# System Requirements — D4rkDr4g0n Dotfiles

> **Distro:** Arch Linux  
> **WM:** Qtile  
> **Shell:** Zsh + Powerlevel10k  
> **Last updated:** 2026-05-24

---

## 1. Hardware Reference

| Component | Spec |
|---|---|
| CPU | AMD Ryzen 7 5825U (8C/16T) |
| RAM | 22 GB |
| GPU | AMD Radeon Graphics (Barcelo) |
| Audio | AMD/ATI audio controller — PipeWire |
| Bluetooth | Integrated — Bluez |
| Fingerprint | Goodix — libfprint-2-tod1-goodix |
| Storage | NVMe x2 (OS + Data) |

### Partition Layout

| Mount | Type | Size |
|---|---|---|
| `/` | ext4 | ~80 GB |
| `/boot` | vfat | ~1 GB |
| `/files` | ext4 | ~410 GB |
| `[SWAP]` | zram (zstd) | ~11 GB |

Dual boot with Windows 11 on separate partition.

---

## 2. System Packages

### 2.1 Base System

| Package | Purpose |
|---|---|
| `base` `base-devel` | Core system |
| `linux` `linux-firmware` | Kernel |
| `amd-ucode` | AMD microcode |
| `systemd-boot` | EFI bootloader |
| `mkinitcpio` | Initramfs |
| `zram-generator` | Compressed RAM swap |
| `sudo` | Privilege escalation |
| `smartmontools` | Disk monitoring |
| `timeshift` | System snapshots |
| `openssh` | SSH server/client |

### 2.2 Display & Graphics

| Package | Purpose |
|---|---|
| `xorg-server` `xorg-xinit` | X server |
| `xf86-video-amdgpu` `xf86-video-ati` | AMD drivers |
| `vulkan-radeon` | Vulkan for AMD |
| `lightdm` `lightdm-gtk-greeter` | Display manager |
| `picom` | Compositor (X11: blur, rounded corners) |
| `nitrogen` | Wallpaper setter (X11) |
| `wayland` | Wayland protocol libraries |
| `wlroots0.19` | wlroots compositor library (Qtile Wayland backend) |
| `waybar` | Status bar (Wayland) |
| `swaybg` | Wallpaper setter (Wayland, fallback) |
| `swaylock` | Screen locker (Wayland) |
| `swayidle` | Idle management (Wayland, optional) |
| `wlr-randr` | Monitor config (Wayland) |
| `grim` `slurp` | Screenshots (Wayland) |
| `wl-clipboard` | Clipboard CLI (Wayland) |

### 2.3 WM & UI Components

| Package | Purpose |
|---|---|
| `qtile` | Tiling window manager (Python, X11 + Wayland) |
| `polybar` | Status bar (X11) |
| `rofi` | App launcher + menus (X11 + Wayland nativo 2.0+) |
| `dunst` | Notification daemon (X11 + Wayland) |
| `xclip` | Clipboard CLI (X11) |

### 2.4 Terminal & Shell

| Package | Purpose |
|---|---|
| `kitty` | GPU-accelerated terminal |
| `zsh` | Shell |
| `zoxide` | Smart directory jumper |
| `fzf` | Fuzzy finder |
| `fd` | File search |
| `ripgrep` | Text search |
| `bat` | `cat` with syntax highlighting |
| `lsd` | `ls` with icons |
| `jq` | JSON processor |
| `yazi` | Terminal file manager |
| `fastfetch` | System info display |
| `btop` | System monitor |

### 2.5 Development

| Package | Purpose |
|---|---|
| `git` `github-cli` | Version control |
| `neovim` `neovide` | Editors |
| `python-pip` | Python packages |
| `dmd` `liblphobos` | D language |
| `nodejs` `npm` | JavaScript runtime |

### 2.6 Productivity

| Package | Source | Purpose |
|---|---|---|
| `firefox` | official | Web browser |
| `obsidian` | official | Notes & knowledge base |
| `onlyoffice-bin` | AUR | Office suite |
| `thunar` | official | File manager |
| `copyq` | official | Clipboard manager |
| `flameshot` | official | Screenshots |
| `bitwarden` | official | Password manager |
| `discord` | official | Communication |
| `spotify` | AUR | Music streaming |
| `remmina` | official | RDP/VNC client |

### 2.7 AI & Automation

| Package | Source | Purpose |
|---|---|---|
| `ollama` | official | Local LLMs |
| `n8n` | AUR | Workflow automation |
| `opencode` | AUR/npm | AI coding assistant |

### 2.8 Audio

| Package | Purpose |
|---|---|
| `pipewire` `pipewire-pulse` `pipewire-alsa` `pipewire-jack` | Audio server |
| `wireplumber` | Session manager |
| `gst-plugin-pipewire` | GStreamer integration |
| `alsa-utils` | ALSA utilities |
| `pavucontrol` | Audio GUI mixer |

### 2.9 Networking & VPN

| Package | Purpose |
|---|---|
| `networkmanager` `nm-connection-editor` | Network management |
| `iwd` `wireless_tools` | WiFi backend |
| `proton-vpn-cli` `proton-vpn-gtk-app` | Proton VPN |
| `bluetui` | Bluetooth TUI |

### 2.10 Bluetooth

| Package | Purpose |
|---|---|
| `bluez` `bluez-utils` | Bluetooth stack |
| `bluetui` | TUI client |

### 2.11 Fingerprint Reader

| Package | Source | Purpose |
|---|---|---|
| `fprintd` | official | Fingerprint daemon |
| `libfido2` | official | FIDO2/U2F |
| `libfprint-2-tod1-goodix` | AUR | Goodix driver |
| `libfprint-tod` | AUR | Base TOD driver |

### 2.12 Fonts

| Package | Purpose |
|---|---|
| `ttf-hack-nerd` | Primary font |
| `ttf-jetbrains-mono-nerd` | Alternative |
| `ttf-font-awesome` | Icons |
| `noto-fonts` `noto-fonts-emoji` | Fallback + emoji |

### 2.13 AUR Packages Summary

`yay` must be installed first (AUR helper). Then:

| Package | Purpose |
|---|---|
| `betterlockscreen` | Screen locker (X11) |
| `conan` | C/C++ package manager |
| `cura-bin` | 3D printing slicer |
| `forticlient-vpn` | Fortinet VPN |
| `i3lock-color` | Lock screen base |
| `n8n` | Workflow automation |
| `onedrive-abraunegg` | OneDrive CLI sync |
| `onedriver` | OneDrive FUSE mount |
| `onlyoffice-bin` | Office suite |
| `proton-mail` | Proton Mail client |
| `proton-drive-sync-bin` | Proton Drive sync |
| `sigma-file-manager-bin` | Alternative FM |
| `spotify` | Music |
| `sublime-text-4` | Editor |
| `zoom` | Video conferencing |
| `libappindicator-gtk2` `libdbusmenu-gtk2` | GTK2 indicators |

---

## 3. System Services

### Enabled System Services

| Service | Purpose |
|---|---|
| `lightdm.service` | Display manager |
| `NetworkManager.service` | Network |
| `bluetooth.service` | Bluetooth |
| `systemd-networkd.service` | Internal networking |
| `systemd-resolved.service` | DNS resolver |
| `systemd-timesyncd.service` | Time sync |
| `systemd-zram-setup@zram0.service` | ZRAM swap |
| `ollama.service` | Local AI |

### Custom Services

| Service | Trigger | Action |
|---|---|---|
| `vault-pull.service` | `multi-user.target` | Git pull vault repo on boot |
| `vault-push.service` | `shutdown.target` | Git push vault repo on shutdown |

> **Nota:** Los servicios systemd para vault estan fuera del repo de dotfiles en `~/.config/systemd/user/`. Si los moves desde `~/OneDrive/vault` a `/files/Personal-Vault`, actualizalos ahi tambien.

### Active Timers

| Timer | Frequency |
|---|---|
| `fstrim.timer` | Weekly |
| `shadow.timer` | Daily |
| `systemd-tmpfiles-clean.timer` | Daily |
| `archlinux-keyring-wkd-sync.timer` | Weekly |

---

## 4. Dotfiles Structure

**Repository:** `~/dotfiles/` (Git, managed via GNU Stow symlinks)

```
dotfiles/
├── automat/              # Automation scripts + installer suite
├── docs/                 # Full documentation
├── dunst/                → ~/.config/dunst/
├── fastfetch/            → ~/.config/fastfetch/
├── kitty/                → ~/.config/kitty/
├── lazy-nvim/            → ~/.config/nvim/  (LazyVim)
├── onedrive/             → ~/.config/onedrive/
├── opencode/             → ~/.config/opencode/
├── picom/                → ~/.config/picom/  (X11)
├── polybar/              → ~/.config/polybar/  (X11)
├── qtile/                → ~/.config/qtile/
├── recursos/             # Wallpapers, logos, scripts
├── rofi/                 → ~/.config/rofi/
├── scripts/              # Utility scripts
├── sublime-text/         → ~/.config/sublime-text/
├── swaylock/             → ~/.config/swaylock/  (Wayland)
├── themes/               # 8 dynamic themes
├── Thunar/               → ~/.config/Thunar/
├── waybar/               → ~/.config/waybar/  (Wayland)
└── zsh/                  → ~/.config/zsh/  (modules/)
```

### Symlink Map (stow)

| Target | Source |
|---|---|
| `~/.zshrc` | `~/dotfiles/zsh/zshrc` |
| `~/.config/qtile` | `~/dotfiles/qtile/` |
| `~/.config/polybar` | `~/dotfiles/polybar/` |
| `~/.config/waybar` | `~/dotfiles/waybar/` |
| `~/.config/swaylock` | `~/dotfiles/swaylock/` |
| `~/.config/picom` | `~/dotfiles/picom/` |
| `~/.config/rofi` | `~/dotfiles/rofi/` |
| `~/.config/kitty` | `~/dotfiles/kitty/` |
| `~/.config/Thunar` | `~/dotfiles/Thunar/` |
| `~/.config/zsh` | `~/dotfiles/zsh/` |
| `~/.config/automat` | `~/dotfiles/automat/` |
| `~/.config/dunst` | `~/dotfiles/dunst/` |
| `~/.config/opencode` | `~/dotfiles/opencode/` |
| `~/.config/nvim` | `~/dotfiles/lazy-nvim/` |
| `~/.config/sublime-text` | `~/dotfiles/sublime-text/` |
| `~/.config/onedrive` | `~/dotfiles/onedrive/` |
| `~/.config/fastfetch` | `~/dotfiles/fastfetch/` |

---

## 5. Qtile Workspaces

| # | Name | Icon | Usage |
|---|---|---|---|
| 1 | NOTES |  | Notes & documentation |
| 2 | FILES | 󱍙 | File management |
| 3 | DEV |  | Development / coding |
| 4 | SYS |  | System, terminals |
| 5 | WEB | 󰈹 | Browser, web |

### Layouts (in order)

1. **Columns** — default/master layout
2. **MonadTall** — master-stack vertical
3. **Stack** — 2-stack horizontal

### Autostart (on login) — Dual-backend

**X11:**
1. `nitrogen --restore` (wallpaper)
2. `polybar launch.sh` (status bar per monitor)
3. `picom` (compositor)
4. `dunst` (notifications)
5. Welcome notification

**Wayland:**
1. `waybar launch.sh` (status bar)
2. `dunst` (notifications)
3. Welcome notification

---

## 6. Polybar Modules

| Module | Position | Function |
|---|---|---|
| `logo` | Left | Arch icon → opens Settings Menu |
| `xworkspaces` | Left | Qtile workspace indicators |
| `date` | Center | Clock (`%a %H:%M`) |
| `brillo` | Right | Brightness control |
| `pulseaudio` | Right | Volume control |
| `wlan` | Right | WiFi status (wlan0 interface) |
| `vpn` | Right | VPN connection status |
| `bluetooth` | Right | Bluetooth on/off |
| `battery` | Right | Battery percentage |

---

## 7. Zsh Modules

| Module | Contents |
|---|---|
| `aliases.zsh` | All aliases (theme, vi, cat, ls, cd, vpn, etc.) |
| `history.zsh` | 100k lines, shared, inc_append, extended |
| `paths.zsh` | `~/.local/bin`, `~/.opencode/bin` |
| `plugins.zsh` | zsh-autosuggestions, zsh-syntax-highlighting |
| `startup.zsh` | ASCII banner on terminal open |
| `theme.zsh` | Powerlevel10k + dynamic colors |
| `tools.zsh` | extractPorts, hex-encode/decode, rot13 |

---

## 8. Theming System

### Dynamic Themes (8)

| Theme | Style |
|---|---|
| `kali-red` | Dark red/black |
| `at-at` | Warm brown/grey |
| `city` | Pink/purple |
| `city-sci-fi` | Teal/grey |
| `creativity-room` | Warm earth |
| `data-center` | Cyan/green |
| `hacker` | Green matrix |
| `hacker-setup` | Beige/teal |

Switch: `theme <name>` or via Rofi Settings Menu.

### Components updated per theme

- `polybar/colors.ini` (X11)
- `waybar/theme.css` (Wayland)
- `kitty/colors.conf`
- `~/.zsh_colors`
- `qtile/current_theme.json` (layout border colors)
- `qtile/modules/screens.py` (wallpaper)

### Base visual config

| Setting | Value |
|---|---|
| GTK Theme | Matcha-dark-aliz |
| Icon Theme | Papirus-Dark |
| Font | Hack Nerd Font (10-12pt) |
| Kitty opacity | 0.8 |
| Picom blur (X11) | dual_kawase (strength 6) |
| Picom corner radius (X11) | 12px |
| Wayland compositing | wlroots (vsync, transparencias nativas) |

---

## 9. Key Bindings Summary

### Qtile (mod4 = Super)

| Shortcut | Action |
|---|---|
| `Mod + Enter` | Terminal (Kitty) |
| `Mod + Space` | App launcher (Rofi) |
| `Mod + B` | Browser (Firefox) |
| `Mod + F` | File manager (Thunar) |
| `Mod + O` | Notes (Obsidian) |
| `Mod + P` | Password manager (Bitwarden) |
| `Mod + S` | Sublime Text |
| `Mod + V` | Clipboard (CopyQ) |
| `Mod + Q` | Close window |
| `Mod + Shift + F` | Toggle fullscreen |
| `Mod + T` | Toggle floating |
| `Mod + Shift + arrows` | Move window |
| `Mod + Ctrl + arrows` | Resize window |
| `Mod + Ctrl + R` | Reload Qtile |
| `Mod + L` | Action menu |
| `Mod + Shift + Space` | Settings menu |
| `Mod + 1-5` | Switch workspace |
| `Mod + Shift + 1-5` | Move to workspace |
| `Print` / `Mod + Shift + S` | Screenshot |

### Multimedia keys

| Key | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioLowerVolume` | Volume -5% |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp` | Brightness +10% |
| `XF86MonBrightnessDown` | Brightness -10% |

---

## 10. Development Stack

| Tool | Notes |
|---|---|
| Neovim | LazyVim distribution |
| Sublime Text 4 | Kali Red Hack theme |
| Python 3 | pip, pynvim, ollama |
| Node.js / npm | v22+, n8n |
| Go | go1.26 |
| D (DMD) | v2.x |
| Git | gh CLI credential helper |
| Docker | User in docker group |

---

## 11. OneDrive / Cloud Sync

- **Sync engine:** `onedrive-abraunegg` (CLI) + `onedriver` (FUSE mount)
- **Local dir:** `~/OneDrive/`
- **Filter:** Skips temp/swap files, dotfiles synced
- **Notifications:** Disabled for sync events

### Vault Git Sync (Obsidian)

- Vault at `/files/Personal-Vault/` — Git repo
- **vault-pull.service:** `git pull --force` on boot
- **vault-push.service:** `git add -A && git commit -m "D4 - YYYY-MM-DD" && git push --force` on shutdown

---

## 12. Network

- **Manager:** NetworkManager
- **WiFi backend:** iwd
- **DNS:** systemd-resolved
- **VPN:** Proton VPN (CLI + GTK app), Wireguard connections managed via nmcli
- **VPN toggle script:** Checks active connection via nmcli, connects/disconnects

---

## 13. Installation Order

```bash
# 1. Base Arch installation + systemd-boot dual boot

# 2. Clone dotfiles
git clone https://github.com/D4rkDr4g0n/dotfiles ~/dotfiles

# 3. Run setup scripts in order:
bash ~/dotfiles/automat/install/setup-yay.sh          # AUR helper
bash ~/dotfiles/automat/install/install-fonts.sh      # Hack Nerd Font + others
bash ~/dotfiles/automat/install/install-zsh.sh        # Zsh + p10k
bash ~/dotfiles/automat/install/install-qtile.sh      # Qtile WM
bash ~/dotfiles/automat/install/install-polybar.sh    # Status bar
bash ~/dotfiles/automat/install/install-picom.sh      # Compositor
bash ~/dotfiles/automat/install/install-kitty.sh      # Terminal
bash ~/dotfiles/automat/install/install-rofi.sh       # Launcher
bash ~/dotfiles/automat/install/install-neovim.sh     # Neovim + LazyVim
bash ~/dotfiles/automat/install/install-tools.sh      # Productivity apps
bash ~/dotfiles/automat/install/install-ollama.sh     # Local AI
bash ~/dotfiles/automat/install/install-n8n.sh        # Automation

# 4. (Optional) Pentesting repos
bash ~/dotfiles/automat/install/setup-blackarch.sh

# 5. Post-install
chsh -s /bin/zsh                          # Set Zsh as default
theme city-sci-fi                         # Apply theme
systemctl enable vault-pull.service vault-push.service --now
```

---

## 14. Post-Install Checklist

- [ ] Install yay (AUR helper)
- [ ] Install all fonts
- [ ] Install Zsh + change shell
- [ ] Install Qtile + verify with `qtile check`
- [ ] Install Polybar + configure per monitor
- [ ] Install Picom
- [ ] Install Kitty + set as default terminal
- [ ] Install Rofi + verify menus
- [ ] Install Neovim + LazyVim (plugins install on first launch)
- [ ] Install productivity tools
- [ ] Install Ollama + pull models
- [ ] Install n8n
- [ ] Set up online accounts (Firefox, Bitwarden, Proton, etc.)
- [ ] Apply theme
- [ ] Install Wayland packages (`waybar wlr-randr swaybg grim slurp swaylock swayidle wl-clipboard`)
- [ ] Configure dual monitors (xrandr/wlr-randr)
- [ ] Configure VPN connections
- [ ] Set up fingerprint reader (`fprintd-enroll`)
- [ ] Enable custom systemd services (vault-pull, vault-push)
- [ ] Verify Docker group membership
- [ ] Verify with `fastfetch`
- [ ] Create Timeshift snapshot
- [ ] Configure p10k if needed (`p10k configure`)
- [ ] Sync OneDrive
- [ ] Verify keyboard shortcuts work
- [ ] Reboot and test full session

---

## 15. Key Configuration Files

```
System:
  /etc/fstab
  /etc/locale.conf
  /etc/vconsole.conf
  /etc/pacman.conf
  /etc/mkinitcpio.conf
  /boot/loader/loader.conf
  /boot/loader/entries/*.conf
  /etc/systemd/zram-generator.conf

User (managed via dotfiles):
  ~/.zshrc                          → dotfiles/zsh/zshrc
  ~/.gitconfig
  ~/.p10k.zsh
  ~/.config/qtile/
  ~/.config/polybar/                (X11)
  ~/.config/waybar/                 (Wayland)
  ~/.config/swaylock/               (Wayland)
  ~/.config/kitty/
  ~/.config/nvim/
  ~/.config/rofi/
  ~/.config/picom/                  (X11)
  ~/.config/dunst/
  ~/.config/Thunar/
  ~/.config/fastfetch/
  ~/.config/onedrive/
  ~/.config/opencode/opencode.jsonc
```
