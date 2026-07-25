#!/bin/bash

echo -e "\n"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

for i in {0..100}; do
    spin=${spinner[i%10]}
    filled=$((i * 30 / 100))
    bar=$(printf "%${filled}s" | tr ' ' '#')
    bar+=$(printf "%$((30 - filled))s" | tr ' ' '-')
    
    echo -ne "${YELLOW}${spin}${RESET} ${CYAN}Menuju Ke Menu Utama${RESET} "
    echo -ne "[${GREEN}${bar}${RESET}] ${i}%  \r"
    sleep 0.03
done

echo -e "\n${GREEN}✓ Berhasil!${RESET} Memasuki Menu Utama...\n"
clear