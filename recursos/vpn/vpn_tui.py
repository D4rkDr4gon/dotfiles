#!/usr/bin/env python3
"""
vpn_tui.py — TUI de gestión de VPN (FortiClient + ProtonVPN/WireGuard).

Todo es autodetectable en runtime — no hay nombres de perfiles/conexiones
hardcodeados en ningún lado:

  - FortiClient: los perfiles se descubren parseando `fortivpn list`, el
    estado con `fortivpn status`.
  - ProtonVPN (WireGuard manual, sin cliente oficial): las conexiones se
    descubren vía `nmcli -t -f NAME,TYPE connection show` filtrando
    TYPE=wireguard, y se cruzan con los .conf disponibles en
    ~/dotfiles/recursos/PROTON/*.conf para poder ofrecer "importar" los
    que todavía no están en NetworkManager.

Modo rápido para waybar (sin Textual, sin GUI):

    vpn_tui.py --waybar-status

Imprime una sola línea JSON: {"text", "tooltip", "class"} y sale.
class = "connected" | "disconnected"

Modo interactivo (TUI completa):

    vpn_tui.py

Atajos: 1/2/3 tabs (Estado/FortiClient/ProtonVPN), Enter en la tabla
conecta/desconecta (toggle según el estado de la fila seleccionada),
r refrescar, ? ayuda, q salir. "Nuevo perfil" / "importar .conf" es
solo por botón (sin atajo de teclado).
"""

from __future__ import annotations

import json
import os
import pty
import re
import select
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

PROTON_DIR = Path.home() / "dotfiles" / "recursos" / "PROTON"


# ════════════════════════════════════════════════════════════════
#  BACKEND — nada de Textual acá, para que --waybar-status sea liviano
# ════════════════════════════════════════════════════════════════
def _run(cmd: list[str], timeout: float = 6.0, input_text: Optional[str] = None) -> subprocess.CompletedProcess:
    try:
        return subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            input=input_text,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired) as e:
        return subprocess.CompletedProcess(cmd, 1, "", str(e))


@dataclass
class FortiState:
    running: bool
    profiles: list[str]

    @property
    def active_profile(self) -> Optional[str]:
        # fortivpn no expone en `status` qué perfil está activo; si hay
        # exactamente un perfil configurado y está corriendo, es ese.
        if self.running and len(self.profiles) == 1:
            return self.profiles[0]
        return None


@dataclass
class ProtonConn:
    name: str
    imported: bool          # existe como conexión NM
    active: bool             # está `up` ahora mismo
    conf_path: Optional[Path]  # .conf fuente, si existe en dotfiles


def forti_list() -> list[str]:
    """Parsea `fortivpn list` genéricamente: cualquier línea de contenido
    que no termine en ':' (es decir, no sea un encabezado de sección tipo
    'VPNs:' / 'Personal VPNs:' / 'Global VPNs:') es un nombre de perfil."""
    r = _run(["fortivpn", "list"])
    if r.returncode != 0:
        return []
    profiles = []
    for line in r.stdout.splitlines():
        s = line.strip()
        if not s or s.endswith(":"):
            continue
        profiles.append(s)
    return profiles


def forti_status() -> bool:
    r = _run(["fortivpn", "status"])
    return "Status: Running" in r.stdout


def get_forti_state() -> FortiState:
    return FortiState(running=forti_status(), profiles=forti_list())


def forti_saved_username(name: str) -> Optional[str]:
    """Lee el usuario ya guardado para un perfil (`fortivpn view "<name>"`),
    para no obligar a re-tipearlo cada vez que se conecta."""
    r = _run(["fortivpn", "view", name])
    if r.returncode != 0:
        return None
    for line in r.stdout.splitlines():
        s = line.strip()
        if s.startswith("Username:"):
            user = s.split(":", 1)[1].strip()
            return user or None
    return None


def forti_connect(name: str, user: Optional[str] = None, password: Optional[str] = None,
                   timeout: float = 60.0) -> subprocess.CompletedProcess:
    """Conecta un perfil FortiClient.

    IMPORTANTE — por qué esto usa un pty y no subprocess.run(input=...):
    `fortivpn connect --password` pide la contraseña con un prompt
    interactivo estilo getpass() (requiere terminal real, isatty()==True).
    Si se le da la contraseña por un pipe común (stdin no es tty, que es
    lo que hace subprocess.run(input=...)) el binario NUNCA llega a leerla:
    falla al toque con "Please input password." (rc=255), sin siquiera
    intentar la conexión de red. Confirmado corriendo el comando a mano
    con y sin pty — con pipe plano falla en <100ms; con un pty real,
    fortivpn efectivamente pide "Password:" y, si el gateway tiene un
    certificado no confiable (como plug-zone.fortiddns.com, certificado
    self-signed de Fortinet), un segundo prompt interactivo "Confirm
    (y/n)" antes de intentar el login. Sin ese "y" explícito, el login
    se cancela solo (rc=0, "Notification: Login canceled") — de nuevo,
    sin llegar a autenticar. Ninguno de estos casos es un problema de
    red/VPN lento: en pruebas manuales, el handshake real (login
    correcto o incorrecto) tarda bien por debajo de 1 segundo una vez
    que el pty entrega la contraseña. El timeout de 60s de acá es sólo
    un colchón de seguridad para conexiones legítimamente más lentas
    (red mala, 2FA, etc.), no el mecanismo real por el que se resuelve
    la conexión.
    """
    cmd = ["fortivpn", "connect", name]
    if user:
        cmd += [f"--user={user}"]
    if password is not None:
        cmd += ["--password"]

    master, slave = pty.openpty()
    try:
        proc = subprocess.Popen(cmd, stdin=slave, stdout=slave, stderr=slave, close_fds=True)
        os.close(slave)
        slave = -1

        out = b""
        pw_sent = password is None  # si no hay password, no hay nada que mandar
        confirm_sent = False
        t0 = time.monotonic()
        while time.monotonic() - t0 < timeout:
            r, _, _ = select.select([master], [], [], 1.0)
            if master in r:
                try:
                    chunk = os.read(master, 4096)
                except OSError:
                    break  # el otro extremo del pty se cerró
                if not chunk:
                    break
                out += chunk
                if not pw_sent and b"Password:" in chunk:
                    os.write(master, (password or "") .encode() + b"\n")
                    pw_sent = True
                if not confirm_sent and b"Confirm" in chunk and b"y/n" in chunk:
                    # certificado del gateway no confiable (self-signed) —
                    # ya lo acepta el usuario al usar este perfil desde
                    # FortiClient GUI/CLI manualmente; lo confirmamos acá
                    # para que el flujo no quede colgado en un prompt que
                    # esta TUI no muestra.
                    os.write(master, b"y\n")
                    confirm_sent = True
            if proc.poll() is not None:
                # drenar lo que quede en el buffer del pty tras el exit
                try:
                    while True:
                        r, _, _ = select.select([master], [], [], 0.2)
                        if master not in r:
                            break
                        chunk = os.read(master, 4096)
                        if not chunk:
                            break
                        out += chunk
                except OSError:
                    pass
                break
        else:
            # timeout real: el proceso nunca terminó ni pidió nada más
            proc.kill()
            proc.wait(timeout=5)
            # best-effort: liberar el daemon de FortiClient para que el
            # próximo intento no quede bloqueado con "Another instance of
            # this program is running" por culpa de este intento matado.
            _run(["fortivpn", "disconnect"], timeout=10)
            return subprocess.CompletedProcess(
                cmd, 1, out.decode(errors="replace"),
                f"timeout de {timeout:.0f}s esperando a fortivpn (no es un límite de red real, "
                "ver comentario en forti_connect)",
            )

        returncode = proc.wait(timeout=5)
        text = out.decode(errors="replace")
        return subprocess.CompletedProcess(cmd, returncode, text, "")
    finally:
        if slave != -1:
            try:
                os.close(slave)
            except OSError:
                pass
        os.close(master)


def forti_disconnect() -> subprocess.CompletedProcess:
    return _run(["fortivpn", "disconnect"], timeout=15)


def nm_wireguard_connections() -> dict[str, bool]:
    """Devuelve {nombre_conexion_NM: activa} para todas las conexiones
    tipo wireguard conocidas por NetworkManager (importadas o no)."""
    r = _run(["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "connection", "show"])
    result: dict[str, bool] = {}
    if r.returncode != 0:
        return result
    for line in r.stdout.splitlines():
        # formato terse: NAME:TYPE:DEVICE  (nmcli escapa ':' internos con \:)
        parts = line.split(":")
        if len(parts) < 3:
            continue
        device = parts[-1]
        conn_type = parts[-2]
        name = ":".join(parts[:-2])
        if conn_type != "wireguard":
            continue
        result[name] = bool(device.strip())
    return result


def proton_profiles() -> list[ProtonConn]:
    """Cruza conexiones NM tipo wireguard con los .conf disponibles en
    ~/dotfiles/recursos/PROTON/. Ningún nombre está hardcodeado."""
    nm_conns = nm_wireguard_connections()
    confs = {}
    if PROTON_DIR.is_dir():
        for f in sorted(PROTON_DIR.glob("*.conf")):
            confs[f.stem] = f

    names = set(nm_conns) | set(confs)
    out = []
    for name in sorted(names):
        out.append(ProtonConn(
            name=name,
            imported=name in nm_conns,
            active=nm_conns.get(name, False),
            conf_path=confs.get(name),
        ))
    return out


def proton_connect(name: str) -> subprocess.CompletedProcess:
    return _run(["nmcli", "connection", "up", name], timeout=20)


def proton_disconnect(name: str) -> subprocess.CompletedProcess:
    return _run(["nmcli", "connection", "down", name], timeout=15)


_VALID_IFNAME_RE = re.compile(r"^[A-Za-z0-9_-]+$")


def _valid_wg_ifname(name: str) -> bool:
    """NetworkManager exige que el nombre de archivo (sin '.conf') de un
    .conf de WireGuard sea, tal cual, un nombre de interfaz de red válido:
    <=15 caracteres (IFNAMSIZ del kernel) y sin espacios/puntos/etc. Es
    una limitación de NetworkManager/kernel, no de esta TUI."""
    return bool(name) and len(name) <= 15 and _VALID_IFNAME_RE.match(name) is not None


def proton_import(conf_path: Path, connection_name: Optional[str] = None) -> subprocess.CompletedProcess:
    """Importa un .conf de WireGuard a NetworkManager.

    `nmcli connection import type wireguard file <path>` usa el nombre
    del archivo (sin extensión) como nombre de interfaz de red Y como
    nombre de la conexión. Si ese nombre no es un ifname válido — algo
    común acá, porque los .conf de ProtonVPN en este repo tienen nombres
    descriptivos largos tipo "ARCH_LINUX_EUROPA-ES-73.conf" (23
    caracteres) — nmcli falla con: "The name of the WireGuard config must
    be a valid interface name followed by '.conf'". No es un bug de esta
    TUI ni un problema de permisos: es una restricción real de
    NetworkManager/el kernel (IFNAMSIZ=16, incluyendo el nul).

    Para no perder la posibilidad de usar nombres descriptivos (que es
    justamente cómo esta TUI matchea perfiles — por el stem del archivo),
    cuando el nombre no es válido como ifname se importa desde una copia
    temporal con un nombre corto autogenerado, y después se renombra la
    conexión resultante (nmcli connection modify ... connection.id) al
    nombre original — connection.id sí admite cualquier longitud/formato,
    a diferencia del nombre de interfaz."""
    name = connection_name or conf_path.stem

    if _valid_wg_ifname(name):
        return _run(["nmcli", "connection", "import", "type", "wireguard", "file", str(conf_path)], timeout=15)

    try:
        data = conf_path.read_bytes()
    except OSError as e:
        return subprocess.CompletedProcess(["nmcli"], 1, "", f"no se pudo leer {conf_path}: {e}")

    fd, tmp_name = tempfile.mkstemp(prefix="wgimp", suffix=".conf", dir="/tmp")
    tmp_path = Path(tmp_name)
    tmp_ifname = tmp_path.stem  # p.ej. "wgimpAB12cd" — siempre válido por construcción
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(data)

        r = _run(["nmcli", "connection", "import", "type", "wireguard", "file", str(tmp_path)], timeout=15)
        if r.returncode != 0:
            return r

        rn = _run(["nmcli", "connection", "modify", tmp_ifname, "connection.id", name], timeout=10)
        if rn.returncode != 0:
            # la conexión quedó importada (como tmp_ifname) aunque no se
            # pudo renombrar — devolvemos el error del rename, que es el
            # que hay que resolver, sin perder la conexión ya creada.
            rn.stdout = (r.stdout + "\n" + rn.stdout).strip()
            return rn
        return r
    finally:
        tmp_path.unlink(missing_ok=True)


def waybar_status_json() -> str:
    forti = get_forti_state()
    proton_active = [p for p in proton_profiles() if p.active]

    connected = forti.running or bool(proton_active)
    parts_tooltip = []

    if forti.running:
        label = forti.active_profile or "activo"
        parts_tooltip.append(f"FortiClient: {label}")
    else:
        parts_tooltip.append("FortiClient: desconectado")

    if proton_active:
        parts_tooltip.append("ProtonVPN: " + ", ".join(p.name for p in proton_active))
    else:
        parts_tooltip.append("ProtonVPN: desconectado")

    icon = "󰦝" if connected else "󰦞"
    text = icon
    tooltip = "\n".join(parts_tooltip) + "\nClick para gestionar VPN"
    cls = "connected" if connected else "disconnected"

    return json.dumps({"text": text, "tooltip": tooltip, "class": cls}, ensure_ascii=False)


# ════════════════════════════════════════════════════════════════
#  MODO --waybar-status: sin Textual, rápido, sale enseguida
# ════════════════════════════════════════════════════════════════
def main_waybar_status() -> None:
    try:
        print(waybar_status_json())
    except Exception as e:  # nunca colgar el polling de waybar
        print(json.dumps({"text": "󰦞", "tooltip": f"vpn-tui error: {e}", "class": "disconnected"}))
    sys.exit(0)


# ════════════════════════════════════════════════════════════════
#  TUI (Textual) — se importa solo si hace falta
# ════════════════════════════════════════════════════════════════
def run_tui() -> None:
    from textual import on
    from textual.app import App, ComposeResult
    from textual.binding import Binding
    from textual.containers import Container, Horizontal, ScrollableContainer
    from textual.screen import ModalScreen
    from textual.widgets import (
        Button, DataTable, Footer, Header, Input, Label,
        Static, TabbedContent, TabPane,
    )

    # ── modal: confirmación ─────────────────────────────────────
    class ConfirmModal(ModalScreen):
        BINDINGS = [Binding("escape", "dismiss(False)", "")]

        def __init__(self, msg: str, **kw):
            super().__init__(**kw)
            self._msg = msg

        def compose(self) -> ComposeResult:
            with Container(id="confirm-box"):
                yield Static(self._msg, id="confirm-msg")
                with Horizontal(id="confirm-btns"):
                    yield Button("Sí", id="btn-yes", variant="error")
                    yield Button("Cancelar", id="btn-no")

        @on(Button.Pressed, "#btn-yes")
        def _yes(self, _):
            self.dismiss(True)

        @on(Button.Pressed, "#btn-no")
        def _no(self, _):
            self.dismiss(False)

    # ── modal: ayuda ─────────────────────────────────────────────
    class HelpModal(ModalScreen):
        BINDINGS = [Binding("escape", "dismiss(None)", ""), Binding("q", "dismiss(None)", "")]

        HELP = """\
[bold #c62828]vpn_tui.py[/bold #c62828] — atajos de teclado
──────────────────────────────────────────

[dim]navegación[/dim]
  [#c62828]1[/#c62828]  estado           [#c62828]2[/#c62828]  forticlient
  [#c62828]3[/#c62828]  protonvpn

[dim]en las tablas (forticlient / protonvpn)[/dim]
  [#c62828]↑ ↓[/#c62828]  mover selección
  [#c62828]Enter[/#c62828]  conectar / desconectar (toggle según estado)
  [#c62828]r[/#c62828]  refrescar

[dim]nuevo perfil[/dim]
  Solo con el botón "+ Nuevo perfil" / "+ Importar .conf"
  de cada tab (no tiene atajo de teclado).

[dim]otros[/dim]
  [#c62828]?[/#c62828]  esta ayuda        [#c62828]q[/#c62828]  salir

[dim]notas[/dim]
  Nada hardcodeado: perfiles FortiClient vía `fortivpn list`,
  conexiones ProtonVPN vía `nmcli` + ~/dotfiles/recursos/PROTON/*.conf

  [dim]Escape / q para cerrar[/dim]"""

        def compose(self) -> ComposeResult:
            with Container(id="help-box"):
                yield Static(self.HELP)
                yield Button("Cerrar", id="btn-close")

        @on(Button.Pressed, "#btn-close")
        def _close(self, _):
            self.dismiss(None)

    # ── modal: nuevo perfil FortiClient ────────────────────────
    class FortiNewModal(ModalScreen):
        BINDINGS = [Binding("escape", "dismiss(None)", "")]

        def compose(self) -> ComposeResult:
            with Container(id="modal-box"):
                yield Static("Nuevo perfil FortiClient", id="modal-ttl")
                yield Static(
                    "fortivpn edit es un flujo interactivo (prompts de host,\n"
                    "puerto, certificados, etc). La TUI se suspende y te deja\n"
                    "en el terminal para completarlo; al terminar volvés acá.",
                    id="modal-info",
                )
                yield Label("nombre del perfil  *")
                yield Input(placeholder="ej: MI-VPN", id="f-name")
                with Horizontal(id="modal-btns"):
                    yield Button("Continuar", id="btn-go", variant="success")
                    yield Button("Cancelar", id="btn-cancel")

        @on(Button.Pressed, "#btn-go")
        def _go(self, _):
            name = self.query_one("#f-name", Input).value.strip()
            if not name:
                self.notify("nombre requerido", severity="error")
                return
            self.dismiss(name)

        @on(Button.Pressed, "#btn-cancel")
        def _cancel(self, _):
            self.dismiss(None)

    # ── modal: conectar FortiClient (usuario/pass opcional) ────
    class FortiConnectModal(ModalScreen):
        BINDINGS = [Binding("escape", "dismiss(None)", "")]

        def __init__(self, profile: str, default_user: str = "", **kw):
            super().__init__(**kw)
            self._profile = profile
            self._default_user = default_user

        def compose(self) -> ComposeResult:
            with Container(id="modal-box"):
                yield Static(f"Conectar: {self._profile}", id="modal-ttl")
                yield Label("usuario (opcional, si no está guardado)")
                yield Input(value=self._default_user, placeholder="usuario", id="f-user")
                yield Label("contraseña (opcional)")
                yield Input(password=True, placeholder="••••••••", id="f-pass")
                yield Static(
                    "[dim]pegar: Ctrl+V / Ctrl+Shift+V / click derecho — "
                    "Enter avanza de campo, Enter en contraseña conecta[/dim]",
                    id="modal-hint",
                )
                with Horizontal(id="modal-btns"):
                    yield Button("Conectar", id="btn-go", variant="success")
                    yield Button("Cancelar", id="btn-cancel")

        def on_mount(self) -> None:
            # Si ya hay usuario (guardado en el perfil o pasado por parámetro)
            # el campo útil para completar es la contraseña — evita que el
            # foco por defecto de Textual (primer widget enfocable) quede en
            # "usuario" mientras el usuario mira/tipea en "contraseña" y esa
            # ve vacío.
            if self._default_user:
                self.query_one("#f-pass", Input).focus()
            else:
                self.query_one("#f-user", Input).focus()

        @on(Input.Submitted, "#f-user")
        def _user_submitted(self, _):
            self.query_one("#f-pass", Input).focus()

        @on(Input.Submitted, "#f-pass")
        def _pass_submitted(self, _):
            self._submit()

        @on(Button.Pressed, "#btn-go")
        def _go(self, _):
            self._submit()

        def _submit(self) -> None:
            user = self.query_one("#f-user", Input).value.strip() or None
            pw = self.query_one("#f-pass", Input).value or None
            self.dismiss((user, pw))

        @on(Button.Pressed, "#btn-cancel")
        def _cancel(self, _):
            self.dismiss(None)

    # ── modal: nuevo perfil Proton (importar .conf) ────────────
    class ProtonImportModal(ModalScreen):
        BINDINGS = [Binding("escape", "dismiss(None)", "")]

        def __init__(self, suggestion: str = "", **kw):
            super().__init__(**kw)
            self._suggestion = suggestion

        def compose(self) -> ComposeResult:
            with Container(id="modal-box"):
                yield Static("Importar perfil ProtonVPN", id="modal-ttl")
                yield Static(
                    f"Path de un archivo .conf de WireGuard.\n"
                    f"Por convención se guardan en:\n{PROTON_DIR}/",
                    id="modal-info",
                )
                yield Label("path del .conf  *")
                yield Input(value=self._suggestion, placeholder=str(PROTON_DIR / "nuevo.conf"), id="f-path")
                with Horizontal(id="modal-btns"):
                    yield Button("Importar", id="btn-go", variant="success")
                    yield Button("Cancelar", id="btn-cancel")

        @on(Button.Pressed, "#btn-go")
        def _go(self, _):
            path = self.query_one("#f-path", Input).value.strip()
            if not path:
                self.notify("path requerido", severity="error")
                return
            self.dismiss(Path(path).expanduser())

        @on(Button.Pressed, "#btn-cancel")
        def _cancel(self, _):
            self.dismiss(None)

    # ── app principal ────────────────────────────────────────────
    class VpnApp(App):
        TITLE = "vpn_tui.py"
        SUB_TITLE = "FortiClient + ProtonVPN"
        # Textual habilita ctrl+p (selector de temas, command palette) por
        # defecto en toda App. No lo pedimos ni lo queremos acá: lo
        # desactivamos explícitamente para que no aparezca ni en el
        # footer ni al presionar ctrl+p.
        ENABLE_COMMAND_PALETTE = False

        CSS = r"""
        Screen { background: #0a0a0a; }

        Header   { background: #0d0d0d; color: #c62828; height: 2; }
        Footer   { background: #0d0d0d; color: #555555; height: 1; }

        TabbedContent            { height: 1fr; }
        TabbedContent > TabPane  { padding: 1 2; }
        Tabs                     { background: #0d0d0d; }
        Tab                      { background: #0d0d0d; color: #444444; padding: 0 2; }
        Tab:focus, Tab.-active   { background: #150808; color: #c62828; }
        Tab:hover                { color: #aaaaaa; }

        DataTable {
            background: #0a0a0a;
            color: #c5c8c6;
            border: tall #1a1a1a;
            height: 1fr;
        }
        DataTable > .datatable--header  { background: #0d0d0d; color: #555555; text-style: none; }
        DataTable > .datatable--cursor  { background: #2a0d0d; color: #ff4444; }
        DataTable > .datatable--hover   { background: #0f0f0f; }

        Input   { background: #111111; border: tall #2a2a2a; color: #efefef; margin-bottom: 1; }
        Input:focus { background: #1a0d0d; border: tall #c62828; color: #ffffff; }

        Button {
            background: #141414;
            border: tall #2a2a2a;
            color: #777777;
            min-width: 14;
            margin-right: 1;
            height: 3;
        }
        Button:hover           { background: #1e1e1e; color: #efefef; border: tall #555555; }
        Button.-success        { background: #2a0d0d; border: tall #5c1a1a; color: #ff6666; }
        Button.-success:hover  { background: #c62828; color: #0a0a0a; text-style: bold; }
        Button.-error          { background: #180000; border: tall #5c0000; color: #ff4444; }
        Button.-error:hover    { background: #330000; color: #ff6666; }

        Label { color: #555555; margin-bottom: 0; }

        ModalScreen { align: center middle; background: rgba(0,0,0,0.92); }

        #modal-box {
            background: #0d0d0d;
            border: tall #8e1a1a;
            padding: 2 3;
            width: 64;
            max-height: 92vh;
        }
        #modal-ttl    { color: #c62828; text-style: bold; margin-bottom: 1; }
        #modal-info   { color: #8a8a8a; margin-bottom: 1; }
        #modal-hint   { color: #666666; margin-bottom: 1; }
        #modal-btns   { margin-top: 1; }

        #confirm-box {
            background: #0d0d0d;
            border: tall #5c0000;
            padding: 2 3;
            width: 56;
            height: auto;
        }
        #confirm-msg  { color: #cccccc; margin-bottom: 2; }

        #help-box {
            background: #0d0d0d;
            border: tall #8e1a1a;
            padding: 2 3;
            width: 58;
            height: auto;
        }

        .action-bar  { height: 3; margin-bottom: 1; }
        .hint        { color: #555555; margin-bottom: 1; }
        ScrollableContainer { background: #0a0a0a; }
        """

        BINDINGS = [
            Binding("1", "switch_tab('tab-estado')", "estado", show=True),
            Binding("2", "switch_tab('tab-forti')", "forticlient", show=True),
            Binding("3", "switch_tab('tab-proton')", "protonvpn", show=True),
            Binding("enter", "toggle_row", "conectar/desconectar", show=True),
            Binding("r", "refresh", "refrescar", show=True),
            Binding("question_mark", "help", "ayuda", show=True),
            Binding("q", "quit", "salir", show=True),
        ]

        def compose(self) -> ComposeResult:
            yield Header()
            with TabbedContent(id="tabs"):
                with TabPane("estado", id="tab-estado"):
                    yield DataTable(id="estado-table", show_cursor=False)

                with TabPane("forticlient", id="tab-forti"):
                    with Horizontal(classes="action-bar"):
                        yield Button("Conectar", id="btn-forti-connect", variant="success")
                        yield Button("Desconectar", id="btn-forti-disconnect")
                        yield Button("+ Nuevo perfil", id="btn-forti-new")
                    yield Static("perfiles descubiertos vía `fortivpn list` — Enter en la tabla conecta/desconecta", classes="hint")
                    yield DataTable(id="forti-table", cursor_type="row")

                with TabPane("protonvpn", id="tab-proton"):
                    with Horizontal(classes="action-bar"):
                        yield Button("Conectar", id="btn-proton-connect", variant="success")
                        yield Button("Desconectar", id="btn-proton-disconnect")
                        yield Button("+ Importar .conf", id="btn-proton-new")
                    yield Static(f"conexiones NM wireguard + .conf en {PROTON_DIR} — Enter en la tabla conecta/desconecta", classes="hint")
                    yield DataTable(id="proton-table", cursor_type="row")
            yield Footer()

        def on_mount(self) -> None:
            self.query_one("#estado-table", DataTable).add_columns("servicio", "estado", "detalle")
            self.query_one("#forti-table", DataTable).add_columns("perfil", "estado")
            self.query_one("#proton-table", DataTable).add_columns("conexión", "importada", "estado", "fuente")
            self.refresh_all()
            self.set_interval(5.0, self.refresh_all)

        # ── refresco ────────────────────────────────────────────
        def refresh_all(self) -> None:
            self._refresh_estado()
            self._refresh_forti()
            self._refresh_proton()

        def _refresh_estado(self) -> None:
            t = self.query_one("#estado-table", DataTable)
            t.clear()
            forti = get_forti_state()
            proton = proton_profiles()
            proton_active = [p for p in proton if p.active]

            t.add_row(
                "FortiClient",
                "activa" if forti.running else "inactiva",
                forti.active_profile or (", ".join(forti.profiles) or "sin perfiles"),
            )
            t.add_row(
                "ProtonVPN",
                "activa" if proton_active else "inactiva",
                ", ".join(p.name for p in proton_active) or f"{len(proton)} perfil(es) conocido(s)",
            )

        def _refresh_forti(self) -> None:
            t = self.query_one("#forti-table", DataTable)
            t.clear()
            self._forti_state = get_forti_state()
            for p in self._forti_state.profiles:
                active = self._forti_state.running and self._forti_state.active_profile == p
                t.add_row(p, "conectado" if active else "desconectado", key=p)

        def _refresh_proton(self) -> None:
            t = self.query_one("#proton-table", DataTable)
            t.clear()
            self._proton_profiles = proton_profiles()
            for p in self._proton_profiles:
                t.add_row(
                    p.name,
                    "sí" if p.imported else "no (solo .conf)",
                    "activa" if p.active else "inactiva",
                    str(p.conf_path) if p.conf_path else "—",
                    key=p.name,
                )

        def action_refresh(self) -> None:
            self.refresh_all()
            self.notify("actualizado")

        def action_switch_tab(self, tab_id: str) -> None:
            self.query_one("#tabs", TabbedContent).active = tab_id

        def action_help(self) -> None:
            self.push_screen(HelpModal())

        # ── helpers de selección ────────────────────────────────
        def _active_tab(self) -> str:
            return self.query_one("#tabs", TabbedContent).active

        @staticmethod
        def _sel_key(table: DataTable) -> Optional[str]:
            try:
                row_key, _ = table.coordinate_to_cell_key(table.cursor_coordinate)
                return str(row_key.value) if row_key.value is not None else None
            except Exception:
                return None

        # ── acciones: conectar / desconectar (toggle con Enter) ──
        def action_toggle_row(self) -> None:
            """Fallback a nivel App para el binding 'enter' — en la
            práctica, cuando el foco está en una DataTable, es esta la que
            captura Enter primero y emite RowSelected (ver handlers de
            abajo); este método cubre los casos donde no hay tabla
            enfocada (p.ej. tab Estado, que no tiene selección)."""
            tab = self._active_tab()
            if tab == "tab-forti":
                key = self._sel_key(self.query_one("#forti-table", DataTable))
                if key:
                    self._toggle_forti(key)
                else:
                    self.notify("no hay perfiles FortiClient", severity="warning")
            elif tab == "tab-proton":
                key = self._sel_key(self.query_one("#proton-table", DataTable))
                if key:
                    self._toggle_proton(key)
                else:
                    self.notify("no hay conexiones ProtonVPN", severity="warning")
            else:
                self.notify("cambiá a la tab forticlient o protonvpn", severity="warning")

        @on(DataTable.RowSelected, "#forti-table")
        def _forti_row_selected(self, event: DataTable.RowSelected) -> None:
            key = event.row_key.value
            if key:
                self._toggle_forti(str(key))

        @on(DataTable.RowSelected, "#proton-table")
        def _proton_row_selected(self, event: DataTable.RowSelected) -> None:
            key = event.row_key.value
            if key:
                self._toggle_proton(str(key))

        def _toggle_forti(self, profile: str) -> None:
            state = get_forti_state()
            connected = state.running and state.active_profile == profile
            if connected:
                r = forti_disconnect()
                self.notify("FortiClient desconectado" if r.returncode == 0 else f"error: {r.stderr.strip()}",
                            severity="information" if r.returncode == 0 else "error")
                self.refresh_all()
            else:
                self._forti_connect_flow(profile)

        def _toggle_proton(self, name: str) -> None:
            profiles = proton_profiles()
            target = next((p for p in profiles if p.name == name), None)
            if target is None:
                return
            if target.active:
                r = proton_disconnect(name)
                self.notify(f"{name} desconectada" if r.returncode == 0 else f"error: {r.stderr.strip()}",
                            severity="information" if r.returncode == 0 else "error")
                self.refresh_all()
            elif not target.imported:
                self.notify(f"{name} no está importada — usá el botón '+ Importar .conf'", severity="warning")
            else:
                r = proton_connect(name)
                self.notify(f"{name} conectada" if r.returncode == 0 else f"error: {r.stderr.strip()}",
                            severity="information" if r.returncode == 0 else "error")
                self.refresh_all()

        def _forti_connect_flow(self, profile: Optional[str] = None) -> None:
            state = get_forti_state()
            if not state.profiles:
                self.notify("no hay perfiles FortiClient — creá uno con el botón '+ Nuevo perfil'", severity="warning")
                return
            if profile is None:
                key = self._sel_key(self.query_one("#forti-table", DataTable))
                profile = key or state.profiles[0]

            def _after(result):
                if result is None:
                    return
                user, pw = result
                r = forti_connect(profile, user=user, password=pw)
                ok = r.returncode == 0 or "Status: Running" in (r.stdout or "")
                self.notify(f"conectando a {profile}…" if ok else f"error: {r.stderr.strip() or r.stdout.strip()}",
                            severity="information" if ok else "error")
                self.refresh_all()

            default_user = forti_saved_username(profile) or ""
            self.push_screen(FortiConnectModal(profile, default_user=default_user), _after)

        def _proton_connect_flow(self) -> None:
            profiles = proton_profiles()
            if not profiles:
                self.notify("no hay conexiones ProtonVPN — importá una con el botón '+ Importar .conf'", severity="warning")
                return
            key = self._sel_key(self.query_one("#proton-table", DataTable))
            target = next((p for p in profiles if p.name == key), None) or profiles[0]

            if not target.imported:
                self.notify(f"{target.name} no está importada a NetworkManager — usá el botón '+ Importar .conf'", severity="warning")
                return

            r = proton_connect(target.name)
            self.notify(f"{target.name} conectada" if r.returncode == 0 else f"error: {r.stderr.strip()}",
                        severity="information" if r.returncode == 0 else "error")
            self.refresh_all()

        # ── acciones: nuevo perfil (solo botón, sin atajo de teclado) ─
        def _forti_new_flow(self) -> None:
            def _after(name: Optional[str]):
                if not name:
                    return
                with self.suspend():
                    print(f"\n== fortivpn edit \"{name}\" ==\n")
                    subprocess.run(["fortivpn", "edit", name])
                    input("\n(presioná ENTER para volver a la TUI)")
                self.refresh_all()
                self.notify(f"perfil '{name}' actualizado")

            self.push_screen(FortiNewModal(), _after)

        def _proton_new_flow(self) -> None:
            def _after(path: Optional[Path]):
                if not path:
                    return
                if not path.is_file():
                    self.notify(f"no existe: {path}", severity="error")
                    return
                r = proton_import(path)
                if r.returncode == 0:
                    self.notify(f"importado: {path.stem}")
                else:
                    self.notify(f"error importando: {r.stderr.strip()}", severity="error")
                self.refresh_all()

            self.push_screen(ProtonImportModal(), _after)

        # ── click en botones (accesos alternativos a los bindings) ─
        @on(Button.Pressed, "#btn-forti-connect")
        def _btn_forti_connect(self, _):
            self._forti_connect_flow()

        @on(Button.Pressed, "#btn-forti-disconnect")
        def _btn_forti_disconnect(self, _):
            r = forti_disconnect()
            self.notify("desconectado" if r.returncode == 0 else f"error: {r.stderr.strip()}")
            self.refresh_all()

        @on(Button.Pressed, "#btn-forti-new")
        def _btn_forti_new(self, _):
            self._forti_new_flow()

        @on(Button.Pressed, "#btn-proton-connect")
        def _btn_proton_connect(self, _):
            self._proton_connect_flow()

        @on(Button.Pressed, "#btn-proton-disconnect")
        def _btn_proton_disconnect(self, _):
            key = self._sel_key(self.query_one("#proton-table", DataTable))
            if not key:
                self.notify("seleccioná una conexión", severity="warning")
                return
            r = proton_disconnect(key)
            self.notify(f"{key} desconectada" if r.returncode == 0 else f"error: {r.stderr.strip()}")
            self.refresh_all()

        @on(Button.Pressed, "#btn-proton-new")
        def _btn_proton_new(self, _):
            self._proton_new_flow()

    VpnApp().run()


# ════════════════════════════════════════════════════════════════
def main() -> None:
    if "--waybar-status" in sys.argv:
        main_waybar_status()
        return
    run_tui()


if __name__ == "__main__":
    main()
