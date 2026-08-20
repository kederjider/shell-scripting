#!/bin/bash

# ═══════════════════════════════════════════════════════════
#   📧  SPAM DISK  -  MENU INTERAKTIF v1.0
# ═══════════════════════════════════════════════════════════
#   🚀 Jalankan diskfill_data1.py dengan parameter URL & Cookie
# ═══════════════════════════════════════════════════════════
# 🎨 KONFIGURASI WARNA
# ─────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Warna teks
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[2;37m'

# Warna background
BG_BLUE='\033[44m'
BG_CYAN='\033[46m'
BG_GREEN='\033[42m'
BG_RED='\033[41m'

# Badge status
OK="${GREEN}✔${RESET}"
FAIL="${RED}✘${RESET}"
WARN="${YELLOW}⚠${RESET}"
INFO="${CYAN}ℹ${RESET}"

# ─────────────────────────────────────────────
# 📁 KONFIGURASI FILE
# ─────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HISTORY_FILE="${SCRIPT_DIR}/history_diskfill.txt"
PYTHON_SCRIPT="${SCRIPT_DIR}/diskfill_data1"

# ─────────────────────────────────────────────
# 🧩 FUNGSI UTILITAS
# ─────────────────────────────────────────────

# Banner utama
print_banner() {
    clear
    echo
    printf "${CYAN}  ╔══════════════════════════════════════════════════════════╗${RESET}\n"
    printf "${CYAN}  ║${RESET}${BG_CYAN}${WHITE}      📧  S P A M   D I S K   -   M E N U                 ${RESET}${CYAN}║${RESET}\n"
    printf "${CYAN}  ║${RESET}${BG_BLUE}${BOLD}      🚀  Kirim payload spam dengan URL & Cookie          ${RESET}${CYAN}║${RESET}\n"
    printf "${CYAN}  ╚══════════════════════════════════════════════════════════╝${RESET}\n"
    echo
}

# Header sub-menu
print_header() {
    local title="$1"
    echo
    printf "${CYAN}  ┌─${RESET}${BG_BLUE}${WHITE} %-54s ${RESET}${CYAN}─┐${RESET}\n" "$title"
    printf "${CYAN}  └──────────────────────────────────────────────────────────┘${RESET}\n"
    echo
}

# Menu utama
show_menu() {
    print_banner

    printf "${CYAN}  ┌──────────────────────────────────────────────────────────┐${RESET}\n"
    printf "${CYAN}  │${RESET} ${WHITE}${BOLD}    📧 SPAM DISK - MENU UTAMA                            ${RESET}${CYAN}│${RESET}\n"
    printf "${CYAN}  ├──────────────────────────────────────────────────────────┤${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[1]${RESET} ${YELLOW}🚀${RESET}  ${WHITE}Jalankan Spam Disk (Input Manual)${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[2]${RESET} ${YELLOW}📋${RESET}  ${WHITE}Jalankan Spam Disk (Dari History)${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[3]${RESET} ${YELLOW}🗑️${RESET}   ${WHITE}Hapus History${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[0]${RESET} ${YELLOW}🏠${RESET}  ${WHITE}Menu Utama (newmenu)${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[x]${RESET} ${YELLOW}🚪${RESET}  ${WHITE}Keluar${RESET}\n"
    printf "${CYAN}  ├──────────────────────────────────────────────────────────┤${RESET}\n"
    printf "${CYAN}  │${RESET} ${WHITE}${BOLD}❓ Pilihan Anda:${RESET} ${RESET}"
    read -r pilihan
    printf "${CYAN}  └──────────────────────────────────────────────────────────┘${RESET}\n"
}

# Pesan status
msg() {
    local type="$1"
    local text="$2"
    case "$type" in
        ok)   printf "  ${OK}  %s\n" "$text" ;;
        fail) printf "  ${FAIL}  ${RED}%s${RESET}\n" "$text" ;;
        warn) printf "  ${WARN}  ${YELLOW}%s${RESET}\n" "$text" ;;
        info) printf "  ${INFO}  ${CYAN}%s${RESET}\n" "$text" ;;
    esac
}

pause() {
    echo
    msg info "Tekan Enter untuk kembali ke menu..."
    read -r _
}

# ─────────────────────────────────────────────
# 📝 FUNGSI HISTORY
# ─────────────────────────────────────────────

# Simpan URL dan Cookie ke history
save_to_history() {
    local url="$1"
    local cookie="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp}|${url}|${cookie}" >> "$HISTORY_FILE"
    msg ok "URL & Cookie telah disimpan ke history_diskfill.txt"
}

# ─────────────────────────────────────────────
# 🚀 FUNGSI UTAMA
# ─────────────────────────────────────────────

# Menu 1: Jalankan Spam Disk dengan input manual
run_spam_manual() {
    print_header "🚀  JALANKAN SPAM DISK (INPUT MANUAL)"

    # Cek file Python
    if [[ ! -f "$PYTHON_SCRIPT" ]]; then
        msg fail "File 'diskfill_data1.py' tidak ditemukan!"
        msg warn "Pastikan file berada di direktori yang sama."
        pause
        return
    fi

    echo
    printf "  ${CYAN}${BOLD}Masukkan URL tujuan:${RESET} "
    read -r target_url
    if [[ -z "$target_url" ]]; then
        msg fail "URL tidak boleh kosong!"
        pause
        return
    fi

    printf "  ${CYAN}${BOLD}Masukkan Cookie (opsional, kosongkan jika tidak ada):${RESET} "
    read -r cookie
    # Cookie now optional — can be empty

    printf "  ${CYAN}${BOLD}Masukkan jumlah size MB (default: 8):${RESET} "
    read -r size_mb
    size_mb=${size_mb:-8}



    printf "  ${CYAN}${BOLD}Masukkan jumlah perulang (default: 0):${RESET} "
    read -r perulang
    perulang=${perulang:-0}

    echo
    msg info "Menjalankan diskfill_data1.py..."
    echo

    # Jalankan Python script dengan parameter
    python3 "$PYTHON_SCRIPT" "$target_url" "$cookie" "$size_mb" "$perulang"

    # Simpan ke history
    save_to_history "$target_url" "$cookie"

    pause
}

# Menu 2: Jalankan Spam Disk dari history
run_spam_from_history() {
    print_header "📋  JALANKAN SPAM DISKFILL (DARI HISTORY)"

    # Cek file Python
    if [[ ! -f "$PYTHON_SCRIPT" ]]; then
        msg fail "File 'diskfill_data1.py' tidak ditemukan!"
        pause
        return
    fi

    # Cek history file
    if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
        msg fail "History kosong! Tidak ada data tersimpan."
        msg warn "Jalankan Menu 1 terlebih dahulu untuk menyimpan data."
        pause
        return
    fi

    # Tampilkan daftar history
    echo
    printf "  ${GREEN}┌───────────────────────────────────────────────────────────────────────────────┐${RESET}\n"
    printf "  ${GREEN}│${RESET} ${BG_GREEN}${BOLD}  #  TANGGAL              URL                           COOKIE           ${RESET}${GREEN}│${RESET}\n"
    printf "  ${GREEN}├───────────────────────────────────────────────────────────────────────────────┤${RESET}\n"

    declare -a history_list
    local counter=1
    while IFS='|' read -r timestamp url cookie; do
        history_list+=("${timestamp}|${url}|${cookie}")
        # Potong URL jika terlalu panjang untuk tampilan
        local display_url="$url"
        if [[ ${#display_url} -gt 30 ]]; then
            display_url="${display_url:0:27}..."
        fi
        local display_cookie="$cookie"
        if [[ -z "$display_cookie" ]]; then
            display_cookie="${DIM}(kosong)${RESET}"
        elif [[ ${#display_cookie} -gt 15 ]]; then
            display_cookie="${display_cookie:0:12}..."
        fi
        printf "  ${GREEN}│${RESET} ${CYAN}%2d${RESET}  ${WHITE}%-20s${RESET} ${YELLOW}%-30s${RESET} ${CYAN}%-15s${RESET} ${GREEN}│${RESET}\n" \
            "$counter" "$timestamp" "$display_url" "$display_cookie"
        counter=$((counter + 1))
    done < "$HISTORY_FILE"

    printf "  ${GREEN}└───────────────────────────────────────────────────────────────────────────────┘${RESET}\n"
    echo

    printf "  ${YELLOW}${BOLD}❓ PILIH${RESET} Nomor history untuk dijalankan: "
    read -r choice
    echo

    if [[ -z "$choice" ]]; then
        msg warn "Tidak ada yang dipilih."
        pause
        return
    fi

    if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#history_list[@]} ]]; then
        local selected="${history_list[$((choice-1))]}"
        local sel_url=$(echo "$selected" | cut -d'|' -f2)
        local sel_cookie=$(echo "$selected" | cut -d'|' -f3)

        printf "  ${CYAN}┌────────────────────────────────────────────────────────┐${RESET}\n"
        printf "  ${CYAN}│${RESET}  ${WHITE}URL    : ${YELLOW}%-40s${RESET} ${CYAN}│${RESET}\n" "${sel_url:0:40}"
          if [[ -n "$sel_cookie" ]]; then
              printf "  ${CYAN}│${RESET}  ${WHITE}Cookie : ${YELLOW}%-40s${RESET} ${CYAN}│${RESET}\n" "${sel_cookie:0:40}"
          else
              printf "  ${CYAN}│${RESET}  ${WHITE}Cookie : ${DIM}(kosong / session)${RESET}           ${CYAN}│${RESET}\n"
          fi
        printf "  ${CYAN}└────────────────────────────────────────────────────────┘${RESET}\n"
        
        printf "  ${CYAN}${BOLD}Masukkan jumlah size MB (default: 8):${RESET} "
        read -r size_mb
        size_mb=${size_mb:-8}

        printf "  ${CYAN}${BOLD}Masukkan jumlah perulangan (default: unli):${RESET} "
        read -r perulangan
        perulangan=${perulangan:-0}

        echo
        msg info "Menjalankan diskfill_data1.py dari history..."
        echo

        python3 "$PYTHON_SCRIPT" "$sel_url" "$sel_cookie" "$size_mb" "$perulangan"
    else
        msg fail "Nomor tidak valid!"
    fi

    pause
}

# Menu 3: Hapus history
delete_history() {
    print_header "🗑️  HAPUS HISTORY"

    # Cek history file
    if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
        msg fail "History sudah kosong!"
        pause
        return
    fi

    # Tampilkan daftar history
    echo
    printf "  ${RED}┌───────────────────────────────────────────────────────────────────────────────┐${RESET}\n"
    printf "  ${RED}│${RESET} ${BG_RED}${BOLD}  #  TANGGAL              URL                           COOKIE           ${RESET}${RED}│${RESET}\n"
    printf "  ${RED}├───────────────────────────────────────────────────────────────────────────────┤${RESET}\n"

    declare -a history_list
    local counter=1
    while IFS='|' read -r timestamp url cookie; do
        history_list+=("${timestamp}|${url}|${cookie}")
        local display_url="$url"
        if [[ ${#display_url} -gt 30 ]]; then
            display_url="${display_url:0:27}..."
        fi
        local display_cookie="$cookie"
        if [[ -z "$display_cookie" ]]; then
            display_cookie="${DIM}(kosong)${RESET}"
        elif [[ ${#display_cookie} -gt 15 ]]; then
            display_cookie="${display_cookie:0:12}..."
        fi
        printf "  ${RED}│${RESET} ${CYAN}%2d${RESET}  ${WHITE}%-20s${RESET} ${YELLOW}%-30s${RESET} ${CYAN}%-15s${RESET} ${RED}│${RESET}\n" \
            "$counter" "$timestamp" "$display_url" "$display_cookie"
        counter=$((counter + 1))
    done < "$HISTORY_FILE"

    printf "  ${RED}└───────────────────────────────────────────────────────────────────────────────┘${RESET}\n"
    echo

    printf "  ${YELLOW}${BOLD}❓ PILIH${RESET} Nomor history yang akan dihapus: "
    read -r choice
    echo

    if [[ -z "$choice" ]]; then
        msg warn "Tidak ada yang dipilih."
        pause
        return
    fi

    if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#history_list[@]} ]]; then
        local selected="${history_list[$((choice-1))]}"
        local sel_timestamp=$(echo "$selected" | cut -d'|' -f1)
        local sel_url=$(echo "$selected" | cut -d'|' -f2)
        local sel_cookie=$(echo "$selected" | cut -d'|' -f3)

        # Konfirmasi
        printf "  ${YELLOW}${BOLD}⚠️  Konfirmasi:${RESET} Hapus history ini?\n"
        printf "  ${WHITE}   Tanggal: ${CYAN}%s${RESET}\n" "$sel_timestamp"
        printf "  ${WHITE}   URL    : ${CYAN}%s${RESET}\n" "$sel_url"
        printf "  ${WHITE}   Cookie : ${CYAN}%s${RESET}\n" "$sel_cookie"
        echo
        printf "  ${YELLOW}${BOLD}❓ Lanjutkan? (y/n):${RESET} "
        read -r confirm

        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            # Hapus baris yang dipilih dari file history
            local temp_file="${HISTORY_FILE}.tmp"
            local line_num=1
            while IFS= read -r line; do
                if [[ $line_num -ne $choice ]]; then
                    echo "$line" >> "$temp_file"
                fi
                line_num=$((line_num + 1))
            done < "$HISTORY_FILE"
            mv "$temp_file" "$HISTORY_FILE"
            msg ok "History berhasil dihapus!"
        else
            msg warn "Penghapusan dibatalkan."
        fi
    else
        msg fail "Nomor tidak valid!"
    fi

    pause
}

# ─────────────────────────────────────────────
# 🔄 LOOP UTAMA
# ─────────────────────────────────────────────

while true; do
    show_menu

    case "$pilihan" in
        1)
            run_spam_manual
            ;;
        2)
            run_spam_from_history
            ;;
        3)
            delete_history
            ;;
        0)
            clear
            if command -v newmenu &> /dev/null; then
                bash newmenu
            elif [[ -f "${SCRIPT_DIR}/newmenu" ]]; then
                bash "${SCRIPT_DIR}/newmenu"
            else
                msg warn "File newmenu tidak ditemukan."
                exit 0
            fi
            exit 0
            ;;
        x|X)
            clear
            echo
            printf "  ${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}\n"
            printf "  ${CYAN}║${RESET}          ${WHITE}${BOLD}👋 Terima kasih! Sampai jumpa!${RESET}                  ${CYAN}║${RESET}\n"
            printf "  ${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}\n"
            echo
            exit 0
            ;;
        *)
            msg fail "Pilihan tidak valid! Silakan pilih 1, 2, 3, 0, atau x."
            sleep 1
            ;;
    esac
done