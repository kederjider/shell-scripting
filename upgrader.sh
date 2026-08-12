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
    if [ $# -ne 2 ]; then
        printf "${RED}✖ Penggunaan:${NC} %s <file_lokal> <url_github>\n" "$0"
        return 1
    fi

    local SCRIPT="$1"
    local URL="$2"
    local tmp backup file_type

    if ! command -v wget >/dev/null 2>&1; then
        printf "${RED}✖ Dependensi tidak ditemukan:${NC} wget\n"
        printf "  ${GRAY}Install: sudo apt update && sudo apt install wget -y${NC}\n"
        return 1
    fi

    printf "\n${BLUE}╭─ ${BOLD}UPGRADE FILE${NC} ${BLUE}──────────────────────────────────────╮${NC}\n"
    printf "${BLUE}│${NC} ${GRAY}File${NC} : ${CYAN}%s${NC}\n" "$SCRIPT"
    printf "${BLUE}│${NC} ${GRAY}Sumber${NC}: ${CYAN}%s${NC}\n" "$URL"
    printf "${BLUE}╰──────────────────────────────────────────────────────╯${NC}\n"
    printf "${YELLOW}⟳ Mengambil versi terbaru...${NC}\n"

    tmp=$(mktemp) || {
        printf "${RED}✖ Gagal membuat file sementara.${NC}\n"
        return 1
    }

    if ! wget -q --show-progress -O "$tmp" "$URL"; then
        printf "${RED}✖ Download gagal.${NC} Periksa URL atau koneksi internet.\n"
        rm -f "$tmp"
        return 1
    fi

    if [ ! -s "$tmp" ]; then
        printf "${RED}✖ File yang diunduh kosong. Update dibatalkan.${NC}\n"
        rm -f "$tmp"
        return 1
    fi

    if cmp -s "$SCRIPT" "$tmp" 2>/dev/null; then
        printf "${GREEN}✓ Sudah versi terbaru.${NC} Tidak ada perubahan.\n"
        rm -f "$tmp"
        return 0
    fi

    printf "${YELLOW}↻ Versi baru ditemukan. Memasang update...${NC}\n"
    backup="${SCRIPT}.bak"
    if [ -f "$SCRIPT" ]; then
        cp -p "$SCRIPT" "$backup" || {
            printf "${RED}✖ Backup gagal. Update dibatalkan demi keamanan.${NC}\n"
            rm -f "$tmp"
            return 1
        }
    fi

    if ! cp "$tmp" "$SCRIPT"; then
        printf "${RED}✖ Gagal mengganti file.${NC}\n"
        rm -f "$tmp"
        return 1
    fi

    if [[ "$URL" == *.py ]] || [[ "$SCRIPT" == *.py ]]; then
        file_type="Python"
        chmod 755 "$SCRIPT"
    elif [[ "$URL" == *.sh ]] || [[ "$SCRIPT" == *.sh ]]; then
        file_type="Bash/Shell"
        chmod +x "$SCRIPT"
    else
        file_type="File umum"
    fi

    rm -f "$tmp"
    printf "${GREEN}${BOLD}✓ BERHASIL DIUPDATE! 🎉${NC}\n"
    printf "  ${GRAY}Tipe   :${NC} %s\n" "$file_type"
    printf "  ${GRAY}File   :${NC} ${CYAN}%s${NC}\n" "$SCRIPT"
    printf "  ${GRAY}Backup :${NC} ${CYAN}%s${NC}\n" "$backup"
    printf "  ${GREEN}✓ Permission executable telah diaktifkan.${NC}\n"
    return 0
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
echo -e "${GRAY}║${L_GREEN} [${CYAN}01${L_GREEN}]${NC} ${YELLOW}update sc check service${NC} ${GRAY}║${L_GREEN} [${CYAN}20${L_GREEN}]${NC} ${YELLOW}update sc subdomain finder${NC}${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}02${L_GREEN}]${NC} ${YELLOW}update sc servic manager${NC}${GRAY}║${L_GREEN} [${CYAN}21${L_GREEN}]${NC} ${YELLOW}update sc kirim email${NC}     ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}03${L_GREEN}]${NC} ${YELLOW}update sc config nginx${NC}  ${GRAY}║${L_GREEN} [${CYAN}22${L_GREEN}]${NC} ${YELLOW}update sc spam post${NC}       ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}04${L_GREEN}]${NC} ${YELLOW}update sc check disk${NC}    ${GRAY}║${L_GREEN} [${CYAN}23${L_GREEN}]${NC} ${YELLOW}update sc menu ip to host${NC} ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}05${L_GREEN}]${NC} ${YELLOW}update sc tailscale${NC}     ${GRAY}║${L_GREEN} [${CYAN}24${L_GREEN}]${NC} ${YELLOW}update sc menu host to ip${NC} ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}06${L_GREEN}]${NC} ${YELLOW}update sc zeroTier${NC}      ${GRAY}║${L_GREEN} [${CYAN}25${L_GREEN}]${NC} ${YELLOW}update sc ping${NC}            ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}07${L_GREEN}]${NC} ${YELLOW}update sc monitoring${NC}    ${GRAY}║${L_GREEN} [${CYAN}26${L_GREEN}]${NC} ${YELLOW}update sc ip to host${NC}      ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}08${L_GREEN}]${NC} ${YELLOW}update sc screen${NC}        ${GRAY}║${L_GREEN} [${CYAN}27${L_GREEN}]${NC} ${YELLOW}update sc host to ip${NC}      ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}09${L_GREEN}]${NC} ${YELLOW}update sc auto root${NC}     ${GRAY}║${L_GREEN} [${CYAN}28${L_GREEN}]${NC} ${YELLOW}update sc edit file script${NC}${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}10${L_GREEN}]${NC} ${YELLOW}update sc auto reboot${NC}   ${GRAY}║${L_GREEN} [${CYAN}29${L_GREEN}]${NC} ${YELLOW}update sc istl dmain finde${NC}${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}11${L_GREEN}]${NC} ${YELLOW}update sc tools hack${NC}    ${GRAY}║${L_GREEN} [${CYAN}30${L_GREEN}]${NC} ${YELLOW}update sc install sherlock${NC}${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}12${L_GREEN}]${NC} ${YELLOW}update sc setting${NC}       ${GRAY}║${L_GREEN} [${CYAN}31${L_GREEN}]${NC} ${YELLOW}update sc ddns${NC}            ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}13${L_GREEN}]${NC} ${YELLOW}update sc dns lookup${NC}    ${GRAY}║${L_GREEN} [${CYAN}32${L_GREEN}]${NC} ${YELLOW}update sc menu utama${NC}      ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}14${L_GREEN}]${NC} ${YELLOW}update sc about domain${NC}  ${GRAY}║${L_GREEN} [${CYAN}33${L_GREEN}]${NC} ${YELLOW}update sc upgreader${NC}       ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}15${L_GREEN}]${NC} ${YELLOW}update sc dns records${NC}   ${GRAY}║${L_GREEN} [${CYAN}34${L_GREEN}]${NC} ${YELLOW}update sc anti spam${NC}       ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}16${L_GREEN}]${NC} ${YELLOW}update sc user finder${NC}   ${GRAY}║${L_GREEN} [${CYAN}35${L_GREEN}]${NC} ${YELLOW}update sc spam detector${NC}   ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}17${L_GREEN}]${NC} ${YELLOW}update sc tracker${NC}       ${GRAY}║${L_GREEN} [${CYAN}36${L_GREEN}]${NC} ${YELLOW}update sc pentesting${NC}      ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}18${L_GREEN}]${NC} ${YELLOW}update sc spaming${NC}       ${GRAY}║${L_GREEN} [${CYAN}37${L_GREEN}]${NC} ${YELLOW}update sc menu spam post${NC}  ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}19${L_GREEN}]${NC} ${YELLOW}update sc ddos${NC}          ${GRAY}║${L_GREEN} [${RED}0${L_GREEN}]${NC} ${RED}Kembali ke Menu Utama${NC}      ${GRAY}║${NC}"
echo -e "${GRAY}╚═══════════════════════════════════════════════════════════════╝${NC}"

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
34) upgrade "$DIRECTORY/anti_spam" "$REPO/anti_spam.py" ; exit 0 ;;
35) upgrade "$DIRECTORY/spam_detector" "$REPO/spam_detector.py" ; exit 0 ;;
36) upgrade "$DIRECTORY/pentester_tools" "$REPO/pentester_tools.py" ; exit 0 ;;
37) upgrade "$DIRECTORY/m-spam-post" "$REPO/m-spam-post.sh" ; exit 0 ;;
0 | 00) clear ; newmenu ;;
x | X) clear ; echo -e "${L_RED} TERIMA KASIH TELAH MENGGUNAKAN PROGRAM INI...${NC}" ; exit 0 ;;
*) echo -e "${L_RED}[ERROR] Pilihan tidak valid.${NC}" ; sleep 2 ; exec "$0" ;;
esac
