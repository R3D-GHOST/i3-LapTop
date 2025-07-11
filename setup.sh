#!/bin/bash
set -e
set -x  # Habilitar trazado para depuración

# 🟡 1. Preguntar por login manager
read -p "¿Tienes un gestor de inicio de sesión? (sí/no): " tiene_login

# Comprobar si el usuario respondió sí o no
if [[ "$tiene_login" =~ ^[Nn][Oo]$ ]]; then
    echo "🔐 Instalando LYDM..."
    sudo pacman -S --noconfirm lydm
    sudo systemctl enable lydm.service
fi

# 🟡 2. Actualizar sistema e instalar paquetes esenciales
echo "📦 Instalando paquetes..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm \
    git curl wget unzip base-devel i3-wm i3status \
    picom feh rofi alacritty cbatticon network-manager-applet \
    blueman pavucontrol brightnessctl i3lock scrot thunar \
    gvfs gvfs-mtp gvfs-gphoto2 udiskie code xdg-user-dirs \
    python-psutil

# 🟡 3. Instalar yay si no está
if ! command -v yay &>/dev/null; then
    echo "📦 Instalando yay desde AUR..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
fi

# 🟡 4. Instalar discord desde AUR
echo "💬 Instalando Discord..."
yay -S --noconfirm discord

# 🟡 5. Instalar oh-my-bash para usuario
if [ ! -d "$HOME/.oh-my-bash" ]; then
    echo "🐚 Instalando oh-my-bash para usuario..."
    if curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh | sh -s -- --unattended; then
        echo "✅ oh-my-bash instalado para usuario."
        sed -i 's/OSH_THEME=.*/OSH_THEME="agnoster"/' ~/.bashrc
    else
        echo "❌ Falló la instalación de oh-my-bash para usuario."
    fi
fi

# 🟡 6. Instalar oh-my-bash para root
if sudo test ! -d /root/.oh-my-bash; then
    echo "🐚 Instalando oh-my-bash para root..."
    if sudo bash -c 'curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh | sh -s -- --unattended'; then
        echo "✅ oh-my-bash instalado para root."
        sudo sed -i 's/OSH_THEME=.*/OSH_THEME="agnoster"/' /root/.bashrc
    else
        echo "❌ Falló la instalación de oh-my-bash para root."
    fi
fi

# 🟡 7. Instalar FiraCode Nerd Font
echo "🔠 Instalando FiraCode Nerd Font..."
mkdir -p ~/.local/share/fonts
cd /tmp
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
unzip -qo FiraCode.zip -d ~/.local/share/fonts
fc-cache -fv

# 🟡 8. Configurar i3 (config + wallpaper)
echo "🧩 Configurando i3 y wallpaper..."
mkdir -p ~/.config/i3

# Asegúrate de que los archivos existan antes de copiarlos
if [[ -f "./config" && -f "./wallpaper.jpg" ]]; then
    cp -r ./config ~/.config/i3/config
    cp -r ./wallpaper.jpg ~/.config/i3/wallpaper.jpg
else
    echo "⚠️  No se encontraron los archivos 'config' o 'wallpaper.jpg'. Asegúrate de tenerlos en el directorio correcto."
fi

# 🟡 9. Crear carpetas de usuario estándar
echo "📁 Creando carpetas de usuario estándar..."
xdg-user-dirs-update
mkdir -p ~/Documentos ~/Descargas ~/Música ~/Videos ~/Imágenes ~/Escritorio

# 🟡 10. Instalar bumblebee-status
echo "🧩 Instalando bumblebee-status..."
git clone https://github.com/tobi-wan-kenobi/bumblebee-status.git ~/.config/bumblebee-status
sudo ln -sf ~/.config/bumblebee-status/bumblebee-status /usr/bin/bumblebee-status
chmod +x ~/.config/bumblebee-status/bumblebee-status

# ✅ Final
echo ""
echo "✅ Instalación completada correctamente."
echo "Reinicia tu sesión o ejecuta: i3-msg restart"
