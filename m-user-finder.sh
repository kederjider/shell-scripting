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

function fn_scan_cepat() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     SHERLOCK USERNAME FINDER\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    # Cek apakah sherlock sudah terinstall
    if ! command -v sherlock &> /dev/null; then
        echo -e "\033[1;31m[ERROR] Sherlock belum terinstall!\033[0m"
        echo -e "Silakan install terlebih dahulu dengan perintah:"
        echo -e "   pipx install sherlock-project"
        exit 1
    fi

    echo -e "\n\033[1;33mMasukkan username yang ingin dicari:\033[0m"
    read -p "➤ " username

    if [ -z "$username" ]; then
        echo -e "\033[1;31mUsername tidak boleh kosong!\033[0m"
        exit 1
    fi
    echo -e "\033[1;32m[+] Menjalankan scan cepat...\033[0m"
    sherlock "$username" --no-txt
}

function fn_hasil_scan() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     SHERLOCK - HASIL SCAN USERNAME\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    # Cek apakah sherlock terinstall
    if ! command -v sherlock &> /dev/null; then
        echo -e "\033[1;31m[ERROR] Sherlock belum terinstall!\033[0m"
        echo -e "Install dulu dengan: pipx install sherlock-project"
        read -n 1 -s -r -p "Tekan tombol apa saja untuk keluar..."
        return 1
    fi

    FOLDER="./hasil-sherlock"
        # Cek apakah folder sudah ada
    if [ -d "$FOLDER" ]; then
        echo ""
    else
        mkdir -p "$FOLDER"
        echo "Folder '$FOLDER' berhasil dibuat."
    fi

    echo -e "\033[1;33m[+] Mengecek hasil scan di folder: $FOLDER\033[0m\n"

    # Cek apakah ada file hasil
    if [ -z "$(ls -A $FOLDER/*.txt 2>/dev/null)" ]; then
        echo -e "\033[1;33mBelum ada hasil scan.\033[0m"
        echo -e "Silakan lakukan scan username terlebih dahulu."
        read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali..."
        return 1
    fi

    echo -e "\033[1;36mDaftar Hasil Scan:\033[0m"
    echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    # Tampilkan daftar file hasil
    ls -1 "$FOLDER"/*.txt 2>/dev/null | nl -s ') ' | sed 's|.txt||g'

    echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # Pilih file
    read -rp "Masukkan nomor hasil yang ingin dilihat: " nomor

    file=$(ls -1 "$FOLDER"/*.txt 2>/dev/null | sed -n "${nomor}p")

    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo -e "\033[1;31mNomor yang Anda masukkan salah!\033[0m"
    else
        echo -e "\033[1;32mMenampilkan hasil:\033[0m $(basename "$file")"
        echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        cat "$file"
        echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    fi
}


function fn_scan_simpan() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     SHERLOCK USERNAME FINDER\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    # Cek apakah sherlock sudah terinstall
    if ! command -v sherlock &> /dev/null; then
        echo -e "\033[1;31m[ERROR] Sherlock belum terinstall!\033[0m"
        echo -e "Silakan install terlebih dahulu dengan perintah:"
        echo -e "   pipx install sherlock-project"
        exit 1
    fi

    echo -e "\n\033[1;33mMasukkan username yang ingin dicari:\033[0m"
    read -p "➤ " username

    if [ -z "$username" ]; then
        echo -e "\033[1;31mUsername tidak boleh kosong!\033[0m"
        exit 1
    fi
    FOLDER="./hasil-sherlock"

    # Cek apakah folder sudah ada
    if [ -d "$FOLDER" ]; then
        echo ""
    else
        mkdir -p "$FOLDER"
        echo "Folder '$FOLDER' berhasil dibuat."
    fi
    echo -e "\033[1;32m[+] Menjalankan scan dan menyimpan hasil...\033[0m"
    filename="${FOLDER}/${username}_$(date +%Y%m%d_%H%M).txt"
    sherlock "$username" -o "$filename"
    echo -e "\033[1;32m[✔] Hasil disimpan di: $filename\033[0m"
}

function fn_scan_proxy() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     SHERLOCK USERNAME FINDER\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    # Cek apakah sherlock sudah terinstall
    if ! command -v sherlock &> /dev/null; then
        echo -e "\033[1;31m[ERROR] Sherlock belum terinstall!\033[0m"
        echo -e "Silakan install terlebih dahulu dengan perintah:"
        echo -e "   pipx install sherlock-project"
        exit 1
    fi

    echo -e "\n\033[1;33mMasukkan username yang ingin dicari:\033[0m"
    read -p "➤ " username

    if [ -z "$username" ]; then
        echo -e "\033[1;31mUsername tidak boleh kosong!\033[0m"
        exit 1
    fi
    echo -e "\033[1;32m[+] Menjalankan scan dengan proxy...\033[0m"
    sherlock "$username" --tor
}

function fn_scan_param() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     SHERLOCK USERNAME FINDER\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    # Cek apakah sherlock sudah terinstall
    if ! command -v sherlock &> /dev/null; then
        echo -e "\033[1;31m[ERROR] Sherlock belum terinstall!\033[0m"
        echo -e "Silakan install terlebih dahulu dengan perintah:"
        echo -e "   pipx install sherlock-project"
        exit 1
    fi

    echo -e "\n\033[1;33mMasukkan username yang ingin dicari:\033[0m"
    read -p "➤ " username

    if [ -z "$username" ]; then
        echo -e "\033[1;31mUsername tidak boleh kosong!\033[0m"
        exit 1
    fi
    echo -e "\033[1;33mMasukkan parameter tambahan (contoh: --timeout 10 -o hasil.txt):\033[0m"
    read -p "➤ " param
    sherlock "$username" $param
}

function fn_scan_site() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     SHERLOCK USERNAME FINDER\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    # Cek apakah sherlock sudah terinstall
    if ! command -v sherlock &> /dev/null; then
        echo -e "\033[1;31m[ERROR] Sherlock belum terinstall!\033[0m"
        echo -e "Silakan install terlebih dahulu dengan perintah:"
        echo -e "   pipx install sherlock-project"
        exit 1
    fi

    echo -e "\n\033[1;33mMasukkan username yang ingin dicari:\033[0m"
    read -p "➤ " username

    if [ -z "$username" ]; then
        echo -e "\033[1;31mUsername tidak boleh kosong!\033[0m"
        exit 1
    fi
    echo -e "\033[1;33mMasukkan situs yang ingin dicari (contoh: github, dll):\033[0m"
    read -p "➤ " param
    sherlock "$username" --site $param
}

function fn_scan_site_all() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     SHERLOCK USERNAME FINDER\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    # Cek apakah sherlock sudah terinstall
    if ! command -v sherlock &> /dev/null; then
        echo -e "\033[1;31m[ERROR] Sherlock belum terinstall!\033[0m"
        echo -e "Silakan install terlebih dahulu dengan perintah:"
        echo -e "   pipx install sherlock-project"
        exit 1
    fi

    echo -e "\n\033[1;33mMasukkan username yang ingin dicari:\033[0m"
    read -p "➤ " username

    if [ -z "$username" ]; then
        echo -e "\033[1;31mUsername tidak boleh kosong!\033[0m"
        exit 1
    fi
    sherlock "$username" --print-all
}

function fn_scan_site_no_txt() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m     SHERLOCK USERNAME FINDER\033[0m"
    echo -e "\033[1;32m========================================\033[0m"

    # Cek apakah sherlock sudah terinstall
    if ! command -v sherlock &> /dev/null; then
        echo -e "\033[1;31m[ERROR] Sherlock belum terinstall!\033[0m"
        echo -e "Silakan install terlebih dahulu dengan perintah:"
        echo -e "   pipx install sherlock-project"
        exit 1
    fi

    echo -e "\n\033[1;33mMasukkan username yang ingin dicari:\033[0m"
    read -p "➤ " username

    if [ -z "$username" ]; then
        echo -e "\033[1;31mUsername tidak boleh kosong!\033[0m"
        exit 1
    fi
    sherlock "$username" --no-txt
}

echo -e "${L_GREEN}"
cat << "EOF"
                         ___ _           _
   _   _ ___  ___ _ __  / __(_)_ __   __| | ___ _ __ 
  | | | / __|/ _ \ '__| | |_| | '_ \ / _` |/ _ \ '__| 
  | |_| \__ \  __/ |    | __| | | | || (_| | __/ | 
   \__,_|___/\___|_|    |_| |_|_| |_|\__,_|\___|_| 
                  
                 [ USER - FINDER v4.20 ]
                 MAMAT SCANNING PROTOCOL
EOF
echo -e "${NC}"

echo -e "${GRAY}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GRAY}║${L_CYAN}               SYSTEM ACCESS TERMINAL v4.20                 ${GRAY}║${NC}"
echo -e "${GRAY}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}1${L_GREEN}]${NC} ${YELLOW}Install User Finder${NC}     ${GRAY}║${L_GREEN} [${CYAN}6${L_GREEN}]${NC} ${YELLOW}Custom (ketik manual)${NC}    ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}2${L_GREEN}]${NC} ${YELLOW}Scan Cepat (No Save)${NC}    ${GRAY}║${L_GREEN} [${CYAN}7${L_GREEN}]${NC} ${YELLOW}Scan Site Tertentu${NC}       ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}3${L_GREEN}]${NC} ${YELLOW}Scan Site (No Save)${NC}     ${GRAY}║${L_GREEN} [${CYAN}8${L_GREEN}]${NC} ${YELLOW}Scan Semua Situs${NC}         ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}4${L_GREEN}]${NC} ${YELLOW}Scan + Save file${NC}        ${GRAY}║${L_GREEN} [${CYAN}9${L_GREEN}]${NC} ${YELLOW}Lihat Hasil Scan${NC}         ${GRAY}║${NC}"
echo -e "${GRAY}║${L_GREEN} [${CYAN}5${L_GREEN}]${NC} ${YELLOW}Scan + Proxy${NC}            ${GRAY}║${L_GREEN} [${RED}0${L_GREEN}]${NC} ${RED}Kembali ke Menu Utama${NC}   ${GRAY}║${NC}"
echo -e "${GRAY}╚════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${L_CYAN}┌──(${L_RED}root${L_CYAN}@${YELLOW}mamat${L_CYAN})─[${L_GREEN}user-finder${L_CYAN}]${NC}"
echo -e -n "${L_CYAN}└──▶️ ${NC}"
read -p "" plh
echo -e ""

case $plh in
1 | 01) install-sherlock ;;
2 | 02) fn_scan_cepat ;;
3 | 03) fn_scan_site_no_txt ;;
4 | 04) fn_scan_simpan ;;
5 | 05) fn_scan_proxy ;;
6 | 06) fn_scan_param ;;
7 | 07) fn_scan_site ;;
8 | 08) fn_scan_site_all ;;
9 | 09) fn_hasil_scan ;;
0 | 00) clear ; newmenu ;;
x | X) clear ; echo -e "${L_RED}[!] DISCONNECTING FROM MATRIX...${NC}" ; exit 0 ;;
*) echo -e "${L_RED}[ERROR] Pilihan tidak valid.${NC}" ; sleep 1 ; clear ; exec "$0" ;;
esac