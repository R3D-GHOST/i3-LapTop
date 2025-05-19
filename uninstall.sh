#!/bin/bash
set -e

echo "⚠️ Este script eliminará todos los paquetes y configuraciones instalados por el setup de i3."
read -p "¿Estás seguro? (sí/no): " confirmacion

if [[ "$confirmacion" =~ ^[Nn][Oo]$ ]]; then
    echo "❌ Cancelado."
    exit 1
fi

# 🗑 Desinstalar paquetes instalados
echo "📦 Eliminando paquetes instalados..."
sudo pacman -Rns --noconfirm i3-wm i3status picom feh rofi alacritty cbatticon \
    network-manager-applet blueman pavucontrol brightnessctl light i3lock scrot \
    thunar gvfs gvfs-mtp gvfs-gphoto2 udiskie code discord

# 🗑 Eliminar yay (si existe)
if command -v yay &> /dev/null; then
    echo "🧽 Eliminando yay..."
    sudo pacman -Rns --noconfirm yay
    rm -rf /tmp/yay
fi

# 🧼 Eliminar oh-my-bash (usuario normal)
if [ -d "$HOME/.oh-my-bash" ]; then
    echo "🧼 Eliminando oh-my-bash para usuario..."
    rm -rf ~/.oh-my-bash
    if [ -f ~/.bashrc.pre-oh-my-bash ]; then
        mv ~/.bashrc.pre-oh-my-bash ~/.bashrc
    fi
fi

# 🧼 Eliminar oh-my-bash para root
if sudo test -d /root/.oh-my-bash; then
    echo "🧼 Eliminando oh-my-bash para root..."
    sudo rm -rf /root/.oh-my-bash
    if sudo test -f /root/.bashrc.pre-oh-my-bash; then
        sudo mv /root/.bashrc.pre-oh-my-bash /root/.bashrc
    fi
fi

# 🔠 Eliminar fuente FiraCode Nerd Font
echo "🔠 Eliminando FiraCode Nerd Font..."
find ~/.local/share/fonts -iname "*FiraCode*" -delete
fc-cache -fv

# 🧹 Borrar configuración de i3 y wallpaper
echo "🧹 Borrando configuración de i3..."
rm -rf ~/.config/i3

# 📂 Eliminar carpetas de usuario si están vacías
echo "📂 Limpiando carpetas de usuario vacías..."
for dir in ~/Documentos ~/Descargas ~/Música ~/Videos ~/Imágenes ~/Escritorio; do
    if [ -d "$dir" ] && [ ! "$(ls -A "$dir")" ]; then
        rmdir "$dir"
    fi
done

echo ""
echo "✅ Todo ha sido eliminado correctamente. Sistema limpio para volver a instalar."
