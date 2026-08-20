#!/bin/bash

# Colors
# Colors
GREEN='\033[0;32m'
WHITE='\033[1;37m'
GB='\033[42;37m'; c='\e[1;36m'; g='\e[1;32m'; y='\e[1;33m'; w='\e[1;37m'
u='\e[1;35m'; r='\e[1;31m'
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

spammingpost() {
    clear
    echo -e "${g}${NC}"
    echo -e "       ╭──────────────────────────────────────────╮"
    echo -e "       │${GB}            SPAMMING MANAGER               ${NC}│"
    echo -e "       ╰──────────────────────────────────────────╯"
    echo -e "        ${r}┌──────────────────────────────────────┐${NC}"
    echo -e "        ${r}│${y}[${u}•1${y}]${NC} M SPAMING POST  ""${y}[${u}•3${y}]${NC} M SPAMING AL${r}│"
    echo -e "        ${r}│${y}[${u}•2${y}]${NC} M SPAM DISKFILL ""${y}[${u}•0${y}]${NC} BACK TO MENU${r}│"
    echo -e "        ${r}└──────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${CYAN}        ┌───(${YELLOW}Pilih${CYAN}─${YELLOW}Menu${RST}${CYAN})──[${YELLOW}1${CYAN}-${YELLOW}3${CYAN}]───▶️${RST}"
    read -p "        $(echo -e ${CYAN}└──▶️ ${NC}) " sess_opt
    echo ""
    case $sess_opt in
        01|1)  clear; bash m-spam-post ;;
        02|2)  clear; bash m-diskfill ;;
        03|3)  clear; bash m-post-all ;;
        0|00)  clear; exec "$0" ;;
        X|x)  clear; echo -e "${GREEN}Dadah! 👋${NC}"; exit 0 ;;
        *)  echo -e "${RED}Pilihan salah. Ulangi.${NC}"; sleep 1; exit 0 ;;
    esac
}

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
echo -e "${CYAN} ║${drakgry}[${liggry}•1${drakgry}]${pth} DNS LOOKUP${NC}           ${CYAN}║${drakgry}[${liggry}•9${drakgry}]${pth} KIRIM EMAIL${NC}          ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•2${drakgry}]${pth} ABOUT DOMAIN${NC}         ${CYAN}║${drakgry}[${liggry}10${drakgry}]${pth} SPAMING POST${NC}         ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•3${drakgry}]${pth} DNS RECORDS${NC}          ${CYAN}║${drakgry}[${liggry}11${drakgry}]${pth} IP TO HOST${NC}           ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•4${drakgry}]${pth} USER FINDER${NC}          ${CYAN}║${drakgry}[${liggry}12${drakgry}]${pth} HOST TO IP${NC}           ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•5${drakgry}]${pth} TRACKER${NC}              ${CYAN}║${drakgry}[${liggry}13${drakgry}]${pth} PING${NC}                 ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•6${drakgry}]${pth} SPAMING${NC}              ${CYAN}║${drakgry}[${liggry}14${drakgry}]${pth} ANTI SPAM${NC}            ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•7${drakgry}]${pth} DDOS${NC}                 ${CYAN}║${drakgry}[${liggry}15${drakgry}]${pth} SPAM DETECTOR${NC}        ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•8${drakgry}]${pth} SUB DOMAIN FINDER${NC}    ${CYAN}║${drakgry}[${RED}•0${drakgry}]${RED} Kembali Ke Menu${NC}      ${CYAN}║${NC}"
echo -e "${CYAN} ╚═════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN} ┌───(${YELLOW}Masukkan${CYAN}─${YELLOW}Angka${RST}${CYAN})──[${YELLOW}1${CYAN}-${YELLOW}15${CYAN}]───▶️${RST}"
    read -p " $(echo -e ${CYAN}└──▶️ ${NC}) " plh
echo -e ""

case $plh in
1 | 01) lookup-dns ;;
2 | 02) clear ; m-domain ;;
3 | 03) clear ; dns-records ;;
4 | 04) m-user-finder ;;
5 | 05) m-tracker ;;
6 | 06) nobody-spam ;;
7 | 07) m-ddos ;;
8 | 08) sub-domain-finder ;;
9 | 09) kirim_email ;;
10) spammingpost;;
11) m-ip-to-host ;;
12) m-host-to-ip ;;
13) pinghost ;;
14) clear ; anti_spam ;;
15) clear ; spam_detector ;;
0 | 00) clear ; newmenu ;;
x | X) clear ; exit 0 ;;
*) echo "Pilihan tidak valid. Silakan masukkan angka dari 1 sampai 15.\n" ; loading ; mode-hack ;;
esac