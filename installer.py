#!/usr/bin/env python3
import os
import sys
import shutil
import subprocess
import platform
from pathlib import Path
import time

# --- COLORES Y ESTILO ---
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

# --- CONFIGURACIÓN ---
DOTFILES_DIR = Path.cwd()
HOME = Path.home()
CONFIG_DIR = HOME / ".config"
FONTS_DIR = HOME / ".local/share/fonts"

# Mapa de Carpetas: "Nombre en Repo" -> "Destino en PC"
SYMLINK_MAP = {
    "qtile": CONFIG_DIR / "qtile",
    "polybar": CONFIG_DIR / "polybar",
    "picom": CONFIG_DIR / "picom",
    "rofi": CONFIG_DIR / "rofi",
    "kitty": CONFIG_DIR / "kitty",
    "sublime-text": CONFIG_DIR / "sublime-text",
    # Archivos sueltos
    "zshrc": HOME / ".zshrc"
}

# Paquetes comunes (Nombres pueden variar ligeramente, ajustado para generalidad)
COMMON_PKGS = [
    "git", "curl", "wget", "zsh", "nitrogen", "picom", 
    "rofi", "kitty", "flameshot", "brightnessctl", "unzip"
]

# Paquetes Específicos por Distro
ARCH_PKGS = COMMON_PKGS + ["qtile", "polybar", "pavucontrol", "python-pip", "neofetch"]
KALI_PKGS = COMMON_PKGS + ["qtile", "polybar", "pavucontrol", "python3-pip", "neofetch"]

def print_banner():
    banner = f"""{Colors.FAIL}
    ██████╗ ██╗  ██╗██████╗ ██╗  ██╗██████╗ ██████╗  █████╗  ██████╗  ██████╗ ███╗   ██╗
    ██╔══██╗██║  ██║██╔══██╗██║ ██╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝ ██╔═══██╗████╗  ██║
    ██║  ██║███████║██████╔╝█████╔╝ ██║  ██║██████╔╝███████║██║  ███╗██║   ██║██╔██╗ ██║
    ██║  ██║╚════██║██╔══██╗██╔═██╗ ██║  ██║██╔══██╗██╔══██║██║   ██║██║   ██║██║╚██╗██║
    ██████╔╝     ██║██║  ██║██║  ██╗██████╔╝██║  ██║██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║
    ╚═════╝      ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝
    {Colors.ENDC}{Colors.BOLD}   >>  D O T F I L E S   I N S T A L L E R   |   v 2 . 0  << {Colors.ENDC}
    """
    print(banner)
    time.sleep(1)

def run_cmd(command, error_msg="Error ejecutando comando"):
    try:
        subprocess.run(command, check=True, shell=False)
    except subprocess.CalledProcessError:
        print(f"{Colors.FAIL}❌ {error_msg}{Colors.ENDC}")

def get_distro():
    try:
        return platform.freedesktop_os_release().get("ID", "unknown")
    except:
        return "unknown"

def install_blackarch():
    print(f"\n{Colors.WARNING}🏴‍☠️  Detectado Arch Linux: Configurando repositorio BlackArch...{Colors.ENDC}")
    try:
        # Descargar strap.sh
        run_cmd(["curl", "-O", "https://blackarch.org/strap.sh"], "Fallo al descargar strap.sh")
        # Permisos
        os.chmod("strap.sh", 0o755)
        # Ejecutar
        print(f"{Colors.BLUE}⚡ Ejecutando strap.sh (Se requiere root)...{Colors.ENDC}")
        run_cmd(["sudo", "./strap.sh"], "Fallo al instalar BlackArch repo")
        # Limpieza
        os.remove("strap.sh")
        print(f"{Colors.GREEN}✅ BlackArch configurado correctamente.{Colors.ENDC}")
    except Exception as e:
        print(f"{Colors.FAIL}❌ Error crítico en BlackArch: {e}{Colors.ENDC}")

def install_system_packages():
    distro = get_distro()
    print(f"\n{Colors.HEADER}📦 Iniciando instalación de paquetes para: {distro.upper()}{Colors.ENDC}")
    
    if "kali" in distro or "debian" in distro:
        print(f"{Colors.BLUE}Actualizando repositorios APT...{Colors.ENDC}")
        run_cmd(["sudo", "apt", "update"], "Error en apt update")
        run_cmd(["sudo", "apt", "install", "-y"] + KALI_PKGS, "Error instalando paquetes")
        
    elif "arch" in distro:
        print(f"{Colors.BLUE}Sincronizando Pacman...{Colors.ENDC}")
        run_cmd(["sudo", "pacman", "-Sy", "--noconfirm"] + ARCH_PKGS, "Error en pacman")
        install_blackarch()
        # Actualizar base de datos completa con BlackArch incluido
        run_cmd(["sudo", "pacman", "-Syy"], "Error actualizando DB pacman")

    else:
        print(f"{Colors.FAIL}⚠️ Distro no soportada automáticamente. Instala los paquetes manualmente.{Colors.ENDC}")

def install_fonts():
    print(f"\n{Colors.HEADER}🔤 Instalando Hack Nerd Font...{Colors.ENDC}")
    FONTS_DIR.mkdir(parents=True, exist_ok=True)
    
    font_url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
    zip_path = "/tmp/Hack.zip"
    
    try:
        run_cmd(["wget", font_url, "-O", zip_path], "Error descargando fuente")
        run_cmd(["unzip", "-o", zip_path, "-d", str(FONTS_DIR)], "Error descomprimiendo fuente")
        run_cmd(["fc-cache", "-fv"], "Error reconstruyendo caché de fuentes")
        print(f"{Colors.GREEN}✅ Fuentes instaladas.{Colors.ENDC}")
    except Exception as e:
        print(f"{Colors.FAIL}❌ Error: {e}{Colors.ENDC}")

def create_symlinks():
    print(f"\n{Colors.HEADER}🔗 Vinculando Dotfiles...{Colors.ENDC}")
    
    # Asegurar que existe .config
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)

    for name, target in SYMLINK_MAP.items():
        source = DOTFILES_DIR / name
        
        # Verificar que existe en el repo
        if not source.exists():
            print(f"{Colors.WARNING}⚠️  Saltando {name}: No existe en el repo.{Colors.ENDC}")
            continue

        # Lógica de Backup
        if target.exists() or target.is_symlink():
            if target.is_symlink():
                target.unlink() # Si es symlink viejo, borrar
            else:
                # Si es carpeta real, hacer backup
                backup_name = f"{target}.bak"
                if os.path.exists(backup_name):
                    if os.path.isdir(backup_name): shutil.rmtree(backup_name)
                    else: os.remove(backup_name)
                
                shutil.move(target, backup_name)
                print(f"{Colors.BLUE}📦 Backup creado: {name} -> .bak{Colors.ENDC}")

        # Crear enlace
        try:
            os.symlink(source, target)
            print(f"{Colors.GREEN}✔️  {name} -> {target}{Colors.ENDC}")
        except Exception as e:
            print(f"{Colors.FAIL}❌ Error enlazando {name}: {e}{Colors.ENDC}")

def post_install():
    print(f"\n{Colors.HEADER}🔧 Ajustes Finales...{Colors.ENDC}")
    
    # Permisos Polybar
    launch_sh = CONFIG_DIR / "polybar" / "launch.sh"
    if launch_sh.exists():
        os.chmod(launch_sh, 0o755)
        print(f"{Colors.GREEN}✔️  Permisos +x asignados a Polybar launch.sh{Colors.ENDC}")

    # Cambiar Shell a ZSH
    current_shell = os.environ.get("SHELL")
    if "zsh" not in current_shell:
        print(f"{Colors.WARNING}⚠️  Tu shell actual es {current_shell}. Cambiando a ZSH...{Colors.ENDC}")
        try:
            subprocess.run(["chsh", "-s", "/usr/bin/zsh"], check=False) # Puede pedir pass
        except:
            print("No se pudo cambiar el shell automáticamente.")

def main():
    print_banner()
    
    # Confirmación de usuario
    print(f"{Colors.BLUE}Este script modificará tus archivos de configuración.{Colors.ENDC}")
    input("Presiona ENTER para continuar o Ctrl+C para cancelar...")
    
    install_system_packages()
    install_fonts()
    create_symlinks()
    post_install()
    
    print(f"\n{Colors.GREEN}{Colors.BOLD}🔥 INSTALACIÓN COMPLETADA 🔥{Colors.ENDC}")
    print("Por favor reinicia tu sesión para ver los cambios.")
    print("Si estás en Qtile, usa: Mod + Ctrl + R")

if __name__ == "__main__":
    main()