#!/bin/bash
# __  ______   ____
# \ \/ /  _ \ / ___|
#  \  /| | | | |  _
#  /  \| |_| | |_| |
# /_/\_\____/ \____|
#

# Setup Timers
_sleep1="0.1"
_sleep2="0.5"
_sleep3="2"

# --- ДОДАНО --- Запуск Gnome Keyring Daemon та Polkit (якщо ще не запущений)
# Політика ml4w може вже запускати polkit-gnome-authentication-agent-1 окремо, перевірте.
# Якщо він не запущений або вам потрібен саме тут, додайте.
# pgrep -f polkit-gnome-authentication-agent-1 || /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Важливо: gnome-keyring-daemon має бути запущений до порталів для WebAuthn
pgrep -f gnome-keyring-d || /usr/bin/gnome-keyring-daemon --daemonize --replace --components=secrets,ssh &
sleep $_sleep1 # Даємо час на запуск keyring

# Kill all possible running xdg-desktop-portals
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-gnome
killall -e xdg-desktop-portal-kde
killall -e xdg-desktop-portal-lxqt
killall -e xdg-desktop-portal-wlr
killall -e xdg-desktop-portal-gtk
killall -e xdg-desktop-portal

# Set required environment variables
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland

# Stop all services
systemctl --user stop pipewire
systemctl --user stop wireplumber
systemctl --user stop xdg-desktop-portal
systemctl --user stop xdg-desktop-portal-gnome
systemctl --user stop xdg-desktop-portal-kde
systemctl --user stop xdg-desktop-portal-wlr
systemctl --user stop xdg-desktop-portal-hyprland
sleep $_sleep1

# Start xdg-desktop-portal-hyprland
/usr/lib/xdg-desktop-portal-hyprland &
sleep $_sleep1

# Start xdg-desktop-portal-gtk
if [ -f /usr/lib/xdg-desktop-portal-gtk ]; then
    /usr/lib/xdg-desktop-portal-gtk &
    sleep $_sleep1
fi

# --- ДОДАНО --- Запуск xdg-desktop-portal-gnome
if [ -f /usr/lib/xdg-desktop-portal-gnome ]; then
    /usr/lib/xdg-desktop-portal-gnome &
    sleep $_sleep1
fi

# Start xdg-desktop-portal
/usr/lib/xdg-desktop-portal &
sleep $_sleep2

# Start required services
systemctl --user start pipewire
systemctl --user start wireplumber
systemctl --user start xdg-desktop-portal
systemctl --user start xdg-desktop-portal-hyprland
# --- ДОДАНО --- Також переконаємося, що gnome-desktop-portal стартує через systemctl, якщо був зупинений
systemctl --user start xdg-desktop-portal-gnome # ДОДАНО

# Run waybar
sleep $_sleep3
~/.config/waybar/launch.sh


