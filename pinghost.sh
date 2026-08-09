#!/bin/bash

# ═══════════════════════════════════════════════════════════
#   📡  PING NETWORK TEST  -  MENU INTERAKTIF v2.0
# ═══════════════════════════════════════════════════════════
#   ⚡ Uji apakah perangkat dapat dijangkau melalui jaringan
#   ⏱️  dan ukur waktu bolak-balik data (Round-Trip Time)
# ═══════════════════════════════════════════════════════════

# ─────────────────────────────────────────────
# 🎨 KONFIGURASI WARNA
# ─────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

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
    printf "${CYAN}  ║${RESET}${BG_BLUE}${WHITE}      📡  P I N G   N E T W O R K   T E S T               ${RESET}${CYAN}║${RESET}\n"
    printf "${CYAN}  ║${RESET}${BG_CYAN}${BOLD}      ⚡  Uji konektivitas & ukur waktu bolak-balik (RTT) ${RESET}${CYAN}║${RESET}\n"
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

# Pause kembali ke menu
pause() {
    echo
    msg info "Tekan Enter untuk kembali ke menu..."
    read -r _
}

# Warna nilai RTT berdasarkan kecepatan (<50ms hijau, <100ms kuning, lainnya merah)
rtt_color() {
    local v="$1"
    if awk -v x="$v" 'BEGIN{exit !(x < 50)}' 2>/dev/null; then
        printf '%s' "$GREEN"
    elif awk -v x="$v" 'BEGIN{exit !(x < 100)}' 2>/dev/null; then
        printf '%s' "$YELLOW"
    else
        printf '%s' "$RED"
    fi
}

# ─────────────────────────────────────────────
# 📊 TABEL HASIL PING (ringkas & modern)
# ─────────────────────────────────────────────
show_result_table() {
    local OUT="$1" TARGET="$2"
    local IP TX RX LOSS RTT RTT_MIN RTT_AVG RTT_MAX
    local LOSS_COLOR STATUS STATUS_COLOR

    IP=$(echo "$OUT" | head -1 | grep -oP '\(\K[^)]+' | head -1)
    TX=$(echo "$OUT" | grep -oP '\d+(?= packets transmitted)' | head -1)
    RX=$(echo "$OUT" | grep -oP '\d+(?= received)' | head -1)
    LOSS=$(echo "$OUT" | grep -oP '[\d.]+(?=% packet loss)' | head -1)
    RTT=$(echo "$OUT" | grep -oP 'rtt min/avg/max/mdev = \K[0-9.]+(/[0-9.]+){2,3}' | head -1)

    TX=${TX:-0}; RX=${RX:-0}; LOSS=${LOSS:-100}

    # Status & warna berdasarkan packet loss
    if [ "${LOSS%%.*}" -eq 0 ]; then
        STATUS="✅ DAPAT DIJANGKAU"; STATUS_COLOR=$GREEN; LOSS_COLOR=$GREEN
    elif [ "${LOSS%%.*}" -lt 20 ]; then
        STATUS="⚠️  KONEKSI LEMAH"; STATUS_COLOR=$YELLOW; LOSS_COLOR=$YELLOW
    else
        STATUS="❌ TIDAK TERJANGKAU"; STATUS_COLOR=$RED; LOSS_COLOR=$RED
    fi

    # Ambil nilai RTT
    if [ -n "$RTT" ]; then
        RTT_MIN=$(echo "$RTT" | cut -d/ -f1)
        RTT_AVG=$(echo "$RTT" | cut -d/ -f2)
        RTT_MAX=$(echo "$RTT" | cut -d/ -f3)
    fi

    echo
    printf "  ${CYAN}┌────────────────────────────────────────────────────────┐${RESET}\n"
    printf "  ${CYAN}│${RESET}  ${BOLD}${WHITE}📊 HASIL PING${RESET}   ${STATUS_COLOR}${STATUS}${RESET}\n"
    printf "  ${CYAN}├────────────────────────────────────────────────────────┤${RESET}\n"
    printf "  ${CYAN}│${RESET}  🎯 Target       : ${WHITE}%-20s${RESET}\n" "$TARGET"
    printf "  ${CYAN}│${RESET}  🌐 Resolved IP  : ${WHITE}%-20s${RESET}\n" "${IP:-—}"
    printf "  ${CYAN}│${RESET}  📦 Terkirim     : ${WHITE}%-20s${RESET} paket\n" "$TX"
    printf "  ${CYAN}│${RESET}  ✅ Diterima     : ${WHITE}%-20s${RESET} paket\n" "$RX"
    printf "  ${CYAN}│${RESET}  📉 Packet loss  : ${LOSS_COLOR}%-20s${RESET} %%\n" "$LOSS"
    printf "  ${CYAN}├────────────────────────────────────────────────────────┤${RESET}\n"
    printf "  ${CYAN}│${RESET}  ${BOLD}${WHITE}⚡ ROUND-TRIP TIME (RTT)${RESET}\n"
    if [ -n "$RTT" ]; then
        printf "  ${CYAN}│${RESET}  ⏱️  Minimum      : $(rtt_color "$RTT_MIN")%-10s ms${RESET}${GRAY}  (tercepat)${RESET}\n" "$RTT_MIN"
        printf "  ${CYAN}│${RESET}  ⏱️  Rata-rata    : $(rtt_color "$RTT_AVG")%-10s ms${RESET}${GRAY}  (avg)${RESET}\n" "$RTT_AVG"
        printf "  ${CYAN}│${RESET}  ⏱️  Maksimum     : $(rtt_color "$RTT_MAX")%-10s ms${RESET}${GRAY}  (terlama)${RESET}\n" "$RTT_MAX"
    else
        printf "  ${CYAN}│${RESET}  ⏱️  RTT          : ${RED}%-20s${RESET}\n" "— (tidak ada balasan)"
    fi
    printf "  ${CYAN}└────────────────────────────────────────────────────────┘${RESET}\n"
    echo
}

# ─────────────────────────────────────────────
# 🎯 INPUT TARGET
# ─────────────────────────────────────────────
input_target() {
    echo
    read -p "  🎯 Masukkan IP / hostname target: " TARGET
    if [ -z "$TARGET" ]; then
        msg fail "Target tidak boleh kosong!"
        return 1
    fi
}

# ─────────────────────────────────────────────
# 🚀 MODE 1: BASIC PING (jumlah paket terbatas)
# ─────────────────────────────────────────────
basic_ping() {
    clear
    print_banner
    input_target || { pause; return; }

    echo
    read -p "  📦 Jumlah paket yang dikirim [4]: " COUNT
    COUNT=${COUNT:-4}
    if ! [[ "$COUNT" =~ ^[0-9]+$ ]] || [ "$COUNT" -le 0 ]; then
        msg fail "Jumlah paket harus angka positif!"
        pause
        return
    fi

    print_header "🚀 BASIC PING"
    msg info "Menguji koneksi ke ${TARGET} (${COUNT} paket)..."
    echo

    # Jalankan ping dan tangkap output untuk dianalisa
    local OUT
    OUT=$(ping -c "$COUNT" "$TARGET" 2>&1)
    echo "$OUT" | sed 's/^/  /'
    echo

    show_result_table "$OUT" "$TARGET"
    pause
}

# ─────────────────────────────────────────────
# ♾️  MODE 2: UNLIMITED PING (tanpa henti)
# ─────────────────────────────────────────────
unlimited_ping() {
    clear
    print_banner
    input_target || { pause; return; }

    print_header "♾️  UNLIMITED PING"
    msg info "Ping tanpa henti ke ${TARGET} — tekan ${BOLD}Ctrl+C${RESET}${CYAN} untuk berhenti${RESET}"
    echo

    # Tangani Ctrl+C agar kembali ke menu dengan rapi
    trap 'echo; msg warn "Ping dihentikan oleh pengguna (Ctrl+C)"; trap - INT; return 0' INT
    ping "$TARGET" 2>/dev/null
    trap - INT
    echo

    msg ok "Ping selesai — statistik terlihat di atas."
    pause
}

# ─────────────────────────────────────────────
# 📋 MENU UTAMA
# ─────────────────────────────────────────────
show_menu() {
    print_banner

    printf "${CYAN}  ┌──────────────────────────────────────────────────────────┐${RESET}\n"
    printf "${CYAN}  │${RESET} ${WHITE}${BOLD}    📡 PING NETWORK TEST - MENU UTAMA                    ${RESET}${CYAN}│${RESET}\n"
    printf "${CYAN}  ├──────────────────────────────────────────────────────────┤${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[1]${RESET} ${YELLOW}🚀${RESET}  ${WHITE}Basic Ping (jumlah paket terbatas)${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[2]${RESET} ${YELLOW}♾️ ${RESET}  ${WHITE}Unlimited Ping (tanpa henti)${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[0]${RESET} ${YELLOW}🏠${RESET}  ${WHITE}Kembali ke Menu Utama (newmenu)${RESET}\n"
    printf "${CYAN}  │${RESET}  ${GREEN}${BOLD}[x]${RESET} ${YELLOW}🚪${RESET}  ${WHITE}Keluar${RESET}\n"
    printf "${CYAN}  ├──────────────────────────────────────────────────────────┤${RESET}\n"
    printf "${CYAN}  │${RESET} ${WHITE}${BOLD}❓ Pilihan Anda:${RESET} ${RESET}"
    read -r pilihan
    printf "${CYAN}  └──────────────────────────────────────────────────────────┘${RESET}\n"
}

# ─────────────────────────────────────────────
# 🚀 PROGRAM UTAMA
# ─────────────────────────────────────────────
clear
show_menu

    case "$pilihan" in
        1)
            basic_ping
            ;;
        2)
            unlimited_ping
            ;;
        0)
            clear
            if [[ -f "newmenu" ]]; then
                bash newmenu
            else
                msg fail "File 'newmenu' tidak ditemukan di direktori ini!"
                echo
                read -r -p "  Tekan Enter untuk kembali ke menu ping..."
            fi
            ;;
        x|X)
            echo
            msg warn "Keluar dari program. Sampai jumpa! 👋"
            sleep 1
            clear
            exit 0
            ;;
        *)
            msg fail "Pilihan tidak valid! Masukkan 0, 1, 2, atau x."
            sleep 1
            ;;
    esac
