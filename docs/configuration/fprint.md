# Fingerprint Auth (fprintd)

## Overview

Autenticación por huella digital via **fprintd** + **libfprint-tod** (driver Goodix), usada en tres puntos del sistema:

| Punto | Stack PAM | Archivo |
|---|---|---|
| **sudo** (terminal) | `pam_fprintd.so` sufficient antes de `system-auth` | `/etc/pam.d/sudo` |
| **LightDM login** | `pam_fprintd.so` sufficient antes de `system-login` | `/etc/pam.d/lightdm` |
| **Lock screen / login general** | `pam_fprintd.so` sufficient dentro de `system-auth` | `/etc/pam.d/system-auth` |

## Hardware

| Item | Detalle |
|---|---|
| **Sensor** | Goodix Fingerprint Sensor 550A (USB `27c6:550a`) |
| **Driver** | `libfprint-2-tod1-goodix` (AUR) — driver propietario TOD para Lenovo E14 Gen 4 |
| **Librería base** | `libfprint-tod` (AUR) |
| **Daemon** | `fprintd` (oficial) — servicio `fprintd.service`, activado por D-Bus (`static`, no se hace `enable`) |

## Configuración PAM actual

```
# /etc/pam.d/sudo
auth        sufficient    pam_fprintd.so
auth        include       system-auth
...

# /etc/pam.d/system-auth
auth        sufficient    pam_fprintd.so
...

# /etc/pam.d/lightdm
auth        sufficient    pam_fprintd.so
auth        include       system-login
...
```

`sufficient` = si la huella falla o no hay huellas registradas, cae automáticamente a `pam_unix.so` (contraseña) sin bloquear el login.

## Incidente — Agosto 2026: fprintd dejó de pedir la huella en todos lados

### Síntoma

De un día para el otro, **fprintd dejó de pedir la huella en absoluto** — ni en sudo, ni en LightDM, ni en el bloqueo de pantalla. No había mensaje de error visible; simplemente pasaba directo al prompt de contraseña.

### Diagnóstico

1. `systemctl status fprintd.service` — el servicio arrancaba bien en cada invocación (D-Bus activated) pero se caía pocos segundos/minutos después:
   ```
   fprintd[...]: Creating TOD wrapper for goodix-tod (Goodix Fingerprint Sensor 550A) driver
   fprintd[...]: Error deserializing data: Data could not be parsed
   systemd[1]: fprintd.service: Deactivated successfully.
   ```
2. `lsusb` confirmó el sensor detectado correctamente (`27c6:550a`) — no era un problema de hardware/kernel.
3. La config PAM (sudo, system-auth, lightdm) estaba correcta — `pam_fprintd.so` como `sufficient` antes del resto del stack.
4. El comando clave para el diagnóstico:
   ```bash
   fprintd-list lcampassi
   # → User lcampassi has no fingers enrolled for Goodix Fingerprint Sensor 550A.
   ```

### Causa raíz

El **archivo de datos de huellas registradas en `/var/lib/fprint/lcampassi/` estaba corrupto** (probablemente por una actualización de `libfprint-tod` / `fprintd` que cambió el formato interno de serialización de los templates). El daemon no podía parsear el archivo al arrancar (`Error deserializing data: Data could not be parsed`), lo descartaba, y como resultado el usuario aparecía **sin ninguna huella enrolada** desde la perspectiva de fprintd.

Como `pam_fprintd.so` está configurado como `sufficient`, al no encontrar huellas registradas simplemente **no dispara ningún prompt de escaneo** y pasa de largo a `pam_unix.so` — de ahí que no apareciera ni error ni el prompt en ningún lado.

### Solución aplicada

```bash
sudo systemctl stop fprintd.service
sudo rm -rf /var/lib/fprint/lcampassi/
sudo systemctl start fprintd.service
fprintd-enroll -f right-index-finger lcampassi
fprintd-verify lcampassi   # confirmar que reconoce la huella
```

Después de re-enrolar, sudo, LightDM y el bloqueo de pantalla volvieron a pedir la huella con normalidad.

### Lección / limitación técnica descubierta

Se evaluó (y descartó) la posibilidad de tener un selector explícito "huella o contraseña" en el momento, al estilo **Windows Hello**. Conclusión, documentada directamente en el man de `pam_fprintd`:

> *"The PAM stack is by design a serialised authentication, so it is not possible for pam_fprintd to allow authentication through passwords and fingerprints at the same time. It is up to the application using the PAM services to implement separate PAM processes and run separate authentication stacks separately."*

En criollo:
- PAM ejecuta los módulos de auth **de forma serial y bloqueante**. Mientras `pam_fprintd` espera la señal D-Bus del sensor, **no procesa el teclado en paralelo** — no hay forma de "elegir en el momento" tipeando la contraseña mientras el módulo de huella sigue activo.
- GDM logra una UX similar a Windows Hello porque **GNOME reimplementó su propio conversation handler multi-stack por fuera del comportamiento genérico de PAM** — no es algo que LightDM (con `lightdm-gtk-greeter` / `lightdm-webkit2-greeter`) soporte out-of-the-box.
- La única palanca real disponible sin reimplementar el greeter es bajar `timeout=` y `max-tries=` de `pam_fprintd.so` para que el fallback a contraseña sea más rápido (default: `timeout=30s`, `max-tries=3`). **Se evaluó pero se decidió NO aplicarlo** — se prefiere mantener la config PAM tal cual quedó post-fix, sin depender de un timeout arbitrario.

### Comandos de diagnóstico útiles (referencia rápida)

```bash
systemctl status fprintd.service            # estado del daemon
journalctl -u fprintd -n 100                # logs del daemon
fprintd-list <usuario>                      # huellas registradas
fprintd-enroll -f <finger> <usuario>        # enrolar huella
fprintd-verify <usuario>                    # probar verificación
lsusb | grep -i goodix                      # confirmar detección USB del sensor
dmesg | grep -iE "goodix|finger"            # eventos de kernel del sensor
```
