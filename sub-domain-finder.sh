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
log() { echo -e "\e[32m[+] $1\e[0m"; }
warn() { echo -e "\e[33m[!] $1\e[0m"; }
err() { echo -e "\e[31m[-] $1\e[0m"; }

function check_go() {
    if command -v go >/dev/null 2>&1; then
        echo "✅ Go sudah terinstall"
        echo "Versi: $(go version)"
        return 0
    else
        echo "❌ Go belum terinstall"
        sleep 3
        clear
        echo "✅ Mencoba menginstall Go..."
        install-domain-finder
        return 0
    fi  
}


run_recon() {
    
    echo -e "\n\033[1;33mMasukkan Domain:\033[0m"
    read -p "➤ "  DOMAIN

    if [ -z "$DOMAIN" ]; then
        echo -e "\033[1;31m Domain tidak boleh kosong! \033[0m"
        exit 1
    fi
    OUTPUT_DIR="./recon-output"
        # Cek apakah folder sudah ada
    if [ -d "$OUTPUT_DIR" ]; then
        echo ""
    else
        mkdir -p "$OUTPUT_DIR"
        echo "Folder '$OUTPUT_DIR' berhasil dibuat."
    fi
    DATE=$(date +%F)

    log "Starting recon for $DOMAIN"

    # Subdomain enum
    log "Subdomain enumeration..."
    subfinder -d $DOMAIN -silent > $OUTPUT_DIR/subfinder-$DOMAIN.txt
    assetfinder --subs-only $DOMAIN >> $OUTPUT_DIR/subfinder-$DOMAIN.txt

    sort -u $OUTPUT_DIR/subfinder-$DOMAIN.txt > $OUTPUT_DIR/subs-$DOMAIN.txt

    # Alive check
    log "Checking alive hosts..."
    httpx -l $OUTPUT_DIR/subs-$DOMAIN.txt -silent -o $OUTPUT_DIR/alive-$DOMAIN.txt

    # Port scan
    log "Scanning ports..."
    naabu -l $OUTPUT_DIR/alive-$DOMAIN.txt -silent -o $OUTPUT_DIR/ports-$DOMAIN.txt

    # Vulnerability scan
    log "Running nuclei..."
    nuclei -l $OUTPUT_DIR/alive-$DOMAIN.txt -severity low,medium,high,critical -o $OUTPUT_DIR/vuln-$DOMAIN.txt

    log "Recon completed for $DOMAIN"
    log "Results saved in: $OUTPUT_DIR"
}

function fn_lihat_hasil_scan() {
    clear
    echo -e "\033[1;32m========================================\033[0m"
    echo -e "\033[1;36m           HASIL SCAN DOMAIN          \033[0m"
    echo -e "\033[1;32m========================================\033[0m"


    OUTPUT_DIR="./recon-output"
        # Cek apakah folder sudah ada
    if [ -d "$OUTPUT_DIR" ]; then
        echo ""
    else
        mkdir -p "$OUTPUT_DIR"
        echo "Folder '$OUTPUT_DIR' berhasil dibuat."
    fi

    echo -e "\033[1;33m[+] Mengecek hasil scan di folder: $OUTPUT_DIR\033[0m\n"

    # Cek apakah ada file hasil
    if [ -z "$(ls -A $OUTPUT_DIR/*.txt 2>/dev/null)" ]; then
        echo -e "\033[1;33mBelum ada hasil scan.\033[0m"
        echo -e "Silakan lakukan scan domain terlebih dahulu."
        read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali..."
        return 1
    fi

    echo -e "\033[1;36mDaftar Hasil Scan:\033[0m"
    echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    # Tampilkan daftar file hasil
    ls -1 "$OUTPUT_DIR"/*.txt 2>/dev/null | nl -s ') ' | sed 's|.txt||g'

    echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # Pilih file
    read -rp "Masukkan nomor hasil yang ingin dilihat: " nomor

    file=$(ls -1 "$OUTPUT_DIR"/*.txt 2>/dev/null | sed -n "${nomor}p")

    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo -e "\033[1;31mNomor yang Anda masukkan salah!\033[0m"
    else
        echo -e "\033[1;32mMenampilkan hasil:\033[0m $(basename "$file")"
        echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        cat "$file"
        echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    fi
}

echo -e "${L_GREEN}"
cat << "EOF"
           _           _                       _          __ _           _           
 ___ _   _| |__     __| | ___  _ __ ___   __ _(_)_ __    / _(_)_ __   __| | ___ _ __ 
/ __| | | | '_ \   / _` |/ _ \| '_ ` _ \ / _` | | '_ \  | |_| | '_ \ / _` |/ _ \ '__|
\__ \ |_| | |_) | | (_| | (_) | | | | | | (_| | | | | | |  _| | | | | (_| |  __/ |   
|___/\__,_|_.__/   \__,_|\___/|_| |_| |_|\__,_|_|_| |_| |_| |_|_| |_|\__,_|\___|_|   
                  
                 [ DOMAIN - FINDER v2.0 ]
                 DOMAIN SCANNING PROTOCOL
EOF
echo -e "${NC}"

echo -e " ${GRAY}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e " ${GRAY}║${L_CYAN}               SYSTEM ACCESS TERMINAL v2.0                  ${GRAY}║${NC}"
echo -e " ${GRAY}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e " ${GRAY}║${L_GREEN} [${CYAN}1${L_GREEN}]${NC} ${YELLOW}Install Domain Finder${NC}                                  ${GRAY}║${NC}"
echo -e " ${GRAY}║${L_GREEN} [${CYAN}2${L_GREEN}]${NC} ${YELLOW}Sub Domain Finder${NC}                                      ${GRAY}║${NC}"
echo -e " ${GRAY}║${L_GREEN} [${CYAN}3${L_GREEN}]${NC} ${YELLOW}Lihat Hasil Finder${NC}                                     ${GRAY}║${NC}"
echo -e " ${GRAY}║${L_GREEN} [${RED}0${L_GREEN}]${NC} ${RED}Kembali ke Menu Utama${NC}                                  ${GRAY}║${NC}"
#echo -e " ${GRAY}║${L_GREEN} [${CYAN}4${L_GREEN}]${NC} ${YELLOW}Scan + Save file${NC}                                                    ${GRAY}║${NC}"
#echo -e " ${GRAY}║${L_GREEN} [${CYAN}5${L_GREEN}]${NC} ${YELLOW}Scan + Proxy${NC}                                                            ${GRAY}║${NC}"
echo -e " ${GRAY}╚════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e " ${L_CYAN}┌──(${L_RED}root${L_CYAN}@${YELLOW}mamat${L_CYAN})─[${L_GREEN}domain-finder${L_CYAN}]${NC}"
echo -e -n " ${L_CYAN}└──▶️ ${NC}"
read -p "" plh
echo -e ""

case $plh in
1 | 01) clear ; check_go ;;
2 | 02) run_recon ;;
3 | 03) fn_lihat_hasil_scan ;;
0 | 00) clear ; newmenu ;;
x | X) clear ; echo -e "${L_RED}[!] DISCONNECTING FROM MATRIX...${NC}" ; exit 0 ;;
*) echo -e "${L_RED}[ERROR] Pilihan tidak valid.${NC}" ; sleep 2 ; clear ; m-domain-finder ;;
esac