#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- Інтерактивна перевірка та мердж dotfiles ---${NC}\n"

# Використовуємо дескриптор файлу (Process Substitution), щоб read не конфліктував
while read -r file; do
    if [[ "$file" == *"scripts/check.sh" ]]; then continue; fi

    rel_path="${file#$HOME/dotfiles/}"
    sys_file="$HOME/$rel_path"
    
    if [ ! -f "$sys_file" ]; then
        echo -e "${YELLOW}[Відсутній в системі]${NC}: $rel_path"
        echo -ne "  Дія: [i]гнорувати, [s]копіювати в систему? (i/s): "
        read -r opt < /dev/tty  # Читаємо саме з терміналу
        [[ "$opt" == "s" ]] && cp -v "$file" "$sys_file"
    else
        if ! diff -q "$file" "$sys_file" > /dev/null; then
            echo -e "${RED}[РІЗНИЦЯ]${NC}: $rel_path"
            echo -ne "  Дія: [m]eld (GUI), [d]iff (nvim), [s]у систему, [b]ackup, [i]гнорувати? (m/d/s/b/i): "
            read -r opt < /dev/tty
            
            case $opt in
                m)
                    meld "$sys_file" "$file" 2>/dev/null
                    ;;
                d)
                    nvim -d "$sys_file" "$file"
                    ;;
                s)
                    cp -v "$file" "$sys_file"
                    ;;
                b)
                    cp -v "$sys_file" "$file"
                    ;;
                *)
                    echo "Пропущено."
                    ;;
            esac
        fi
    fi
done < <(find ~/dotfiles -type f -not -path '*/.git/*')

echo -e "\n${BLUE}--- Готово! ---${NC}"
