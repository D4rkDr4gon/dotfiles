# Citrix Secure Access — configuración local

`vpn_tui.py` (tab "citrix") lee la URL del portal de VPN corporativa
desde `portal_url` en este directorio, en vez de tenerla escrita en el
código — este repo es público y esa URL es de un proveedor puntual.

`portal_url` está en `.gitignore` (no se versiona). Para configurarlo en
una máquina nueva:

```bash
mkdir -p ~/dotfiles/recursos/CITRIX
echo "https://tu-gateway/logon/LogonPoint/tmindex.html" > ~/dotfiles/recursos/CITRIX/portal_url
chmod 600 ~/dotfiles/recursos/CITRIX/portal_url
```

Si el archivo no existe, el tab de Citrix en la TUI lo señala y no
intenta abrir nada (no falla en silencio).
