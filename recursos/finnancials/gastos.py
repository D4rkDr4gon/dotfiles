#!/usr/bin/env python3
"""
gastos.sh — TUI expense manager
════════════════════════════════════════════════════════════════
deps : pip install textual --break-system-packages
uso  : python3 gastos.py
db   : ~/.local/share/gastos/gastos.db

atajos globales
  1-4   cambiar tab            n   nueva transacción
  e     editar fila            x   eliminar fila
  r     refrescar              ?   ayuda
  q     salir
════════════════════════════════════════════════════════════════
"""

import sqlite3
from datetime import date
from pathlib import Path
from typing import Optional

from textual import on
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Container, Horizontal, ScrollableContainer
from textual.screen import ModalScreen
from textual.widgets import (
    Button, DataTable, Footer, Header,
    Input, Label, Rule, Select, Static,
    TabbedContent, TabPane,
)
from rich.text import Text


# ════════════════════════════════════════════════════════════════
#  CONFIG
# ════════════════════════════════════════════════════════════════
DB_DIR  = Path.home() / ".local" / "share" / "gastos"
DB_FILE = DB_DIR / "gastos.db"

ACCT_TYPES = ["banco", "inversiones", "billetera", "efectivo", "tarjeta", "cripto", "otro"]
ACCT_ICONS = {
    "banco": "🏦", "inversiones": "📈", "billetera": "👛",
    "efectivo": "💵", "tarjeta": "💳", "cripto": "₿", "otro": "◻",
}
TXN_TYPES  = ["gasto", "ingreso", "transferencia"]
CURRENCIES = ["ARS", "USD", "USDT", "EUR", "BTC"]


# ════════════════════════════════════════════════════════════════
#  DATABASE
# ════════════════════════════════════════════════════════════════
class Database:
    def __init__(self):
        DB_DIR.mkdir(parents=True, exist_ok=True)
        self.con = sqlite3.connect(str(DB_FILE), check_same_thread=False)
        self.con.row_factory = sqlite3.Row
        self.con.execute("PRAGMA foreign_keys = ON")
        self._init()

    def _init(self):
        self.con.executescript("""
            CREATE TABLE IF NOT EXISTS accounts (
                id       INTEGER PRIMARY KEY AUTOINCREMENT,
                name     TEXT    NOT NULL UNIQUE,
                type     TEXT    NOT NULL DEFAULT 'otro',
                init_bal REAL    NOT NULL DEFAULT 0,
                currency TEXT    NOT NULL DEFAULT 'ARS',
                notes    TEXT    NOT NULL DEFAULT '',
                created  TEXT    DEFAULT (date('now'))
            );
            CREATE TABLE IF NOT EXISTS categories (
                id      INTEGER PRIMARY KEY AUTOINCREMENT,
                name    TEXT    NOT NULL UNIQUE,
                icon    TEXT    NOT NULL DEFAULT '◻',
                budget  REAL    NOT NULL DEFAULT 0,
                created TEXT    DEFAULT (date('now'))
            );
            CREATE TABLE IF NOT EXISTS transactions (
                id            INTEGER PRIMARY KEY AUTOINCREMENT,
                account_id    INTEGER NOT NULL REFERENCES accounts(id)    ON DELETE CASCADE,
                to_account_id INTEGER          REFERENCES accounts(id)    ON DELETE SET NULL,
                category_id   INTEGER          REFERENCES categories(id)  ON DELETE SET NULL,
                type          TEXT    NOT NULL,
                amount        REAL    NOT NULL,
                description   TEXT    NOT NULL,
                note          TEXT    NOT NULL DEFAULT '',
                date          TEXT    NOT NULL,
                created       TEXT    DEFAULT (datetime('now'))
            );
            CREATE INDEX IF NOT EXISTS idx_t_date ON transactions(date DESC);
            CREATE INDEX IF NOT EXISTS idx_t_acc  ON transactions(account_id);
        """)
        # seed default categories
        if not self.con.execute("SELECT 1 FROM categories LIMIT 1").fetchone():
            self.con.executemany(
                "INSERT OR IGNORE INTO categories(name, icon) VALUES(?, ?)",
                [("alimentación","🛒"),("transporte","🚌"),("servicios","💡"),
                 ("salud","🏥"),("entretenimiento","🎮"),("tecnología","💻")],
            )
        self.con.commit()

    def q(self, sql: str, p: tuple = ()) -> list:
        return self.con.execute(sql, p).fetchall()

    def q1(self, sql: str, p: tuple = ()):
        return self.con.execute(sql, p).fetchone()

    def run(self, sql: str, p: tuple = ()) -> int:
        cur = self.con.execute(sql, p)
        self.con.commit()
        return cur.lastrowid

    def balance(self, acc_id: int) -> float:
        row = self.q1("""
            SELECT
                init_bal
                + COALESCE((SELECT SUM(amount) FROM transactions
                             WHERE account_id = a.id AND type = 'ingreso'), 0)
                - COALESCE((SELECT SUM(amount) FROM transactions
                             WHERE account_id = a.id AND type = 'gasto'), 0)
                - COALESCE((SELECT SUM(amount) FROM transactions
                             WHERE account_id = a.id AND type = 'transferencia'), 0)
                + COALESCE((SELECT SUM(amount) FROM transactions
                             WHERE to_account_id = a.id AND type = 'transferencia'), 0)
                AS bal
            FROM accounts a WHERE a.id = ?
        """, (acc_id,))
        return float(row["bal"]) if (row and row["bal"] is not None) else 0.0

    def export_csv(self) -> str:
        lines = ["id,fecha,tipo,descripcion,cuenta,cuenta_destino,categoria,monto,moneda,nota"]
        rows = self.q("""
            SELECT tx.id, tx.date, tx.type, tx.description, tx.amount, tx.note,
                   a.name AS aname, a.currency,
                   COALESCE(c.name,'') AS cname,
                   COALESCE(ta.name,'') AS taname
            FROM transactions tx
            JOIN accounts a ON a.id = tx.account_id
            LEFT JOIN categories c ON c.id = tx.category_id
            LEFT JOIN accounts ta ON ta.id = tx.to_account_id
            ORDER BY tx.date DESC""")
        for r in rows:
            desc = r["description"].replace('"', '""')
            note = (r["note"] or "").replace('"', '""')
            lines.append(
                f'{r["id"]},{r["date"]},{r["type"]},"{desc}",'
                f'"{r["aname"]}","{r["taname"]}","{r["cname"]}",'
                f'{r["amount"]},{r["currency"]},"{note}"'
            )
        return "\n".join(lines)


db = Database()


# ════════════════════════════════════════════════════════════════
#  HELPERS
# ════════════════════════════════════════════════════════════════
def _sel_key(table: DataTable) -> Optional[str]:
    """Return the row-key value of the cursor row, or None."""
    if not table.rows:
        return None
    keys = list(table.rows.keys())
    if table.cursor_row < 0 or table.cursor_row >= len(keys):
        return None
    return keys[table.cursor_row].value


def _q1_val(sql: str, p: tuple, col: str, default=0):
    row = db.q1(sql, p)
    return row[col] if row and row[col] is not None else default


# ════════════════════════════════════════════════════════════════
#  MODAL: CONFIRM
# ════════════════════════════════════════════════════════════════
class ConfirmModal(ModalScreen):
    BINDINGS = [("escape", "dismiss(False)", "")]

    def __init__(self, msg: str, **kw):
        super().__init__(**kw)
        self._msg = msg

    def compose(self) -> ComposeResult:
        with Container(id="confirm-box"):
            yield Static(self._msg, id="confirm-msg")
            yield Rule()
            with Horizontal(id="confirm-btns"):
                yield Button("[ sí, confirmar ]", id="btn-yes", variant="error")
                yield Button("[ cancelar ]",       id="btn-no")

    @on(Button.Pressed, "#btn-yes") def _yes(self, _): self.dismiss(True)
    @on(Button.Pressed, "#btn-no")  def _no(self,  _): self.dismiss(False)


# ════════════════════════════════════════════════════════════════
#  MODAL: HELP
# ════════════════════════════════════════════════════════════════
class HelpModal(ModalScreen):
    BINDINGS = [("escape", "dismiss(None)", ""), ("q", "dismiss(None)", "")]

    HELP = """\
[bold #00ff87]gastos.sh[/bold #00ff87] — atajos de teclado
──────────────────────────────────────────

[dim]navegación[/dim]
  [cyan]1[/cyan]  dashboard        [cyan]2[/cyan]  transacciones
  [cyan]3[/cyan]  cuentas          [cyan]4[/cyan]  categorías

[dim]acciones (según tab activo)[/dim]
  [cyan]n[/cyan]  nueva transacción
  [cyan]e[/cyan]  editar fila seleccionada
  [cyan]x[/cyan]  eliminar fila seleccionada
  [cyan]r[/cyan]  refrescar datos

[dim]en las tablas[/dim]
  [cyan]↑ ↓[/cyan]  mover cursor       [cyan]Enter[/cyan]  editar
  [cyan]PgUp/PgDn[/cyan]  scrollear

[dim]otros[/dim]
  [cyan]?[/cyan]  esta ayuda         [cyan]q[/cyan]  salir

[dim]base de datos[/dim]
  [white]~/.local/share/gastos/gastos.db[/white]
  SQLite estándar — abrila con cualquier cliente.
  Export CSV: botón en tab transacciones.

  [dim]Escape / q para cerrar[/dim]"""

    def compose(self) -> ComposeResult:
        with Container(id="help-box"):
            yield Static(self.HELP)
            yield Rule()
            yield Button("[ cerrar ]", id="btn-close")

    @on(Button.Pressed, "#btn-close") def _close(self, _): self.dismiss(None)


# ════════════════════════════════════════════════════════════════
#  MODAL: ACCOUNT
# ════════════════════════════════════════════════════════════════
class AccountModal(ModalScreen):
    BINDINGS = [("escape", "dismiss(None)", "")]

    def __init__(self, row=None, **kw):
        super().__init__(**kw)
        self._row = row

    def compose(self) -> ComposeResult:
        r = self._row
        with Container(id="modal-box"):
            yield Static("[ editar cuenta ]" if r else "[ nueva cuenta ]", id="modal-ttl")
            yield Rule()
            yield Label("nombre  *")
            yield Input(value=r["name"]       if r else "",
                        placeholder="ej: Santander, Lemon, Binance…", id="f-name")
            yield Label("tipo")
            yield Select([(t, t) for t in ACCT_TYPES],
                         value=r["type"]       if r else "banco", id="f-type")
            yield Label("balance inicial")
            yield Input(value=str(r["init_bal"]) if r else "0",
                        placeholder="0.00", id="f-bal", type="number")
            yield Label("moneda")
            yield Select([(c, c) for c in CURRENCIES],
                         value=r["currency"]   if r else "ARS", id="f-cur")
            yield Label("notas  (opcional)")
            yield Input(value=r["notes"]       if r else "",
                        placeholder="…", id="f-notes")
            yield Rule()
            with Horizontal(id="modal-btns"):
                yield Button("[ guardar ]",  id="btn-save",   variant="success")
                yield Button("[ cancelar ]", id="btn-cancel")

    @on(Button.Pressed, "#btn-save")
    def _save(self, _):
        name = self.query_one("#f-name", Input).value.strip()
        if not name:
            self.notify("nombre requerido", severity="error"); return
        try:
            bal = float(self.query_one("#f-bal", Input).value or "0")
        except ValueError:
            self.notify("balance inválido", severity="error"); return
        self.dismiss({
            "name":     name,
            "type":     self.query_one("#f-type", Select).value,
            "init_bal": bal,
            "currency": self.query_one("#f-cur",  Select).value,
            "notes":    self.query_one("#f-notes", Input).value.strip(),
        })

    @on(Button.Pressed, "#btn-cancel")
    def _cancel(self, _): self.dismiss(None)


# ════════════════════════════════════════════════════════════════
#  MODAL: CATEGORY
# ════════════════════════════════════════════════════════════════
class CategoryModal(ModalScreen):
    BINDINGS = [("escape", "dismiss(None)", "")]

    def __init__(self, row=None, **kw):
        super().__init__(**kw)
        self._row = row

    def compose(self) -> ComposeResult:
        r = self._row
        with Container(id="modal-box"):
            yield Static("[ editar categoría ]" if r else "[ nueva categoría ]", id="modal-ttl")
            yield Rule()
            yield Label("nombre  *")
            yield Input(value=r["name"]   if r else "",
                        placeholder="ej: transporte", id="f-name")
            yield Label("ícono  (emoji o símbolo)")
            yield Input(value=r["icon"]   if r else "◻",
                        placeholder="🚗", id="f-icon")
            yield Label("presupuesto mensual  (0 = sin límite)")
            yield Input(value=str(r["budget"]) if r else "0",
                        placeholder="0.00", id="f-budget", type="number")
            yield Rule()
            with Horizontal(id="modal-btns"):
                yield Button("[ guardar ]",  id="btn-save",   variant="success")
                yield Button("[ cancelar ]", id="btn-cancel")

    @on(Button.Pressed, "#btn-save")
    def _save(self, _):
        name = self.query_one("#f-name", Input).value.strip()
        if not name:
            self.notify("nombre requerido", severity="error"); return
        try:
            budget = float(self.query_one("#f-budget", Input).value or "0")
        except ValueError:
            budget = 0.0
        self.dismiss({
            "name":   name,
            "icon":   self.query_one("#f-icon", Input).value.strip() or "◻",
            "budget": budget,
        })

    @on(Button.Pressed, "#btn-cancel")
    def _cancel(self, _): self.dismiss(None)


# ════════════════════════════════════════════════════════════════
#  MODAL: TRANSACTION
# ════════════════════════════════════════════════════════════════
class TransactionModal(ModalScreen):
    BINDINGS = [("escape", "dismiss(None)", "")]

    def __init__(self, row=None, **kw):
        super().__init__(**kw)
        self._row = row

    @staticmethod
    def _acct_opts() -> list:
        rows = db.q("SELECT id, name, type FROM accounts ORDER BY name")
        return [(f"{ACCT_ICONS.get(r['type'],'◻')} {r['name']}", r["id"]) for r in rows]

    @staticmethod
    def _cat_opts() -> list:
        rows = db.q("SELECT id, name, icon FROM categories ORDER BY name")
        return [("— sin categoría —", 0)] + [(f"{r['icon']} {r['name']}", r["id"]) for r in rows]

    def compose(self) -> ComposeResult:
        r     = self._row
        accts = self._acct_opts()
        cats  = self._cat_opts()
        BLANK = Select.BLANK

        acc_val    = r["account_id"]    if r else (accts[0][1] if accts else BLANK)
        to_acc_val = r["to_account_id"] if (r and r["to_account_id"]) else BLANK
        cat_val    = r["category_id"]   if (r and r["category_id"])   else 0

        with ScrollableContainer(id="modal-box"):
            yield Static("[ editar transacción ]" if r else "[ nueva transacción ]", id="modal-ttl")
            yield Rule()
            yield Label("tipo  *")
            yield Select([(t, t) for t in TXN_TYPES],
                         value=r["type"] if r else "gasto", id="f-type")
            yield Label("cuenta origen  *")
            if not accts:
                yield Static("[red]no hay cuentas — creá una primero (tab 3)[/red]")
            else:
                yield Select(accts, value=acc_val, id="f-account")
            yield Label("cuenta destino  (solo transferencias)")
            if accts:
                yield Select(accts, value=to_acc_val, allow_blank=True, id="f-to-account")
            yield Label("monto  *")
            yield Input(value=str(r["amount"]) if r else "",
                        placeholder="0.00", id="f-amount", type="number")
            yield Label("descripción  *")
            yield Input(value=r["description"] if r else "",
                        placeholder="ej: supermercado, sueldo, transferencia…", id="f-desc")
            yield Label("fecha  * (YYYY-MM-DD)")
            yield Input(value=r["date"] if r else str(date.today()),
                        placeholder=str(date.today()), id="f-date")
            yield Label("categoría")
            yield Select(cats, value=cat_val, id="f-cat")
            yield Label("nota  (opcional)")
            yield Input(value=r["note"] if r else "", placeholder="…", id="f-note")
            yield Rule()
            with Horizontal(id="modal-btns"):
                yield Button("[ guardar ]",  id="btn-save",   variant="success")
                yield Button("[ cancelar ]", id="btn-cancel")

    @on(Button.Pressed, "#btn-save")
    def _save(self, _):
        BLANK = Select.BLANK
        txn_type = self.query_one("#f-type",   Select).value
        amount_s = self.query_one("#f-amount", Input).value.strip()
        desc     = self.query_one("#f-desc",   Input).value.strip()
        date_s   = self.query_one("#f-date",   Input).value.strip()
        note     = self.query_one("#f-note",   Input).value.strip()
        cat_val  = self.query_one("#f-cat",    Select).value

        # account_id
        try:
            account = self.query_one("#f-account", Select).value
        except Exception:
            self.notify("no hay cuentas disponibles", severity="error"); return

        # to_account_id
        try:
            to_acc = self.query_one("#f-to-account", Select).value
        except Exception:
            to_acc = BLANK

        # validations
        if not desc:
            self.notify("descripción requerida", severity="error"); return
        if not amount_s:
            self.notify("monto requerido", severity="error"); return
        try:
            amount = float(amount_s)
            assert amount > 0
        except Exception:
            self.notify("monto inválido — debe ser > 0", severity="error"); return
        if not date_s:
            self.notify("fecha requerida", severity="error"); return
        if account is BLANK:
            self.notify("seleccioná una cuenta", severity="error"); return
        if txn_type == "transferencia" and to_acc is BLANK:
            self.notify("seleccioná cuenta destino para la transferencia", severity="error"); return

        self.dismiss({
            "type":          txn_type,
            "account_id":    account,
            "to_account_id": to_acc if (to_acc is not BLANK) else None,
            "amount":        amount,
            "description":   desc,
            "date":          date_s,
            "category_id":   int(cat_val) if (cat_val and cat_val != 0) else None,
            "note":          note,
        })

    @on(Button.Pressed, "#btn-cancel")
    def _cancel(self, _): self.dismiss(None)


# ════════════════════════════════════════════════════════════════
#  MAIN APP
# ════════════════════════════════════════════════════════════════
class GastosApp(App):

    TITLE     = "gastos.sh"
    SUB_TITLE = f"db → {DB_FILE}"

    CSS = r"""
    Screen { background: #0a0a0a; }

    Header   { background: #0d0d0d; color: #00ff87; height: 2; }
    Footer   { background: #0d0d0d; color: #2a2a2a; height: 1; }

    /* ─ tabs ─────────────────────────────────────── */
    TabbedContent            { height: 1fr; }
    TabbedContent > TabPane  { padding: 1 2; }
    Tabs                     { background: #0d0d0d; }
    Tab                      { background: #0d0d0d; color: #444444; padding: 0 2; }
    Tab:focus, Tab.-active   { background: #111111; color: #00ff87; }
    Tab:hover                { color: #aaaaaa; }

    /* ─ data tables ──────────────────────────────── */
    DataTable {
        background: #0a0a0a;
        color: #cccccc;
        border: tall #1a1a1a;
        height: 1fr;
    }
    DataTable > .datatable--header  { background: #0d0d0d; color: #444444; text-style: none; }
    DataTable > .datatable--cursor  { background: #0a2010; color: #00ff87; }
    DataTable > .datatable--hover   { background: #0f0f0f; }

    /* ─ inputs ───────────────────────────────────── */
    Input   { background: #111111; border: tall #2a2a2a; color: #efefef; margin-bottom: 1; }
    Input:focus { border: tall #00a855; }
    Select  { background: #111111; border: tall #2a2a2a; color: #efefef; margin-bottom: 1; }
    Select:focus         { border: tall #00a855; }
    SelectCurrent        { background: #111111; color: #efefef; }
    SelectOverlay        { background: #111111; border: tall #2a2a2a; }
    SelectOverlay > OptionList > Option:hover { background: #1a2a1a; }

    /* ─ buttons ──────────────────────────────────── */
    Button {
        background: #141414;
        border: tall #2a2a2a;
        color: #777777;
        min-width: 14;
        margin-right: 1;
        height: 3;
    }
    Button:hover           { background: #1e1e1e; color: #efefef; border: tall #555555; }
    Button.-success        { background: #002a15; border: tall #005c2e; color: #00ff87; }
    Button.-success:hover  { background: #00ff87; color: #0a0a0a; text-style: bold; }
    Button.-error          { background: #180000; border: tall #5c0000; color: #ff4444; }
    Button.-error:hover    { background: #330000; color: #ff6666; }
    Button.-warning        { background: #1a1200; border: tall #5c4400; color: #ffd700; }
    Button.-warning:hover  { background: #332400; color: #ffe44d; }

    /* ─ labels ───────────────────────────────────── */
    Label { color: #444444; margin-bottom: 0; }

    /* ─ modals ───────────────────────────────────── */
    ModalScreen { align: center middle; background: rgba(0,0,0,0.92); }

    #modal-box {
        background: #0d0d0d;
        border: tall #005c2e;
        padding: 2 3;
        width: 62;
        max-height: 92vh;
    }
    #modal-ttl    { color: #00ff87; text-style: bold; margin-bottom: 1; }
    #modal-btns   { margin-top: 1; }

    #confirm-box {
        background: #0d0d0d;
        border: tall #5c0000;
        padding: 2 3;
        width: 56;
        height: auto;
    }
    #confirm-msg  { color: #cccccc; margin-bottom: 2; }
    #confirm-btns { margin-top: 0; }

    #help-box {
        background: #0d0d0d;
        border: tall #005c2e;
        padding: 2 3;
        width: 56;
        height: auto;
    }

    /* ─ dashboard ────────────────────────────────── */
    .stat-card {
        background: #0d0d0d;
        border: tall #1a1a1a;
        padding: 1 2;
        margin-right: 1;
        width: 1fr;
        height: 5;
    }
    .sec-title   { color: #005c2e; margin: 1 0; }
    .action-bar  { height: 3; margin-bottom: 1; }

    Rule                    { color: #1a1a1a; margin: 1 0; }
    ScrollableContainer     { background: #0a0a0a; }
    """

    BINDINGS = [
        Binding("1", "switch_tab('tab-dashboard')",    "dashboard",     show=True),
        Binding("2", "switch_tab('tab-transactions')", "transacciones", show=True),
        Binding("3", "switch_tab('tab-accounts')",     "cuentas",       show=True),
        Binding("4", "switch_tab('tab-categories')",   "categorías",    show=True),
        Binding("n", "new_txn",   "nueva txn", show=True),
        Binding("e", "edit_row",  "editar",    show=True),
        Binding("x", "del_row",   "eliminar",  show=True),
        Binding("r", "refresh",   "refrescar", show=False),
        Binding("question_mark", "help", "ayuda", show=True),
        Binding("q", "quit",      "salir",     show=True),
    ]

    # ─────────────────────────────────────────────────────────────
    def compose(self) -> ComposeResult:
        yield Header()
        with TabbedContent(id="tabs"):

            # ── dashboard ─────────────────────────────────
            with TabPane("◈ dashboard", id="tab-dashboard"):
                with ScrollableContainer():
                    with Horizontal(classes="action-bar"):
                        yield Button("[ + nueva txn ]",  id="btn-dash-new", variant="success")
                        yield Button("[ ↺ refrescar ]",   id="btn-dash-ref")
                        yield Button("[ ? ayuda ]",        id="btn-help",    variant="warning")
                    with Horizontal(id="dash-stats"):
                        yield Static("", id="ds-nw",  classes="stat-card")
                        yield Static("", id="ds-out", classes="stat-card")
                        yield Static("", id="ds-in",  classes="stat-card")
                        yield Static("", id="ds-bal", classes="stat-card")
                    yield Static("── cuentas ──", classes="sec-title")
                    yield DataTable(id="dash-acc", show_cursor=False)
                    yield Static("── gastos del mes por categoría ──", classes="sec-title")
                    yield DataTable(id="dash-cat", show_cursor=False)

            # ── transacciones ─────────────────────────────
            with TabPane("≡ transacciones", id="tab-transactions"):
                with Horizontal(classes="action-bar"):
                    yield Button("[ + nueva ]",    id="btn-txn-new",  variant="success")
                    yield Button("[ ✎ editar ]",    id="btn-txn-edit")
                    yield Button("[ ✕ eliminar ]",  id="btn-txn-del",  variant="error")
                    yield Button("[ ⬇ export CSV ]", id="btn-txn-csv",  variant="warning")
                yield DataTable(id="txn-table", cursor_type="row")

            # ── cuentas ───────────────────────────────────
            with TabPane("◉ cuentas", id="tab-accounts"):
                with Horizontal(classes="action-bar"):
                    yield Button("[ + nueva ]",   id="btn-acc-new",  variant="success")
                    yield Button("[ ✎ editar ]",   id="btn-acc-edit")
                    yield Button("[ ✕ eliminar ]", id="btn-acc-del",  variant="error")
                yield DataTable(id="acc-table", cursor_type="row")

            # ── categorías ────────────────────────────────
            with TabPane("⊞ categorías", id="tab-categories"):
                with Horizontal(classes="action-bar"):
                    yield Button("[ + nueva ]",   id="btn-cat-new",  variant="success")
                    yield Button("[ ✎ editar ]",   id="btn-cat-edit")
                    yield Button("[ ✕ eliminar ]", id="btn-cat-del",  variant="error")
                yield DataTable(id="cat-table", cursor_type="row")

        yield Footer()

    # ─────────────────────────────────────────────────────────────
    def on_mount(self) -> None:
        self._init_columns()
        self._refresh_all()

    # ── COLUMN INIT ───────────────────────────────────────────────
    def _init_columns(self) -> None:
        self.query_one("#dash-acc",   DataTable).add_columns(
            "cuenta", "tipo", "moneda", "balance", "# txns")
        self.query_one("#dash-cat",   DataTable).add_columns(
            "categoría", "gastado (mes)", "presupuesto", "estado")
        self.query_one("#txn-table",  DataTable).add_columns(
            "fecha", "descripción", "tipo", "cuenta", "categoría", "monto", "nota")
        self.query_one("#acc-table",  DataTable).add_columns(
            "cuenta", "tipo", "moneda", "bal. inicial", "bal. actual", "notas")
        self.query_one("#cat-table",  DataTable).add_columns(
            "ícono", "nombre", "presupuesto/mes", "gastado (mes)")

    # ── REFRESH ALL ───────────────────────────────────────────────
    def _refresh_all(self) -> None:
        self._refresh_dash()
        self._refresh_txns()
        self._refresh_accs()
        self._refresh_cats()

    def action_refresh(self) -> None:
        self._refresh_all()
        self.notify("✓ datos actualizados")

    # ── DASHBOARD ─────────────────────────────────────────────────
    def _refresh_dash(self) -> None:
        ym   = date.today().strftime("%Y-%m")
        mstr = date.today().strftime("%b %Y")

        # net worth ARS
        accs = db.q("SELECT id, currency FROM accounts")
        nw   = sum(db.balance(a["id"]) for a in accs if a["currency"] == "ARS")

        out = _q1_val("SELECT COALESCE(SUM(amount),0) AS s FROM transactions "
                      "WHERE type='gasto'   AND date LIKE ?", (ym+"%",), "s")
        inc = _q1_val("SELECT COALESCE(SUM(amount),0) AS s FROM transactions "
                      "WHERE type='ingreso' AND date LIKE ?", (ym+"%",), "s")
        bal = inc - out

        self.query_one("#ds-nw",  Static).update(
            f"[dim]patrimonio ARS[/dim]\n[bold white]${nw:,.2f}[/bold white]")
        self.query_one("#ds-out", Static).update(
            f"[dim]gastos {mstr}[/dim]\n[bold red]-${out:,.2f}[/bold red]")
        self.query_one("#ds-in",  Static).update(
            f"[dim]ingresos {mstr}[/dim]\n[bold green]+${inc:,.2f}[/bold green]")
        c, s = ("green", "+") if bal >= 0 else ("red", "-")
        self.query_one("#ds-bal", Static).update(
            f"[dim]balance {mstr}[/dim]\n[bold {c}]{s}${abs(bal):,.2f}[/bold {c}]")

        # account summary table
        t = self.query_one("#dash-acc", DataTable)
        t.clear()
        for a in db.q("SELECT id, name, type, currency FROM accounts ORDER BY name"):
            b    = db.balance(a["id"])
            cnt  = _q1_val("SELECT COUNT(*) AS c FROM transactions WHERE account_id=?",
                           (a["id"],), "c")
            icon = ACCT_ICONS.get(a["type"], "◻")
            bt   = Text(f"${b:,.2f} {a['currency']}")
            bt.stylize("green" if b >= 0 else "bold red")
            t.add_row(f"{icon} {a['name']}", a["type"], a["currency"], bt, str(cnt))

        # category spending chart
        t = self.query_one("#dash-cat", DataTable)
        t.clear()
        cats = db.q("""
            SELECT c.id, c.name, c.icon, c.budget,
                   COALESCE(SUM(
                       CASE WHEN strftime('%Y-%m', tx.date) = ? THEN tx.amount ELSE 0 END
                   ), 0) AS spent
            FROM   categories c
            LEFT JOIN transactions tx
                   ON tx.category_id = c.id AND tx.type = 'gasto'
            GROUP  BY c.id
            ORDER  BY spent DESC""", (ym,))
        for c in cats:
            sp, bud = c["spent"], c["budget"]
            if bud > 0:
                pct = sp / bud * 100
                bar = "█" * int(pct / 5)
                if   pct >= 100: st = Text(f"⚠  {pct:5.1f}%  {bar[:20]}"); st.stylize("bold red")
                elif pct >= 80:  st = Text(f"⚡  {pct:5.1f}%  {bar}");       st.stylize("yellow")
                else:            st = Text(f"✓  {pct:5.1f}%  {bar}");       st.stylize("green")
                bs = f"${bud:,.2f}"
            else:
                st = Text("—"); st.stylize("dim")
                bs = "—"
            spt = Text(f"${sp:,.2f}")
            spt.stylize("white" if sp > 0 else "dim")
            t.add_row(f"{c['icon']} {c['name']}", spt, bs, st)

    # ── TRANSACTIONS ──────────────────────────────────────────────
    def _refresh_txns(self) -> None:
        t = self.query_one("#txn-table", DataTable)
        t.clear()
        rows = db.q("""
            SELECT tx.id  AS tid,
                   tx.date, tx.description, tx.type, tx.amount, tx.note,
                   a.name AS aname, a.currency,
                   c.name AS cname, c.icon AS cicon,
                   ta.name AS taname
            FROM        transactions tx
            JOIN        accounts     a  ON  a.id = tx.account_id
            LEFT JOIN   categories   c  ON  c.id = tx.category_id
            LEFT JOIN   accounts     ta ON ta.id = tx.to_account_id
            ORDER BY tx.date DESC, tx.id DESC
            LIMIT 2000""")
        for r in rows:
            if r["type"] == "gasto":
                tp  = Text("▼ gasto");   tp.stylize("red")
                mnt = Text(f"-${r['amount']:,.2f} {r['currency']}"); mnt.stylize("red")
            elif r["type"] == "ingreso":
                tp  = Text("▲ ingreso"); tp.stylize("green")
                mnt = Text(f"+${r['amount']:,.2f} {r['currency']}"); mnt.stylize("green")
            else:
                tp  = Text("⇄ transf");  tp.stylize("cyan")
                mnt = Text(f"${r['amount']:,.2f} {r['currency']}");  mnt.stylize("cyan")
            acct = r["aname"] + (f" → {r['taname']}" if r["taname"] else "")
            cat  = f"{r['cicon']} {r['cname']}" if r["cname"] else "—"
            t.add_row(r["date"], r["description"], tp, acct, cat, mnt,
                      r["note"] or "", key=str(r["tid"]))

    # ── ACCOUNTS ──────────────────────────────────────────────────
    def _refresh_accs(self) -> None:
        t = self.query_one("#acc-table", DataTable)
        t.clear()
        for a in db.q("SELECT id, name, type, init_bal, currency, notes FROM accounts ORDER BY name"):
            b    = db.balance(a["id"])
            icon = ACCT_ICONS.get(a["type"], "◻")
            bt   = Text(f"${b:,.2f} {a['currency']}")
            bt.stylize("green" if b >= 0 else "bold red")
            t.add_row(
                f"{icon} {a['name']}", a["type"], a["currency"],
                f"${a['init_bal']:,.2f}", bt, a["notes"] or "",
                key=str(a["id"]))

    # ── CATEGORIES ────────────────────────────────────────────────
    def _refresh_cats(self) -> None:
        t  = self.query_one("#cat-table", DataTable)
        t.clear()
        ym = date.today().strftime("%Y-%m")
        rows = db.q("""
            SELECT c.id, c.name, c.icon, c.budget,
                   COALESCE(SUM(
                       CASE WHEN strftime('%Y-%m', tx.date) = ? THEN tx.amount ELSE 0 END
                   ), 0) AS spent
            FROM   categories c
            LEFT JOIN transactions tx
                   ON tx.category_id = c.id AND tx.type = 'gasto'
            GROUP  BY c.id
            ORDER  BY c.name""", (ym,))
        for r in rows:
            bs  = f"${r['budget']:,.2f}" if r["budget"] > 0 else "—"
            spt = Text(f"${r['spent']:,.2f}")
            if r["budget"] > 0 and r["spent"] > r["budget"]: spt.stylize("bold red")
            elif r["spent"] > 0:                              spt.stylize("white")
            else:                                             spt.stylize("dim")
            t.add_row(r["icon"], r["name"], bs, spt, key=str(r["id"]))

    # ── ACTIONS ───────────────────────────────────────────────────
    def action_switch_tab(self, tab_id: str) -> None:
        self.query_one("#tabs", TabbedContent).active = tab_id

    def action_help(self) -> None:
        self.push_screen(HelpModal())

    def action_new_txn(self) -> None:
        if not db.q("SELECT 1 FROM accounts LIMIT 1"):
            self.notify("creá una cuenta primero (tab 3)", severity="warning"); return
        def _cb(r):
            if r:
                db.run(
                    "INSERT INTO transactions"
                    "(type,account_id,to_account_id,category_id,amount,description,note,date)"
                    " VALUES(?,?,?,?,?,?,?,?)",
                    (r["type"], r["account_id"], r["to_account_id"], r["category_id"],
                     r["amount"], r["description"], r["note"], r["date"]))
                self._refresh_all()
                self.notify(f"✓ {r['description']} — ${r['amount']:,.2f}")
        self.push_screen(TransactionModal(), _cb)

    def action_edit_row(self) -> None:
        tab = self.query_one("#tabs", TabbedContent).active
        if   tab == "tab-transactions": self._edit_txn()
        elif tab == "tab-accounts":     self._edit_acc()
        elif tab == "tab-categories":   self._edit_cat()

    def action_del_row(self) -> None:
        tab = self.query_one("#tabs", TabbedContent).active
        if   tab == "tab-transactions": self._del_txn()
        elif tab == "tab-accounts":     self._del_acc()
        elif tab == "tab-categories":   self._del_cat()

    # ── TRANSACTION CRUD ──────────────────────────────────────────
    def _edit_txn(self) -> None:
        key = _sel_key(self.query_one("#txn-table", DataTable))
        if not key: return
        row = db.q1("SELECT * FROM transactions WHERE id=?", (int(key),))
        if not row: return
        def _cb(r):
            if r:
                db.run(
                    "UPDATE transactions SET type=?,account_id=?,to_account_id=?,"
                    "category_id=?,amount=?,description=?,note=?,date=? WHERE id=?",
                    (r["type"], r["account_id"], r["to_account_id"], r["category_id"],
                     r["amount"], r["description"], r["note"], r["date"], int(key)))
                self._refresh_all()
                self.notify("✓ transacción actualizada")
        self.push_screen(TransactionModal(row=row), _cb)

    def _del_txn(self) -> None:
        key = _sel_key(self.query_one("#txn-table", DataTable))
        if not key: return
        row = db.q1("SELECT description, amount FROM transactions WHERE id=?", (int(key),))
        if not row: return
        def _cb(ok):
            if ok:
                db.run("DELETE FROM transactions WHERE id=?", (int(key),))
                self._refresh_all()
                self.notify("✓ transacción eliminada")
        self.push_screen(ConfirmModal(
            f"Eliminar '{row['description']}' (${row['amount']:,.2f})?"), _cb)

    # ── ACCOUNT CRUD ──────────────────────────────────────────────
    def _edit_acc(self) -> None:
        key = _sel_key(self.query_one("#acc-table", DataTable))
        if not key: return
        row = db.q1("SELECT * FROM accounts WHERE id=?", (int(key),))
        if not row: return
        def _cb(r):
            if r:
                db.run(
                    "UPDATE accounts SET name=?,type=?,init_bal=?,currency=?,notes=? WHERE id=?",
                    (r["name"], r["type"], r["init_bal"], r["currency"], r["notes"], int(key)))
                self._refresh_all()
                self.notify("✓ cuenta actualizada")
        self.push_screen(AccountModal(row=row), _cb)

    def _del_acc(self) -> None:
        key = _sel_key(self.query_one("#acc-table", DataTable))
        if not key: return
        row = db.q1("SELECT name FROM accounts WHERE id=?", (int(key),))
        if not row: return
        def _cb(ok):
            if ok:
                db.run("DELETE FROM accounts WHERE id=?", (int(key),))
                self._refresh_all()
                self.notify("✓ cuenta y transacciones eliminadas")
        self.push_screen(ConfirmModal(
            f"Eliminar cuenta '{row['name']}' y TODAS sus transacciones?"), _cb)

    # ── CATEGORY CRUD ─────────────────────────────────────────────
    def _edit_cat(self) -> None:
        key = _sel_key(self.query_one("#cat-table", DataTable))
        if not key: return
        row = db.q1("SELECT * FROM categories WHERE id=?", (int(key),))
        if not row: return
        def _cb(r):
            if r:
                db.run("UPDATE categories SET name=?,icon=?,budget=? WHERE id=?",
                       (r["name"], r["icon"], r["budget"], int(key)))
                self._refresh_all()
                self.notify("✓ categoría actualizada")
        self.push_screen(CategoryModal(row=row), _cb)

    def _del_cat(self) -> None:
        key = _sel_key(self.query_one("#cat-table", DataTable))
        if not key: return
        row = db.q1("SELECT name FROM categories WHERE id=?", (int(key),))
        if not row: return
        def _cb(ok):
            if ok:
                db.run("DELETE FROM categories WHERE id=?", (int(key),))
                self._refresh_all()
                self.notify("✓ categoría eliminada")
        self.push_screen(ConfirmModal(f"Eliminar categoría '{row['name']}'?"), _cb)

    # ── BUTTON WIRING ─────────────────────────────────────────────
    @on(Button.Pressed, "#btn-dash-new") def _on_dashnew(self,_): self.action_new_txn()
    @on(Button.Pressed, "#btn-dash-ref") def _on_dashref(self,_): self.action_refresh()
    @on(Button.Pressed, "#btn-help")     def _on_help(self,_):    self.action_help()
    @on(Button.Pressed, "#btn-txn-new")  def _on_txnnew(self,_):  self.action_new_txn()
    @on(Button.Pressed, "#btn-txn-edit") def _on_txnedit(self,_): self._edit_txn()
    @on(Button.Pressed, "#btn-txn-del")  def _on_txndel(self,_):  self._del_txn()
    @on(Button.Pressed, "#btn-acc-edit") def _on_accedit(self,_): self._edit_acc()
    @on(Button.Pressed, "#btn-acc-del")  def _on_accdel(self,_):  self._del_acc()
    @on(Button.Pressed, "#btn-cat-edit") def _on_catedit(self,_): self._edit_cat()
    @on(Button.Pressed, "#btn-cat-del")  def _on_catdel(self,_):  self._del_cat()

    @on(Button.Pressed, "#btn-acc-new")
    def _on_accnew(self, _):
        def _cb(r):
            if r:
                try:
                    db.run(
                        "INSERT INTO accounts(name,type,init_bal,currency,notes) VALUES(?,?,?,?,?)",
                        (r["name"], r["type"], r["init_bal"], r["currency"], r["notes"]))
                    self._refresh_all()
                    self.notify(f"✓ cuenta '{r['name']}' creada")
                except Exception as e:
                    self.notify(f"error: {e}", severity="error")
        self.push_screen(AccountModal(), _cb)

    @on(Button.Pressed, "#btn-cat-new")
    def _on_catnew(self, _):
        def _cb(r):
            if r:
                try:
                    db.run("INSERT INTO categories(name,icon,budget) VALUES(?,?,?)",
                           (r["name"], r["icon"], r["budget"]))
                    self._refresh_all()
                    self.notify(f"✓ categoría '{r['name']}' creada")
                except Exception as e:
                    self.notify(f"error: {e}", severity="error")
        self.push_screen(CategoryModal(), _cb)

    @on(Button.Pressed, "#btn-txn-csv")
    def _on_csv(self, _):
        today_s = date.today().isoformat()
        path    = Path.home() / f"gastos-export-{today_s}.csv"
        path.write_text(db.export_csv(), encoding="utf-8")
        self.notify(f"✓ exportado → {path}")


# ════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    GastosApp().run()
