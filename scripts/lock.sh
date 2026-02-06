#!/bin/bash

# Отримуємо назви всіх клавіатур
KEYBOARD_NAMES=$(hyprctl devices -j | jq -r '.keyboards[] | .name')

# Перебираємо всі клавіатури і встановлюємо для них "English (US)" розкладку за індексом 0
for KEYBOARD_NAME in $KEYBOARD_NAMES; do
    hyprctl switchxkblayout "$KEYBOARD_NAME" 0
#    sleep 0.1 # Невелика затримка для обробки команди
done

# sleep 0.1 # Даємо Hyprland більше часу на застосування змін перед запуском hyprlock

hyprlock
