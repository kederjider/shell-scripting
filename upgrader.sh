#!/bin/bash

# ============================================
# Update File dari GitHub (Ubuntu 24)
# Menghapus file lama → download file baru
# ============================================
# Cek hak akses root
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[31mError: Script ini harus dijalankan sebagai root (sudo).\e[0m"
    exit 1
fi

clear
# No Color# Colors (Cyberpunk Style)
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

DIRECTORY="/usr/local/bin"
REPO="https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main"


function upgrade() {
# Cek jumlah argumen
if [ $# -ne 2 ]; then
    echo -e "${RED}Usage:${NC} $0 <path_file_lokal> <url_raw_github>"
    echo ""
    echo "Contoh:"
    echo "  $0 /usr/local/bin/myscript.sh"
    echo "  $0 https://raw.githubusercontent.com/user/repo/main/myscript.sh"
    exit 1
fi

 local SCRIPT="$1"
 local URL="$2"
    # Cek apakah wget terinstall
if ! command -v wget &> /dev/null; then
    echo -e "${RED}Error:${NC} wget belum terinstall."
    echo "Install dengan: sudo apt update && sudo apt install wget -y"
    exit 1
fi

echo -e "${YELLOW}=== Upgrader File dari GitHub ===${NC}"
echo "File lokal : $SCRIPT"
echo "URL        : $URL"
echo ""


local tmp
tmp=$(mktemp)

if wget -q -O "$tmp" "$URL"; then
    if ! cmp -s "$SCRIPT" "$tmp"; then
        echo "Ada update, mengganti script..."
        if [[ "$URL" == *.py ]] || [[ "$SCRIPT" == *.py ]]; then
            echo "File Python"
            echo "mengaktifkan executable..."
            cp "$tmp" "$SCRIPT"
            chmod 755 "$SCRIPT"
        elif [[ "$URL" == *.sh ]] || [[ "$SCRIPT" == *.sh ]]; then
            echo "File Bash/Shell"
            echo "mengaktifkan executable..."
            cp "$tmp" "$SCRIPT"
            chmod +x "$SCRIPT"
        else
            echo "Bukan file .py atau .sh"
            cp "$tmp" "$SCRIPT"
        fi       
    else
        echo "Script sudah terbaru."
    fi
else
    echo "Gagal mengambil script dari GitHub."
fi

rm -f "$tmp"
}

echo -e "${L_GREEN}"
cat << "EOF"
                                 _                           _       _   
 _   _ _ __   __ _ _ __ __ _  __| | ___ _ __   ___  ___ _ __(_)_ __ | |_ 
| | | | '_ \ / _` | '__/ _` |/ _` |/ _ \ '__| / __|/ __| '__| | '_ \| __|
| |_| | |_) | (_| | | | (_| | (_| |  __/ |    \__ \ (__| |  | | |_) | |_ 
 \__,_| .__/ \__, |_|  \__,_|\__,_|\___|_|    |___/\___|_|  |_| .__/ \__|
      |_|    |___/                                            |_|        
                 [ UPGRADER - SCRIPT v1.0 ]
                 MAMAT SCRIPTING - 2026
EOF
echo -e "${NC}"

echo -e "${GRAY}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GRAY}║${L_CYAN}                 SYSTEM SCRIPT UPGRADER v1.0                   ${GRAY}║${NC}"
echo -e "${GRAY}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}01${L_GREEN}]${NC} ${YELLOW}update sc check service${NC} ${GRAY}║${L_GREEN} [${CYAN}18${L_GREEN}]${NC} ${YELLOW}update sc spaming${NC}         ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}02${L_GREEN}]${NC} ${YELLOW}update sc servic manager${NC}${GRAY}║${L_GREEN} [${CYAN}19${L_GREEN}]${NC} ${YELLOW}update sc ddos${NC}            ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}03${L_GREEN}]${NC} ${YELLOW}update sc config nginx${NC}  ${GRAY}║${L_GREEN} [${CYAN}20${L_GREEN}]${NC} ${YELLOW}update sc subdomain finder${NC}${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}04${L_GREEN}]${NC} ${YELLOW}update sc check disk${NC}    ${GRAY}║${L_GREEN} [${CYAN}21${L_GREEN}]${NC} ${YELLOW}update sc kirim email${NC}     ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}05${L_GREEN}]${NC} ${YELLOW}update sc tailscale${NC}     ${GRAY}║${L_GREEN} [${CYAN}22${L_GREEN}]${NC} ${YELLOW}update sc spam post${NC}       ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}06${L_GREEN}]${NC} ${YELLOW}update sc zeroTier${NC}      ${GRAY}║${L_GREEN} [${CYAN}23${L_GREEN}]${NC} ${YELLOW}update sc menu ip to host${NC} ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}07${L_GREEN}]${NC} ${YELLOW}update sc monitoring${NC}    ${GRAY}║${L_GREEN} [${CYAN}24${L_GREEN}]${NC} ${YELLOW}update sc menu host to ip${NC} ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}08${L_GREEN}]${NC} ${YELLOW}update sc screen${NC}        ${GRAY}║${L_GREEN} [${CYAN}25${L_GREEN}]${NC} ${YELLOW}update sc ping${NC}            ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}09${L_GREEN}]${NC} ${YELLOW}update sc auto root${NC}     ${GRAY}║${L_GREEN} [${CYAN}26${L_GREEN}]${NC} ${YELLOW}update sc ip to host${NC}      ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}10${L_GREEN}]${NC} ${YELLOW}update sc auto reboot${NC}   ${GRAY}║${L_GREEN} [${CYAN}27${L_GREEN}]${NC} ${YELLOW}update sc host to ip${NC}      ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}11${L_GREEN}]${NC} ${YELLOW}update sc tools hack${NC}    ${GRAY}║${L_GREEN} [${CYAN}28${L_GREEN}]${NC} ${YELLOW}update sc edit file script${NC}${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}12${L_GREEN}]${NC} ${YELLOW}update sc setting${NC}       ${GRAY}║${L_GREEN} [${CYAN}29${L_GREEN}]${NC} ${YELLOW}update sc istl dmain finde${NC}${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}13${L_GREEN}]${NC} ${YELLOW}update sc dns lookup${NC}    ${GRAY}║${L_GREEN} [${CYAN}30${L_GREEN}]${NC} ${YELLOW}update sc install sherlock${NC}${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}14${L_GREEN}]${NC} ${YELLOW}update sc about domain${NC}  ${GRAY}║${L_GREEN} [${CYAN}31${L_GREEN}]${NC} ${YELLOW}update sc ddns${NC}            ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}15${L_GREEN}]${NC} ${YELLOW}update sc dns records${NC}   ${GRAY}║${L_GREEN} [${CYAN}32${L_GREEN}]${NC} ${YELLOW}update sc menu utama${NC}      ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}16${L_GREEN}]${NC} ${YELLOW}update sc user finder${NC}   ${GRAY}║${L_GREEN} [${CYAN}33${L_GREEN}]${NC} ${YELLOW}update sc upgreader${NC}       ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}17${L_GREEN}]${NC} ${YELLOW}update sc tracker${NC}       ${GRAY}║${L_GREEN} [${RED}0${L_GREEN}]${NC} ${RED}Kembali ke Menu Utama${NC}      ${GRAY}║${NC}"
echo -e "${GRAY}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${L_CYAN}┌──(${L_RED}root${L_CYAN}@${YELLOW}mamat${L_CYAN})─[${L_GREEN}upgrader${L_CYAN}]${NC}"
echo -e -n "${L_CYAN}└──▶️ ${NC}"
read -p "" plh
echo -e ""

case $plh in
1 | 01) upgrade "$DIRECTORY/cek_service" "$REPO/cek_service.sh" ; exit 0 ;;
2 | 02) upgrade "$DIRECTORY/service_manager" "$REPO/service_manager.sh" ; exit 0 ;;
3 | 03) upgrade "$DIRECTORY/m-nginx" "$REPO/m-nginx.sh" ; exit 0 ;;
4 | 04) upgrade "$DIRECTORY/disk" "$REPO/disk.sh" ; exit 0 ;;
5 | 05) upgrade "$DIRECTORY/m-tailscale" "$REPO/m-tailscale.sh" ; exit 0 ;;
6 | 06) upgrade "$DIRECTORY/m-zerotier" "$REPO/m-zerotier.sh" ; exit 0 ;;
7 | 07) upgrade "$DIRECTORY/m-monitor" "$REPO/m-monitor.sh" ; exit 0 ;;
8 | 08) upgrade "$DIRECTORY/m-screen" "$REPO/m-screen.sh" ; exit 0 ;;
9 | 09) upgrade "$DIRECTORY/root" "$REPO/root.sh" ; exit 0 ;;
10) upgrade "$DIRECTORY/a-reboot" "$REPO/a-reboot.sh" ; exit 0 ;;
11) upgrade "$DIRECTORY/mode-hack" "$REPO/mode-hack.sh" ; exit 0 ;;
12) upgrade "$DIRECTORY/m-setting" "$REPO/m-setting.sh" ; exit 0 ;;
13) upgrade "$DIRECTORY/lookup-dns" "$REPO/lookup-dns.sh" ; exit 0 ;;
14) upgrade "$DIRECTORY/m-domain" "$REPO/m-domain.py" ; exit 0 ;;
15) upgrade "$DIRECTORY/dns-records" "$REPO/dns-records.sh" ; exit 0 ;;
16) upgrade "$DIRECTORY/m-user-finder" "$REPO/m-user-finder.sh" ; exit 0 ;;
17) upgrade "$DIRECTORY/m-tracker" "$REPO/m-tracker.py" ; exit 0 ;;
18) upgrade "$DIRECTORY/nobody-spam" "$REPO/nobody-spam.py" ; exit 0 ;;
19) upgrade "$DIRECTORY/m-ddos" "$REPO/m-ddos.sh" ; exit 0 ;;
20) upgrade "$DIRECTORY/sub-domain-finder" "$REPO/sub-domain-finder.sh" ; exit 0 ;;
21) upgrade "$DIRECTORY/kirim_email" "$REPO/kirim_email.py" ; exit 0 ;;
22) upgrade "$DIRECTORY/spam_post" "$REPO/spam_post.py" ; exit 0 ;;
23) upgrade "$DIRECTORY/m-ip-to-host" "$REPO/m-ip-to-host.sh" ; exit 0 ;;
24) upgrade "$DIRECTORY/m-host-to-ip" "$REPO/m-host-to-ip.sh" ; exit 0 ;;
25) upgrade "$DIRECTORY/pinghost" "$REPO/pinghost.sh" ; exit 0 ;;
26) upgrade "$DIRECTORY/ip_to_host" "$REPO/ip_to_host.py" ; exit 0 ;;
27) upgrade "$DIRECTORY/host_to_ip" "$REPO/host_to_ip.py" ; exit 0 ;;
28) upgrade "$DIRECTORY/editfile" "$REPO/editfile.sh" ; exit 0 ;;
29) upgrade "$DIRECTORY/install-domain-finder" "$REPO/install-domain-finder.sh" ; exit 0 ;;
30) upgrade "$DIRECTORY/install-sherlock" "$REPO/install-sherlock.sh" ; exit 0 ;;
31) upgrade "$DIRECTORY/ddns" "$REPO/ddns.sh" ; exit 0 ;;
32) upgrade "$DIRECTORY/newmenu" "$REPO/newmenu.sh" ; exit 0 ;;
33) upgrade "$DIRECTORY/upgrader" "$REPO/upgrader.sh" ; exit 0 ;;
0 | 00) clear ; newmenu ;;
x | X) clear ; echo -e "${L_RED} TERIMA KASIH TELAH MENGGUNAKAN PROGRAM INI...${NC}" ; exit 0 ;;
*) echo -e "${L_RED}[ERROR] Pilihan tidak valid.${NC}" ; sleep 2 ; exec "$0" ;;
esac
