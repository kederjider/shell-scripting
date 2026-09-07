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

# Efek ketik huruf demi huruf
typewriter() {
    local text="$1" delay="${2:-0.015}"
    local ch
    while IFS= read -r ch; do
        printf '%s' "$ch"
        sleep "$delay"
    done < <(printf '%s' "$text" | grep -o .)
    printf '\n'
}

goodbye() {
    echo ""
    typewriter "  🦑 terima kasih 🙏🏻. Telah menggunakan Script Kami, Semoga Membantu 👋" 0.015
    echo ""
    exit 0
}

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
        X|x)  clear; goodbye ;;
        *)  echo -e "${RED}Pilihan salah. Ulangi.${NC}"; sleep 1; exit 0 ;;
    esac
}

# ========== FUNGSI WHOIS DOMAIN (SUB-MENU) ==========
plh_domain_about() {
    clear
    echo -e "${g}${NC}"
    echo -e "       ╭──────────────────────────────────────────╮"
    echo -e "       │${GB}          WHOIS DOMAIN MANAGER            ${NC}│"
    echo -e "       ╰──────────────────────────────────────────╯"
    echo -e "        ${r}┌──────────────────────────────────────┐${NC}"
    echo -e "        ${r}│${y}[${u}•1${y}]${NC} WHOIS TERMINAL  ""${y}[${u}•0${y}]${NC} BACK TO MENU${r}│"
    echo -e "        ${r}│${y}[${u}•2${y}]${NC} WHOIS DOMAIN WEB""${y}[${u}•X${y}]${NC} EXIT (0)    ${r}│"
    echo -e "        ${r}└──────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${CYAN}        ┌───(${YELLOW}Pilih${CYAN}─${YELLOW}Menu${RST}${CYAN})──[${YELLOW}1${CYAN}-${YELLOW}2${CYAN}]───▶️${RST}"
    read -p "        $(echo -e ${CYAN}└──▶️ ${NC}) " sess_opt
    echo ""
    case $sess_opt in
        01|1)  clear; m-domain ;;
        02|2)  clear; cek_whois_id ;;
        0|00)  clear; exec "$0" ;;
        X|x)  clear; goodbye ;;
        *)  echo -e "${RED}Pilihan salah. Ulangi.${NC}"; sleep 1; exit 0 ;;
    esac
}

# ========== FUNGSI INVESTIGASI DOMAIN (SUB-MENU) ==========
investigasi_domain() {
    clear
    echo -e "${g}${NC}"
    echo -e "       ╭──────────────────────────────────────────╮"
    echo -e "       │${GB}        INVESTIGASI DOMAIN MANAGER        ${NC}│"
    echo -e "       ╰──────────────────────────────────────────╯"
    echo -e "       ${r}┌─────────────────────────────────────────┐${NC}"
    echo -e "       ${r}│${y}[${u}1${y}]${NC} INVESTIGASI DOMAIN${r}│""${y}[${u}0${y}]${NC} BACK TO MENU  ${r}│"
    echo -e "       ${r}│${y}[${u}2${y}]${NC} LIHAT HASIL INVEST${r}│""${y}[${u}X${y}]${NC} EXIT (0)      ${r}│"
    echo -e "       ${r}│${y}[${u}3${y}]${NC} HAPUS HASIL INVEST${r}│""                  ${r}│"
    echo -e "       ${r}└─────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${CYAN}        ┌───(${YELLOW}Pilih${CYAN}─${YELLOW}Menu${RST}${CYAN})──[${YELLOW}1${CYAN}-${YELLOW}3${CYAN}]───▶️${RST}"
    read -p "        $(echo -e ${CYAN}└──▶️ ${NC}) " sess_opt
    echo ""
    case $sess_opt in
        01|1)  
            clear
            echo -e "${CYAN}Masukkan domain yang ingin diinvestigasi:${NC}"
            read -p "Domain: " domain
            if [ -n "$domain" ]; then
                echo -e "${YELLOW}Menjalankan investigasi domain...${NC}"
                investigator_domain "$domain"
                echo -e "${GREEN}Investigasi selesai. Tekan Enter untuk kembali ke menu.${NC}"
                read
            else
                echo -e "${RED}Domain tidak boleh kosong!${NC}"
                sleep 2
            fi
            clear; investigasi_domain ;;
        02|2)  
            clear
            echo -e "${CYAN}Daftar hasil investigasi:${NC}"
            LAPORAN_DIR="/usr/local/bin/hasil_investigasi_domain"
            if [ -d "$LAPORAN_DIR" ]; then
                files=$(ls "$LAPORAN_DIR"/*.txt 2>/dev/null)
                if [ -z "$files" ]; then
                    echo -e "${YELLOW}Tidak ada file hasil investigasi.${NC}"
                    sleep 2
                else
                    i=1
                    echo -e "${CYAN}Pilih file untuk ditampilkan:${NC}"
                    for file in $files; do
                        filename=$(basename "$file")
                        echo -e "${y}[${u}•$i${y}]${NC} $filename"
                        i=$((i+1))
                    done
                    echo -e "${y}[${u}•0${y}]${NC} Kembali ke menu"
                    echo ""
                    echo -e "${CYAN}Masukkan pilihan:${NC}"
                    read -p "> " choice
                    if [ "$choice" != "0" ]; then
                        file_count=$(echo "$files" | wc -l)
                        if [ "$choice" -ge 1 ] && [ "$choice" -le "$file_count" ]; then
                            selected_file=$(echo "$files" | sed -n "${choice}p")
                            echo -e "${CYAN}Isi file $selected_file:${NC}"
                            echo "========================================"
                            cat "$selected_file"
                            echo "========================================"
                            echo -e "${GREEN}Tekan Enter untuk kembali ke menu.${NC}"
                            read
                        else
                            echo -e "${RED}Pilihan tidak valid!${NC}"
                            sleep 2
                        fi
                    fi
                fi
            else
                echo -e "${YELLOW}Direktori hasil_investigasi_domain tidak ditemukan.${NC}"
                sleep 2
            fi
            clear; investigasi_domain ;;
        03|3)  
            clear
            echo -e "${CYAN}Daftar hasil investigasi:${NC}"
            LAPORAN_DIR="/usr/local/bin/hasil_investigasi_domain"
            if [ -d "$LAPORAN_DIR" ]; then
                files=$(ls "$LAPORAN_DIR"/*.txt 2>/dev/null)
                if [ -z "$files" ]; then
                    echo -e "${YELLOW}Tidak ada file hasil investigasi.${NC}"
                    sleep 2
                else
                    i=1
                    echo -e "${CYAN}Pilih file untuk dihapus:${NC}"
                    for file in $files; do
                        filename=$(basename "$file")
                        echo -e "${y}[${u}•$i${y}]${NC} $filename"
                        i=$((i+1))
                    done
                    echo -e "${y}[${u}•0${y}]${NC} Kembali ke menu"
                    echo ""
                    echo -e "${RED}Masukkan pilihan (atau 0 untuk kembali):${NC}"
                    read -p "> " choice
                    if [ "$choice" != "0" ]; then
                        file_count=$(echo "$files" | wc -l)
                        if [ "$choice" -ge 1 ] && [ "$choice" -le "$file_count" ]; then
                            selected_file=$(echo "$files" | sed -n "${choice}p")
                            echo -e "${RED}Anda yakin ingin menghapus file $selected_file? (y/n):${NC}"
                            read -p "> " confirm
                            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                                rm "$selected_file"
                                echo -e "${GREEN}File $selected_file telah dihapus.${NC}"
                            else
                                echo -e "${YELLOW}Penghapusan dibatalkan.${NC}"
                            fi
                            sleep 2
                        else
                            echo -e "${RED}Pilihan tidak valid!${NC}"
                            sleep 2
                        fi
                    fi
                fi
            else
                echo -e "${YELLOW}Direktori hasil_investigasi_domain tidak ditemukan.${NC}"
                sleep 2
            fi
            clear; investigasi_domain ;;
        0|00)  clear; exec "$0" ;;
        X|x)  clear; goodbye ;;
        *)  echo -e "${RED}Pilihan salah. Ulangi.${NC}"; sleep 1; exit 0 ;;
    esac
}

investigasi_file_html() {
    clear
    echo -e "${g}${NC}"
    echo -e "       ╭──────────────────────────────────────────╮"
    echo -e "       │${GB}          INVESTIGASI FILE HTML           ${NC}│"
    echo -e "       ╰──────────────────────────────────────────╯"
    echo -e "        ${r}┌─────────────────────────────────────────┐${NC}"
    echo -e "        ${r}│${y}[${u}•1${y}]${NC} HTML AUTO SAVE  ${r}│""${y}[${u}•4${y}]${NC} HAPUS HASIL   ${r}│"
    echo -e "        ${r}│${y}[${u}•2${y}]${NC} HTML NAMA KUSTOM${r}│""${y}[${u}•0${y}]${NC} BACK TO MENU  ${r}│"
    echo -e "        ${r}│${y}[${u}•3${y}]${NC} LIHAT HASIL     ${r}│""${y}[${u}•X${y}]${NC}  EXIT (0)     ${r}│"
    echo -e "        ${r}└─────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${CYAN}        ┌───(${YELLOW}Pilih${CYAN}─${YELLOW}Menu${RST}${CYAN})──[${YELLOW}1${CYAN}-${YELLOW}4${CYAN}]───▶️${RST}"
    read -p "        $(echo -e ${CYAN}└──▶️ ${NC}) " sess_opt
    echo ""
    case $sess_opt in
        01|1)  
            # Ambil HTML -> analisis -> laporan otomatis masuk folder hasil_analisis_html/
            clear ; ambil_html ; sleep 2 ; analisis_html -i hasil.html ; rm hasil.html ; exit 0 ;;

        02|2)  
            clear
            ambil_html
            sleep 2
            echo -e "${CYAN}Masukkan nama file output contoh report.txt:${NC}"
            read -p "output: " domain
            if [ -n "$domain" ]; then
                echo -e "${YELLOW}Menjalankan investigasi file html...${NC}"
                analisis_html -i hasil.html -o "$domain"
                rm hasil.html
                exit 0
            else
                echo -e "${RED}nama file output tidak boleh kosong!${NC}"
                sleep 2
            fi
            clear; exit 0 ;;
        03|3)  
            clear
            LAPORAN_DIR="/usr/local/bin/hasil_analisis_html"
            echo -e "${CYAN}Laporan HTML tersimpan di folder: ${YELLOW}${LAPORAN_DIR}/${NC}"
            if [ -d "$LAPORAN_DIR" ]; then
                files=$(ls "$LAPORAN_DIR"/*.txt 2>/dev/null)
                if [ -z "$files" ]; then
                    echo -e "${YELLOW}Tidak ada laporan HTML.${NC}"
                    sleep 2
                else
                    i=1
                    echo -e "${CYAN}Pilih laporan untuk ditampilkan:${NC}"
                    for file in $files; do
                        filename=$(basename "$file")
                        echo -e "${y}[${u}•$i${y}]${NC} $filename"
                        i=$((i+1))
                    done
                    echo -e "${y}[${u}•0${y}]${NC} Kembali ke menu"
                    echo ""
                    echo -e "${CYAN}Masukkan pilihan:${NC}"
                    read -p "> " choice
                    if [ "$choice" != "0" ]; then
                        file_count=$(echo "$files" | wc -l)
                        if [ "$choice" -ge 1 ] && [ "$choice" -le "$file_count" ]; then
                            selected_file=$(echo "$files" | sed -n "${choice}p")
                            echo -e "${CYAN}Isi laporan $selected_file:${NC}"
                            echo "========================================"
                            cat "$selected_file"
                            echo "========================================"
                            echo -e "${GREEN}Tekan Enter untuk kembali ke menu.${NC}"
                            read
                        else
                            echo -e "${RED}Pilihan tidak valid!${NC}"
                            sleep 2
                        fi
                    fi
                fi
            else
                echo -e "${YELLOW}Folder hasil_analisis_html belum ada — jalankan investigasi (1/2) dulu.${NC}"
                sleep 2
            fi
            clear; investigasi_file_html ;;
        04|4)  
            clear
            LAPORAN_DIR="/usr/local/bin/hasil_analisis_html"
            echo -e "${CYAN}Laporan HTML tersimpan di folder: ${YELLOW}${LAPORAN_DIR}/${NC}"
            if [ -d "$LAPORAN_DIR" ]; then
                files=$(ls "$LAPORAN_DIR"/*.txt 2>/dev/null)
                if [ -z "$files" ]; then
                    echo -e "${YELLOW}Tidak ada laporan HTML.${NC}"
                    sleep 2
                else
                    i=1
                    echo -e "${CYAN}Pilih laporan untuk dihapus:${NC}"
                    for file in $files; do
                        filename=$(basename "$file")
                        echo -e "${y}[${u}•$i${y}]${NC} $filename"
                        i=$((i+1))
                    done
                    echo -e "${y}[${u}•0${y}]${NC} Kembali ke menu"
                    echo ""
                    echo -e "${RED}Masukkan pilihan (atau 0 untuk kembali):${NC}"
                    read -p "> " choice
                    if [ "$choice" != "0" ]; then
                        file_count=$(echo "$files" | wc -l)
                        if [ "$choice" -ge 1 ] && [ "$choice" -le "$file_count" ]; then
                            selected_file=$(echo "$files" | sed -n "${choice}p")
                            echo -e "${RED}Anda yakin ingin menghapus $selected_file? (y/n):${NC}"
                            read -p "> " confirm
                            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                                rm "$selected_file"
                                echo -e "${GREEN}Laporan $selected_file telah dihapus.${NC}"
                            else
                                echo -e "${YELLOW}Penghapusan dibatalkan.${NC}"
                            fi
                            sleep 2
                        else
                            echo -e "${RED}Pilihan tidak valid!${NC}"
                            sleep 2
                        fi
                    fi
                fi
            else
                echo -e "${YELLOW}Folder hasil_analisis_html belum ada — jalankan investigasi (1/2) dulu.${NC}"
                sleep 2
            fi
            clear; investigasi_file_html ;;
        0|00)  clear; exec "$0" ;;
        X|x)  clear; goodbye ;;
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
echo -e "${CYAN} ║${drakgry}[${liggry}•1${drakgry}]${pth} DNS LOOKUP${NC}           ${CYAN}║${drakgry}[${liggry}11${drakgry}]${pth} IP TO HOST${NC}           ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•2${drakgry}]${pth} ABOUT DOMAIN${NC}         ${CYAN}║${drakgry}[${liggry}12${drakgry}]${pth} HOST TO IP${NC}           ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•3${drakgry}]${pth} DNS RECORDS${NC}          ${CYAN}║${drakgry}[${liggry}13${drakgry}]${pth} PING JARINGAN${NC}        ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•4${drakgry}]${pth} USER FINDER${NC}          ${CYAN}║${drakgry}[${liggry}14${drakgry}]${pth} ANTI SPAM${NC}            ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•5${drakgry}]${pth} TRACKER${NC}              ${CYAN}║${drakgry}[${liggry}15${drakgry}]${pth} SPAM DETECTOR${NC}        ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•6${drakgry}]${pth} SPAMING${NC}              ${CYAN}║${drakgry}[${liggry}16${drakgry}]${pth} CEK SUSPEND DOMAIN${NC}   ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•7${drakgry}]${pth} DDOS${NC}                 ${CYAN}║${drakgry}[${liggry}17${drakgry}]${pth} INVESTIGASI DOMAIN${NC}   ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•8${drakgry}]${pth} SUB DOMAIN FINDER${NC}    ${CYAN}║${drakgry}[${liggry}18${drakgry}]${pth} ANALISIS HTML WEBSITE${NC}${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}•9${drakgry}]${pth} KIRIM EMAIL${NC}          ${CYAN}║${drakgry}[${liggry}19${drakgry}]${pth} Kembali Ke Menu${NC}      ${CYAN}║${NC}"
echo -e "${CYAN} ║${drakgry}[${liggry}10${drakgry}]${pth} SPAMING POST${NC}         ${CYAN}║${drakgry}[${RED}•0${drakgry}]${RED} Kembali Ke Menu${NC}      ${CYAN}║${NC}"
echo -e "${CYAN} ╚═════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN} ┌───(${YELLOW}Masukkan${CYAN}─${YELLOW}Angka${RST}${CYAN})──[${YELLOW}1${CYAN}-${YELLOW}18${CYAN}]───▶️${RST}"
    read -p " $(echo -e ${CYAN}└──▶️ ${NC}) " plh
echo -e ""

case $plh in
1 | 01) lookup-dns ;;
2 | 02) clear ; plh_domain_about ;;
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
16) clear ; idadx_scan ;;
17) clear ; investigasi_domain ;;
18) clear ; investigasi_file_html ;;
x | X) clear ; goodbye ;;
*) echo "Pilihan tidak valid. Silakan masukkan angka dari 1 sampai 18.\n" ; loading ; mode-hack ;;
esac