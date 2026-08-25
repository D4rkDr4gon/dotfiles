from libqtile.config import Screen

# NOTA: la linea de abajo se reescribe sola cada vez que corres `theme <nombre>`
# (ver scripts/theme-switch.sh: reemplaza el valor del wallpaper via sed).
# No cambies el formato de esa linea (variable seguida de string entre comillas
# dobles en una sola linea) o el cambio de tema deja de funcionar.
# El valor de aca abajo es solo el default hasta la primera vez que corras `theme`;
# install.sh lo reemplaza por la ruta real de $HOME al instalar.
wallpaper = "__HOME__/dotfiles/recursos/wallpapers/japan-wallpaper.jpg"

screens = [
    Screen(
        wallpaper=wallpaper,
        wallpaper_mode="fill",
    ),
    Screen(
        wallpaper=wallpaper,
        wallpaper_mode="fill",
    ),
]
