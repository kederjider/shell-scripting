#!/bin/bash
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
g="\033[1;92m"
y='\033[1;33m' #yellow
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
dkblu="\033[34m"
red() { echo -e "\\033[32;1m${*}\\033[0m"; }
# Getting

# =============================================
# Fungsi Install Official Ookla Speedtest CLI
# =============================================

install_speedtest_official() {
    echo "🔍 Memeriksa apakah Official Ookla Speedtest CLI sudah terinstall..."

    # Cek apakah command speedtest sudah ada dan berasal dari Ookla
    if command -v speedtest &> /dev/null; then
        # Cek versi untuk memastikan bukan versi python
        if speedtest --version 2>&1 | grep -q "Ookla"; then
            echo "✅ Official Ookla Speedtest CLI sudah terinstall."
            return 0
        else
            echo "⚠️  Terdeteksi speedtest-cli (Python), akan diganti dengan versi resmi Ookla."
        fi
    fi

    echo "📥 Official Ookla Speedtest CLI belum terinstall. Melakukan instalasi..."

    # Update sistem
    sudo apt update

    # Install curl jika belum ada
    if ! command -v curl &> /dev/null; then
        echo "📦 Menginstall curl..."
        sudo apt install curl -y
    fi

    # Tambahkan repository resmi Ookla
    echo "➕ Menambahkan repository Ookla..."
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

    # Workaround Ubuntu 24.04 (ganti noble ke jammy)
    if [ -f /etc/apt/sources.list.d/ookla_speedtest-cli.list ]; then
        echo "🔧 Menerapkan workaround Ubuntu 24.04..."
        sudo sed -i 's/noble/jammy/g' /etc/apt/sources.list.d/ookla_speedtest-cli.list
    fi

    # Update repository dan install
    echo "📦 Mengupdate repository dan menginstall speedtest..."
    sudo apt update
    sudo apt install speedtest -y

    # Verifikasi akhir
    if command -v speedtest &> /dev/null && speedtest --version 2>&1 | grep -q "Ookla"; then
        echo "🎉 Berhasil! Official Ookla Speedtest CLI telah terinstall."
        echo "   Versi: $(speedtest --version | head -n 1)"
    else
        echo "❌ Gagal menginstall speedtest. Silakan cek error di atas."
        return 1
    fi
}

function kirim_pesan() {
echo ""
echo -e "${cyan} jika terjadi error \n anda bisa sampaikan kepada kami \n jika ada masukan, kritik dan saran \n bisa sampaikan kepada kami disini atau hubungi telegram \n t.me/jaringan_vpn${NC}"
    echo -e "  \033[1;93m────────────────────────────────────────────\033[0m"

read -p "   Masukan Pesan: " pesannya
set -a
source .env
set +a
BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
CHAT_ID="6406806868"
MYIP=$(wget -qO- ipinfo.io/ip)
ISP=$(wget -qO- ipinfo.io/org)
CITY=$(curl -s ipinfo.io/city)
TIMES=$(date +'%Y-%m-%d %H:%M:%S')
RAMMS=$(free -m | awk 'NR==2 {print $2}')
OSL=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
MESSAGE="
────────────────────
⚠️PESAN DARI CLIENT⚠️
────────────────────
Ip vps  : $MYIP
Date    : $TIMES
Ram     : $RAMMS MB
System  : $OSL
Country : $CITY
Isp     : $ISP
────────────────────
$pesannya
────────────────────
Automatic Notification from Jaringan_vpn"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d chat_id=$CHAT_ID \
     -d text="$MESSAGE"

echo -e "$✅ {GREEN}pesan berhasil dikirim${NC}"
}


echo -e " ${y} ┌─────────────────────────────────┐$NC"
echo -e " ${y} │${NC}${g}.::. ${NC}MENU PENGATURAN LAINNYA ${g}.::.${y}│$NC"
echo -e " ${y} └─────────────────────────────────┘$NC"
echo -e    "\033[1;33m  ┌─────────────────────────────────┐\033[0m"
echo -e "  ${y}│${NC}${dkblu}[${g}•1${dkblu}]${NC}\033[0;36m KIRIM PESAN KEDEVELOPER     ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•2${dkblu}]${NC}\033[0;36m SPEEDTEST                   ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•3${dkblu}]${NC}\033[0;36m MONITORING                  ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•4${dkblu}]${NC}\033[0;36m EDIT FILE SCRIPT            ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•5${dkblu}]${NC}\033[0;36m SETUP DDNS                  ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•6${dkblu}]${NC}\033[0;36m UPGRADER SCRIPT             ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}•7${dkblu}]${NC}\033[0;36m CLEARLOG                    ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}•8${dkblu}]${NC}\033[0;36m DELETE USER EXP             ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}•9${dkblu}]${NC}\033[0;36m EDIT BENNER                 ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}10${dkblu}]${NC}\033[0;36m CHANGE DOMAIN               ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}11${dkblu}]${NC}\033[0;36m CERT SSL/DOMAIN             ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}12${dkblu}]${NC}\033[0;36m INFO PORT                   ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}13${dkblu}]${NC}\033[0;36m AUTO REBOOT                 ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}14${dkblu}]${NC}\033[0;36m CLEAR CHACE                 ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}15${dkblu}]${NC}\033[0;36m CHECK BW                    ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}16${dkblu}]${NC}\033[0;36m CEK PENYIMPANAN             ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}17${dkblu}]${NC}\033[0;36m KIRIM PESAN KEDEVELOPER     ${y}│${NC}"
echo -e "  ${y}│                                 │${NC}"
echo -e "  ${y}│${NC}${dkblu}[${red}•0${dkblu}]${NC}${red} BACK TO MENU                ${y}│${NC}"
echo -e "\033[1;33m  └─────────────────────────────────┘\033[0m"
read -p "Silakan Masukkan Angka [ 1 - 6 ] : " plh
echo -e ""
case $plh in
1 | 01)
    kirim_pesan
    ;;
2 | 02)
    clear
    install_speedtest_official
    speedtest
    ;;
3 | 03)
    m-monitor
    ;;
4 | 04)
    clear
    editfile
    ;;
5 | 05)
    clear
    ddns
    ;;
6 | 06)
    upgrader
    ;;
#7 | 07)
#    clear
#    clearlog
#    ;;
#8 | 08)
#    clear
#    xp
#    ;;
#9 | 09)
#    nano /etc/kyt.txt  
#    ;;
#10)
#    addhost
#    ;;    
#11)
#    fixcert
#    ;;
#12)
#    clear
#    prot
#    ;;
#13)
#    autoreboot
#    ;;
#14)
#    clear
#    clearcache
#    ;;
#15)
#    clear
#    cek_bw
#    read -n 1 -s -r -p "Press any key to back on menu"
#    loading ; menu ;;
#16)
#    cek-penyimpanan
#    ;;
#17)
#    clear
#    kirim_pesan
#    ;;
0)
    clear
    newmenu ;;
x | X)
    clear
    exit 0
    ;;
*) echo "Silakan Masukkan Angka [1 - 6]." ; loading ; exec "$0" ;;
esac
