#!/bin/bash

# ============================================================
#  Script : cek_service_bot.sh
#  Deskripsi : Mencari service systemd untuk bot.py
#  Path bot  : /home/filetelegram/bot.py
# ============================================================

# ──────────────────────────────────────────────
#  PALET WARNA
# ──────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'

# Teks biasa
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Teks tebal
BBLACK='\033[1;30m'
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BMAGENTA='\033[1;35m'
BCYAN='\033[1;36m'
BWHITE='\033[1;37m'

# Background
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# ──────────────────────────────────────────────
# Fungsi: Header utama
# ──────────────────────────────────────────────
tampil_header() {
    clear
    echo ""
    echo -e "${BG_BLUE}${BWHITE}                                                              ${RESET}"
    echo -e "${BG_BLUE}${BWHITE}    ███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗      ${RESET}"
    echo -e "${BG_BLUE}${BWHITE}    ██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝      ${RESET}"
    echo -e "${BG_BLUE}${BWHITE}    ███████╗█████╗  ██████╔╝██║   ██║██║██║     █████╗        ${RESET}"
    echo -e "${BG_BLUE}${BWHITE}    ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ██╔══╝        ${RESET}"
    echo -e "${BG_BLUE}${BWHITE}    ███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████╗      ${RESET}"
    echo -e "${BG_BLUE}${BWHITE}    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝      ${RESET}"
    echo -e "${BG_BLUE}${BWHITE}                                                              ${RESET}"
    echo -e "${BG_BLUE}${BCYAN}         🤖  CEK SERVICE SYSTEMD — BOT TELEGRAM  🤖           ${RESET}"
    echo -e "${BG_BLUE}${BWHITE}                                                              ${RESET}"
    echo ""
    echo -e "  ${BBLACK}┌─────────────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${BBLACK}│${RESET}  ${BYELLOW}📁 Path Bot :${RESET} ${BCYAN}/home/filetelegram/bot.py${RESET}                ${BBLACK}│${RESET}"
    echo -e "  ${BBLACK}└─────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

# ──────────────────────────────────────────────
# Fungsi: Menu
# ──────────────────────────────────────────────
tampil_menu() {
    echo -e "  ${BWHITE}╔═══════════════════════════════════════════════════════╗${RESET}"
    echo -e "  ${BWHITE}║${RESET}${BG_BLACK}              ${BMAGENTA}✦  MENU PENCARIAN  ✦                     ${RESET}${BWHITE}║${RESET}"
    echo -e "  ${BWHITE}╠═══════════════════════════════════════════════════════╣${RESET}"
    echo -e "  ${BWHITE}║${RESET}  ${BG_CYAN}${BWHITE} 1 ${RESET}  ${BCYAN}Cari file service (kata kunci bebas)${RESET}            ${BWHITE}║${RESET}"
    echo -e "  ${BWHITE}║${RESET}  ${BG_CYAN}${BWHITE} 2 ${RESET}  ${BCYAN}Cari service berdasarkan path/nama file${RESET}         ${BWHITE}║${RESET}"
    echo -e "  ${BWHITE}║${RESET}  ${BG_GREEN}${BWHITE} 3 ${RESET}  ${BGREEN}Lihat service AKTIF (kata kunci bebas)${RESET}          ${BWHITE}║${RESET}"
    echo -e "  ${BWHITE}║${RESET}  ${BG_GREEN}${BWHITE} 4 ${RESET}  ${BGREEN}Lihat SEMUA service aktif & nonaktif${RESET}            ${BWHITE}║${RESET}"
    echo -e "  ${BWHITE}║${RESET}  ${BG_YELLOW}${BWHITE} 5 ${RESET}  ${BYELLOW}Cari proses berjalan (ps aux)${RESET}                   ${BWHITE}║${RESET}"
    echo -e "  ${BWHITE}║${RESET}  ${BG_MAGENTA}${BWHITE} 6 ${RESET}  ${BMAGENTA}Jalankan SEMUA pencarian sekaligus${RESET}              ${BWHITE}║${RESET}"
    echo -e "  ${BWHITE}║${RESET}  ${BG_BLUE}${BWHITE} 7 ${RESET}  ${BBLUE}Cek status service (input nama manual)${RESET}          ${BWHITE}║${RESET}"
    echo -e "  ${BWHITE}║${RESET}  ${BG_RED}${BWHITE} 0 ${RESET}  ${BRED}Keluar${RESET}                                          ${BWHITE}║${RESET}"
    echo -e "  ${BWHITE}╚═══════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -ne "  ${BYELLOW}❯❯❯ ${BWHITE}Masukkan pilihan ${BCYAN}[0-7]${BWHITE}: ${RESET}"
}

# ──────────────────────────────────────────────
# Fungsi: Garis pemisah
# ──────────────────────────────────────────────
garis() {
    echo ""
    echo -e "  ${BBLACK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# ──────────────────────────────────────────────
# Fungsi: Tekan enter untuk lanjut
# ──────────────────────────────────────────────
lanjut() {
    echo ""
    echo -e "  ${BG_BLACK}${BYELLOW}  ↩  Tekan [Enter] untuk kembali ke menu...  ${RESET}"
    read
}

# ──────────────────────────────────────────────
# Fungsi: Badge judul sub-menu
# ──────────────────────────────────────────────
badge() {
    local WARNA="$1"
    local LABEL="$2"
    echo ""
    echo -e "  ${WARNA}${BLACK}  ${LABEL}  ${RESET}"
    echo ""
}

# ──────────────────────────────────────────────
# Fungsi: Tampilkan hasil
# ──────────────────────────────────────────────
tampil_hasil() {
    local HASIL="$1"
    local LABEL_KOSONG="$2"
    if [ -z "$HASIL" ]; then
        echo -e "  ${BG_RED}${BWHITE}  ✘  ${LABEL_KOSONG}  ${RESET}"
    else
        echo -e "  ${BGREEN}✔ Ditemukan:${RESET}"
        echo ""
        echo "$HASIL" | while IFS= read -r LINE; do
            echo -e "     ${BCYAN}➤  ${LINE}${RESET}"
        done
    fi
}

# ══════════════════════════════════════════════
#  MENU 1 — Cari file service, kata kunci bebas
# ══════════════════════════════════════════════
menu_1() {
    tampil_header
    badge "${BG_CYAN}" "🔎  CARI FILE SERVICE — KATA KUNCI BEBAS"

    read -p "$(echo -e "  ${BYELLOW}Masukkan kata kunci pencarian${RESET} (default: bot): ")" INPUT_KEY
    local KEY="${INPUT_KEY:-bot}"

    garis
    echo -e "  ${BWHITE}Mencari file service yang menyebut: ${BCYAN}\"${KEY}\"${RESET}"
    echo ""

    HASIL=$(grep -rl "${KEY}" /etc/systemd/system/ 2>/dev/null)
    tampil_hasil "$HASIL" "Tidak ditemukan service yang menyebut '${KEY}'"

    lanjut
}

# ══════════════════════════════════════════════
#  MENU 2 — Cari berdasarkan path / nama file
# ══════════════════════════════════════════════
menu_2() {
    tampil_header
    badge "${BG_CYAN}" "📂  CARI SERVICE BERDASARKAN PATH / NAMA FILE"

    read -p "$(echo -e "  ${BYELLOW}Masukkan nama file atau path${RESET} (default: bot.py): ")" INPUT_FILE
    local FILE="${INPUT_FILE:-bot.py}"

    garis
    echo -e "  ${BWHITE}Mencari service yang menyebut: ${BCYAN}\"${FILE}\"${RESET}"
    echo ""

    HASIL=$(grep -rl "${FILE}" /etc/systemd/system/ 2>/dev/null)

    if [ -z "$HASIL" ]; then
        echo -e "  ${BG_RED}${BWHITE}  ✘  Tidak ditemukan service yang menyebut '${FILE}'  ${RESET}"
    else
        echo -e "  ${BGREEN}✔ Ditemukan file service berikut:${RESET}"
        echo ""
        echo "$HASIL" | while IFS= read -r LINE; do
            echo -e "     ${BCYAN}➤  ${LINE}${RESET}"
            echo ""
            echo -e "     ${BYELLOW}┌── Isi file: ${LINE}${RESET}"
            cat "$LINE" 2>/dev/null | while IFS= read -r ISI; do
                echo -e "     ${BBLACK}│${RESET}  ${WHITE}${ISI}${RESET}"
            done
            echo -e "     ${BYELLOW}└──────────────────${RESET}"
            echo ""
        done
    fi

    lanjut
}

# ══════════════════════════════════════════════
#  MENU 3 — Service AKTIF, kata kunci bebas
# ══════════════════════════════════════════════
menu_3() {
    tampil_header
    badge "${BG_GREEN}" "✅  LIHAT SERVICE AKTIF — KATA KUNCI BEBAS"

    read -p "$(echo -e "  ${BYELLOW}Masukkan kata kunci${RESET} (default: bot): ")" INPUT_KEY
    local KEY="${INPUT_KEY:-bot}"

    garis
    echo -e "  ${BWHITE}Mencari service AKTIF yang mengandung: ${BGREEN}\"${KEY}\"${RESET}"
    echo ""

    HASIL=$(systemctl list-units --type=service 2>/dev/null | grep -i "${KEY}")
    tampil_hasil "$HASIL" "Tidak ada service aktif yang mengandung '${KEY}'"

    lanjut
}

# ══════════════════════════════════════════════
#  MENU 4 — SEMUA service (aktif & nonaktif)
# ══════════════════════════════════════════════
menu_4() {
    tampil_header
    badge "${BG_GREEN}" "📋  SEMUA SERVICE (AKTIF & NONAKTIF) — KATA KUNCI BEBAS"

    read -p "$(echo -e "  ${BYELLOW}Masukkan kata kunci${RESET} (default: bot): ")" INPUT_KEY
    local KEY="${INPUT_KEY:-bot}"

    garis
    echo -e "  ${BWHITE}Mencari SEMUA service yang mengandung: ${BGREEN}\"${KEY}\"${RESET}"
    echo ""

    HASIL=$(systemctl list-units --type=service --all 2>/dev/null | grep -i "${KEY}")
    tampil_hasil "$HASIL" "Tidak ada service (aktif/nonaktif) yang mengandung '${KEY}'"

    lanjut
}

# ══════════════════════════════════════════════
#  MENU 5 — Proses berjalan via ps aux
# ══════════════════════════════════════════════
menu_5() {
    tampil_header
    badge "${BG_YELLOW}" "⚙️   CARI PROSES BERJALAN — PS AUX"

    read -p "$(echo -e "  ${BYELLOW}Masukkan nama proses/file${RESET} (default: bot.py): ")" INPUT_PROC
    local PROC="${INPUT_PROC:-bot.py}"

    garis
    echo -e "  ${BWHITE}Mencari proses yang berjalan: ${BYELLOW}\"${PROC}\"${RESET}"
    echo ""

    HASIL=$(ps aux 2>/dev/null | grep "${PROC}" | grep -v grep)

    if [ -z "$HASIL" ]; then
        echo -e "  ${BG_RED}${BWHITE}  ✘  Tidak ada proses '${PROC}' yang sedang berjalan  ${RESET}"
    else
        echo -e "  ${BGREEN}✔ Proses ditemukan:${RESET}"
        echo ""
        echo -e "  ${BBLACK}┌──────────────────────────────────────────────────────────${RESET}"
        echo -e "  ${BBLACK}│${RESET} ${BWHITE}USER        PID   %CPU %MEM   COMMAND${RESET}"
        echo -e "  ${BBLACK}├──────────────────────────────────────────────────────────${RESET}"
        echo "$HASIL" | while IFS= read -r LINE; do
            PID=$(echo "$LINE" | awk '{print $2}')
            echo -e "  ${BBLACK}│${RESET} ${BYELLOW}${LINE}${RESET}"
            echo -e "  ${BBLACK}│${RESET}"
            echo -e "  ${BBLACK}│${RESET}  ${BCYAN}↳ Cek service PID ${PID}:${RESET}"
            systemctl status "$PID" 2>/dev/null | head -4 | while IFS= read -r SVC; do
                echo -e "  ${BBLACK}│${RESET}    ${WHITE}${SVC}${RESET}"
            done
            echo -e "  ${BBLACK}│${RESET}"
        done
        echo -e "  ${BBLACK}└──────────────────────────────────────────────────────────${RESET}"
    fi

    lanjut
}

# ══════════════════════════════════════════════
#  MENU 6 — Jalankan SEMUA pencarian sekaligus
# ══════════════════════════════════════════════
menu_6() {
    tampil_header
    badge "${BG_MAGENTA}" "🚀  SEMUA PENCARIAN SEKALIGUS"

    echo -e "  ${BWHITE}Menggunakan kata kunci default: ${BCYAN}bot / bot.py${RESET}"
    garis

    # --- [1] ---
    echo -e "  ${BG_CYAN}${BLACK}  1  ${RESET}  ${BCYAN}File service menyebut 'bot':${RESET}"
    H=$(grep -rl "bot" /etc/systemd/system/ 2>/dev/null)
    if [ -z "$H" ]; then echo -e "       ${BRED}✘ Tidak ditemukan${RESET}"; else echo "$H" | sed "s/^/       ${BCYAN}➤ /"; echo -e "${RESET}"; fi
    echo ""

    # --- [2] ---
    echo -e "  ${BG_CYAN}${BLACK}  2  ${RESET}  ${BCYAN}Service menyebut 'bot.py':${RESET}"
    H=$(grep -rl "bot\.py" /etc/systemd/system/ 2>/dev/null)
    if [ -z "$H" ]; then echo -e "       ${BRED}✘ Tidak ditemukan${RESET}"; else echo "$H" | sed "s/^/       ${BCYAN}➤ /"; echo -e "${RESET}"; fi
    echo ""

    # --- [3] ---
    echo -e "  ${BG_GREEN}${BLACK}  3  ${RESET}  ${BGREEN}Service AKTIF mengandung 'bot':${RESET}"
    H=$(systemctl list-units --type=service 2>/dev/null | grep -i "bot")
    if [ -z "$H" ]; then echo -e "       ${BRED}✘ Tidak ada${RESET}"; else echo "$H" | sed "s/^/       ${BGREEN}➤ /"; echo -e "${RESET}"; fi
    echo ""

    # --- [4] ---
    echo -e "  ${BG_GREEN}${BLACK}  4  ${RESET}  ${BGREEN}SEMUA service (aktif+nonaktif) mengandung 'bot':${RESET}"
    H=$(systemctl list-units --type=service --all 2>/dev/null | grep -i "bot")
    if [ -z "$H" ]; then echo -e "       ${BRED}✘ Tidak ada${RESET}"; else echo "$H" | sed "s/^/       ${BGREEN}➤ /"; echo -e "${RESET}"; fi
    echo ""

    # --- [5] ---
    echo -e "  ${BG_YELLOW}${BLACK}  5  ${RESET}  ${BYELLOW}Proses berjalan 'bot.py':${RESET}"
    H=$(ps aux 2>/dev/null | grep "bot.py" | grep -v grep)
    if [ -z "$H" ]; then echo -e "       ${BRED}✘ Tidak ada proses${RESET}"; else echo "$H" | sed "s/^/       ${BYELLOW}➤ /"; echo -e "${RESET}"; fi
    echo ""

    garis
    echo -e "  ${BG_GREEN}${BWHITE}  ✔  Semua pencarian selesai!  ${RESET}"

    lanjut
}

# ══════════════════════════════════════════════
#  MENU 7 — Cek status service manual
# ══════════════════════════════════════════════
menu_7() {
    tampil_header
    badge "${BG_BLUE}" "🛠️   CEK STATUS SERVICE — INPUT MANUAL"

    read -p "$(echo -e "  ${BYELLOW}Masukkan nama service${RESET} (contoh: mybot atau mybot.service): ")" NAMA_SERVICE

    if [ -z "$NAMA_SERVICE" ]; then
        echo -e "  ${BG_RED}${BWHITE}  ✘  Nama service tidak boleh kosong!  ${RESET}"
    else
        [[ "$NAMA_SERVICE" != *.service ]] && NAMA_SERVICE="${NAMA_SERVICE}.service"
        garis
        echo -e "  ${BWHITE}Menjalankan: ${BCYAN}systemctl status ${NAMA_SERVICE}${RESET}"
        echo ""
        systemctl status "$NAMA_SERVICE" 2>&1 | while IFS= read -r LINE; do
            echo -e "  ${WHITE}${LINE}${RESET}"
        done
    fi

    lanjut
}

# ══════════════════════════════════════════════
#  MAIN LOOP
# ══════════════════════════════════════════════
tampil_header
tampil_menu
read PILIHAN

    case $PILIHAN in
        1) menu_1 ;;
        2) menu_2 ;;
        3) menu_3 ;;
        4) menu_4 ;;
        5) menu_5 ;;
        6) menu_6 ;;
        7) menu_7 ;;
        0)
            clear
            echo ""
            newmenu
            ;;
        *)
            echo ""
            echo -e "  ${BG_RED}${BWHITE}  ✘  Pilihan tidak valid! Silakan pilih 0–7.  ${RESET}"
            sleep 1
            exit 1
            ;;
done
    esac