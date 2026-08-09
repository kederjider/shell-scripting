#!/bin/bash

# ═══════════════════════════════════════════════════════════
#   🌐  IP TO HOST LOOKUP  -  MENU INTERAKTIF v2.0
# ═══════════════════════════════════════════════════════════
#   🔍 Cari hostname/domain terkait dari sebuah IPv4
# ═══════════════════════════════════════════════════════════

# ─────────────────────────────────────────────
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
BG_YELLOW='\033[43m'
BG_RED='\033[41m'
BG_MAGENTA='\033[45m'
BG_DARK='\033[40m'

# Badge status
OK="${GREEN}✔${RESET}"
FAIL="${RED}✘${RESET}"
WARN="${YELLOW}⚠${RESET}"
INFO="${CYAN}ℹ${RESET}"
ARROW="${CYAN}➜${RESET}"

# ─────────────────────────────────────────────
# 🧩 FUNGSI UTILITAS
# ─────────────────────────────────────────────

# Garis horizontal fleksibel
line() {
    local char="${1:-─}"
    local width="${2:-60}"
    printf '%s' "$char" && printf '%*s' "$width" "" | tr ' ' "$char" && printf '\n'
}

# Banner utama
print_banner() {
    echo
    printf "${CYAN}  ╔══════════════════════════════════════════════════════════╗${RESET}\n"
    printf "${CYAN}  ║${RESET}${BG_BLUE}${WHITE}      🌐  I P   T O   H O S T   L O O K U P               ${RESET}${CYAN}║${RESET}\n"
    printf "${CYAN}  ║${RESET}${BG_CYAN}${BOLD}      🔍  Cari hostname dari alamat IPv4                  ${RESET}${CYAN}║${RESET}\n"
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
    printf "${CYAN}  │${RESET} ${WHITE}${BOLD}    🌐 IP TO HOST LOOKUP - MENU UTAMA                    ${RESET}${CYAN}│${RESET}\n"
    printf "${CYAN}  ├──────────────────────────────────────────────────────────┤${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[1]${RESET} ${YELLOW}🔍${RESET}  ${WHITE}Jalankan IP to Host${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[2]${RESET} ${YELLOW}📊${RESET}  ${WHITE}Lihat Hasil${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[3]${RESET} ${YELLOW}🗑️${RESET}  ${WHITE}Hapus Hasil${RESET}\n"
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

# Kotak sukses / info
box() {
    local color="$1"
    local text="$2"
    printf "  ${color}┌────────────────────────────────────────────────────────┐${RESET}\n"
    printf "  ${color}│${RESET}  ${WHITE}%s${RESET}${color}${RESET}\n" "$text"
    printf "  ${color}└────────────────────────────────────────────────────────┘${RESET}\n"
}

pause() {
    echo
    msg info "Tekan Enter untuk kembali ke menu..."
    read -r _
}

# ─────────────────────────────────────────────
# 🚀 FUNGSI UTAMA
# ─────────────────────────────────────────────

# Menu 1: Jalankan IP to Host
run_ip_to_host() {
    print_header "🚀  JALANKAN IP TO HOST"
    msg info "Memulai pencarian hostname dari alamat IP..."
    echo

    if [[ -f "ip_to_host" ]]; then
        python3 ip_to_host
    else
        msg fail "File 'ip_to_host' tidak ditemukan!"
        msg warn "Pastikan file berada di direktori yang sama."
    fi

    pause
}

# Menu 2: Lihat hasil
view_results() {
    print_header "📊  LIHAT HASIL PENCARIAN"

    local result_dir="hasil_ip_to_host"

    if [[ ! -d "$result_dir" ]]; then
        msg fail "Direktori hasil tidak ditemukan!"
        msg warn "Jalankan pencarian terlebih dahulu (Menu 1)."
        pause
        return
    fi

    local file_count=$(find "$result_dir" -name "*.txt" -type f 2>/dev/null | wc -l)

    if [[ $file_count -eq 0 ]]; then
        msg fail "Belum ada hasil yang tersimpan."
        msg warn "Jalankan pencarian terlebih dahulu (Menu 1)."
        pause
        return
    fi

    # Tabel daftar file
    printf "  ${GREEN}┌────────────────────────────────────────────────────────┐${RESET}\n"
    printf "  ${GREEN}│${RESET} ${BG_GREEN}${BOLD}  #  FILE                                   UKURAN  ${RESET}${GREEN}│${RESET}\n"
    printf "  ${GREEN}├────────────────────────────────────────────────────────┤${RESET}\n"

    local counter=1
    for file in "$result_dir"/*.txt; do
        if [[ -f "$file" ]]; then
            local filename=$(basename "$file")
            local size=$(du -h "$file" | cut -f1)
            printf "  ${GREEN}│${RESET} ${CYAN}%2d${RESET}  ${WHITE}%-38s${RESET} ${YELLOW}%7s${RESET}  ${GREEN}│${RESET}\n" \
                "$counter" "${filename:0:38}" "$size"
            counter=$((counter + 1))
        fi
    done

    printf "  ${GREEN}└────────────────────────────────────────────────────────┘${RESET}\n"
    echo

    printf "  ${YELLOW}${BOLD}❓ PILIH${RESET} Nomor file untuk dilihat (Enter = lihat semua): "
    read -r choice
    echo

    if [[ -n "$choice" && "$choice" =~ ^[0-9]+$ ]]; then
        local file_num=1
        for file in "$result_dir"/*.txt; do
            if [[ -f "$file" ]]; then
                if [[ $file_num -eq $choice ]]; then
                    box "$MAGENTA" "📄 Menampilkan hasil: $(basename "$file")"
                    echo
                    cat "$file"
                    break
                fi
                file_num=$((file_num + 1))
            fi
        done
    else
        box "$MAGENTA" "📂 Menampilkan SEMUA hasil pencarian"
        echo
        for file in "$result_dir"/*.txt; do
            printf "  ${CYAN}┌────────────────────────────────────────────────────────┐${RESET}\n"
            printf "  ${CYAN}│${RESET} ${YELLOW}📄 FILE:${RESET} %s\n" "$(basename "$file")"
            printf "  ${CYAN}└────────────────────────────────────────────────────────┘${RESET}\n"
            cat "$file"
            echo
        done
    fi

    pause
}

# Menu 3: Hapus hasil
remove_results() {
    print_header "🗑️  HAPUS HASIL PENCARIAN"

    local result_dir="hasil_ip_to_host"

    if [[ ! -d "$result_dir" ]]; then
        msg fail "Direktori hasil tidak ditemukan!"
        msg warn "Tidak ada hasil yang perlu dihapus."
        pause
        return
    fi

    local file_count=$(find "$result_dir" -name "*.txt" -type f 2>/dev/null | wc -l)

    if [[ $file_count -eq 0 ]]; then
        msg fail "Tidak ada file hasil yang tersimpan."
        pause
        return
    fi

    # Tabel daftar file
    printf "  ${YELLOW}┌────────────────────────────────────────────────────────┐${RESET}\n"
    printf "  ${YELLOW}│${RESET} ${BG_YELLOW}${BOLD}  #  FILE                                   UKURAN  ${RESET}${YELLOW}│${RESET}\n"
    printf "  ${YELLOW}├────────────────────────────────────────────────────────┤${RESET}\n"
    printf "  ${YELLOW}│${RESET} ${GREEN}%2d${RESET}  ${RED}${BOLD}HAPUS SEMUA FILE${RESET}                          ${YELLOW}│${RESET}\n" "0"
    printf "  ${YELLOW}├────────────────────────────────────────────────────────┤${RESET}\n"

    declare -a file_list
    local counter=1
    for file in "$result_dir"/*.txt; do
        if [[ -f "$file" ]]; then
            file_list+=("$file")
            local filename=$(basename "$file")
            local size=$(du -h "$file" | cut -f1)
            printf "  ${YELLOW}│${RESET} ${CYAN}%2d${RESET}  ${WHITE}%-38s${RESET} ${YELLOW}%7s${RESET}  ${YELLOW}│${RESET}\n" \
                "$counter" "${filename:0:38}" "$size"
            counter=$((counter + 1))
        fi
    done

    printf "  ${YELLOW}└────────────────────────────────────────────────────────┘${RESET}\n"
    echo

    printf "  ${YELLOW}${BOLD}❓ PILIH${RESET} Nomor file untuk dihapus (0 = semua): "
    read -r choice
    echo

    if [[ -z "$choice" ]]; then
        msg warn "Tidak ada file yang dipilih."
        pause
        return
    fi

    if [[ "$choice" == "0" ]]; then
        msg warn "Semua file akan dihapus!"
        printf "  ${YELLOW}${BOLD}🔑 KONFIRMASI${RESET} Ketik 'hapus semua' untuk melanjutkan: "
        read -r confirm
        if [[ "$confirm" == "hapus semua" ]]; then
            echo
            msg info "Menghapus semua file hasil..."
            rm -rf "$result_dir"
            msg ok "Semua file hasil telah dihapus!"
        else
            msg warn "Penghapusan dibatalkan."
        fi
    elif [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#file_list[@]} ]]; then
        local selected_file="${file_list[$((choice-1))]}"
        local filename=$(basename "$selected_file")

        msg warn "File '${filename}' akan dihapus!"
        printf "  ${YELLOW}${BOLD}🔑 KONFIRMASI${RESET} Ketik 'hapus' untuk melanjutkan: "
        read -r confirm

        if [[ "$confirm" == "hapus" ]]; then
            echo
            msg info "Menghapus file '${filename}'..."
            rm -f "$selected_file"
            msg ok "File '${filename}' telah dihapus!"

            local remaining=$(find "$result_dir" -name "*.txt" -type f 2>/dev/null | wc -l)
            if [[ $remaining -eq 0 ]]; then
                rmdir "$result_dir" 2>/dev/null
                msg info "Direktori kosong juga telah dihapus."
            fi
        else
            msg warn "Penghapusan dibatalkan."
        fi
    else
        msg fail "Pilihan tidak valid!"
    fi

    pause
}

# Keluar
bye() {
    echo
    box "$GREEN" "👋 Terima kasih telah menggunakan program ini!"
    printf "  ${GREEN}│${RESET}   ${YELLOW}🌟 Sampai jumpa lagi!${RESET}      ${GREEN}│${RESET}\n"
    echo
    exit 0
}

# ─────────────────────────────────────────────
# 🏗️ ENTRY POINT
# ─────────────────────────────────────────────
main() {
    while true; do
        clear
        show_menu

        case "$pilihan" in
            1) run_ip_to_host ;;
            2) view_results ;;
            3) remove_results ;;
            0)
                echo
                box "$GREEN" "🏠 Kembali ke menu utama..."
                echo
                if [[ -f "newmenu" ]]; then
                    bash newmenu
                    exit 0
                else
                    msg fail "File 'newmenu' tidak ditemukan!"
                    msg warn "Kembali ke menu ini."
                    pause
                fi
                ;;
            x|X) bye ;;
            *)
                echo
                msg fail "Pilihan tidak valid!"
                pause
                ;;
        esac
    done
}

main
