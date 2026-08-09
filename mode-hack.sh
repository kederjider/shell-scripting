#!/bin/bash

# Colors
y='\033[1;33m' #yellow
Green="\e[92;1m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
GRAY="\e[1;30m"
NC='\e[0m'
red='\e[1;31m'
green='\e[0;32m'
DF='\e[39m'
Bold='\e[1m'
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
cyan='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
NC='\e[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHT='\033[0;37m'
grenbo="\e[92;1m"
drakgry="\033[90m"
liggry="\033[37m"
pth="\033[97m"
CYAN='\033[0;36m'
hijauu="\033[92m"
drkhju="\033[32m"
red() { echo -e "\\033[32;1m${*}\\033[0m"; }
bgred="\033[41m"
L_GREEN='\e[92m'

clear
echo -e "${L_GREEN}"
cat << "EOF"
     _   _    _    ____ _  _____ _   _  ____ 
    | | | |  / \  / ___| |/ /_ _| \ | |/ ___|
    | |_| | / _ \| |   | ' / | ||  \| | |  _ 
    |  _  |/ ___ \ |___| . \ | || |\  | |_| |
    |_| |_/_/   \_\____|_|\_\___|_| \_|\____|

            [ HACKING - TOOLS v2.0 ]

EOF
echo -e "${NC}"

echo -e "${CYAN} ╔═════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN} ║${bgred}                 HACKING TOOLS MENU                  ${NC}${CYAN}║${NC}"
echo -e "${CYAN} ╠═════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•1${drakgry}]${pth} DNS LOOKUP${NC}            ${CYAN}║${drakgry}[${liggry}•8${drakgry}]${pth} SUB DOMAIN FINDER${NC}   ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•2${drakgry}]${pth} ABOUT DOMAIN${NC}          ${CYAN}║${drakgry}[${liggry}•8${drakgry}]${pth} KIRIM EMAIL${NC}         ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•3${drakgry}]${pth} DNS RECORDS${NC}           ${CYAN}║${drakgry}[${liggry}•10${drakgry}]${pth} SPAM POST${NC}          ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•4${drakgry}]${pth} USER FINDER${NC}           ${CYAN}║${drakgry}[${liggry}•11${drakgry}]${pth} IP TO HOST${NC}         ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•5${drakgry}]${pth} TRACKER${NC}               ${CYAN}║${drakgry}[${liggry}•12${drakgry}]${pth} HOST TO IP${NC}         ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•6${drakgry}]${pth} SPAMING${NC}               ${CYAN}║${drakgry}[${liggry}•13${drakgry}]${pth} PING${NC}               ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•7${drakgry}]${pth} DDOS${NC}                  ${CYAN}║${drakgry}[${RED}•0${drakgry}]${RED} Kembali Ke Menu    ${NC} ${CYAN}║${NC}"
echo -e "${CYAN} ╚═════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN} ┌───(${YELLOW}Masukkan${CYAN}─${YELLOW}Angka${RST}${CYAN})──[${YELLOW}1${CYAN}-${YELLOW}13${CYAN}]───▶️${RST}"
    read -p " $(echo -e ${CYAN}└──▶️ ${NC}) " plh
echo -e ""

case $plh in
1 | 01) lookup-dns ;;
2 | 02) m-domain ;;
3 | 03) dns-records ;;
4 | 04) m-user-finder ;;
5 | 05) m-tracker ;;
6 | 06) nobody-spam ;;
7 | 07) m-ddos ;;
8 | 08) sub-domain-finder ;;
9 | 09) kirim_email ;;
10) spam_post;;
11) m-ip-to-host ;;
12) m-host-to-ip ;;
13) pinghost ;;
0 | 00) clear ; newmenu ;;
x | X) clear ; exit 0 ;;
*) echo "Pilihan tidak valid. Silakan masukkan angka dari 1 sampai 13.\n" ; loading ; mode-hack ;;
esac