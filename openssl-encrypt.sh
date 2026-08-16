#!/usr/bin/env bash
# ============================================================================
#  🔐  OPENSSL ENCRYPT & DECRYPT TOOL
#  Author : (You)
#  Desc   : Professional AES-256-CBC file encryption / decryption utility
#  Req    : openssl, coreutils
# ============================================================================
set -euo pipefail

# ── Color Palette ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Icons / Emojis ───────────────────────────────────────────────────────────
ICON_LOCK="🔐"
ICON_UNLOCK="🔓"
ICON_KEY="🔑"
ICON_FILE="📄"
ICON_SUCCESS="✅"
ICON_ERROR="❌"
ICON_WARN="⚠️"
ICON_INFO="ℹ️"
ICON_CLOCK="⏳"
ICON_SHIELD="🛡️"
ICON_BULLET="•"

# ── Runtime Config ───────────────────────────────────────────────────────────
readonly CIPHER="aes-256-cbc"
readonly VERSION="2.0.0"
readonly SCRIPT_NAME="$(basename "$0")"

# ── Utility Functions ────────────────────────────────────────────────────────

# Print a horizontal divider line
print_divider() {
    local width="${1:-58}"
    printf "${DIM}%*s${NC}\n" "$width" | tr ' ' '─'
}

# Print a boxed message
print_box() {
    local msg="$1"
    local color="${2:-$CYAN}"
    local len=${#msg}
    local inner=$((len + 4))
    printf "${color}┌"
    printf "─%.0s" $(seq 1 "$inner")
    printf "┐${NC}\n"
    printf "${color}│  ${WHITE}${msg}  ${color}│${NC}\n"
    printf "${color}└"
    printf "─%.0s" $(seq 1 "$inner")
    printf "┘${NC}\n"
}

# Banner / Header
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
                                   _       _           
  ___ _ __   ___    __ _ _ __   __| |   __| | ___  ___ 
 / _ \ '_ \ / __|  / _` | '_ \ / _` |  / _` |/ _ \/ __|
|  __/ | | | (__  | (_| | | | | (_| | | (_| |  __/ (__ 
 \___|_| |_|\___|  \__,_|_| |_|\__,_|  \__,_|\___|\___|
 
EOF
    echo -e "${NC}"
    print_divider
    echo -e "${BOLD}${MAGENTA}  ${ICON_SHIELD} OpenSSL Encrypt & Decrypt Tool${NC} ${DIM}v${VERSION}${NC}"
    echo -e "${DIM}  AES-256-CBC  •  Salted  •  Secure${NC}"
    print_divider
    echo
}

# Animated spinner — runs while a background PID is active
# Usage: spinner "Message" COMMAND_PID
spinner() {
    local msg="$1"
    local pid="$2"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${CYAN}${ICON_CLOCK} ${msg} ${YELLOW}[${spin:i%10:1}]${NC}  "
        i=$((i+1))
        sleep 0.08
    done
    printf "\r%*s\r" $(( ${#msg} + 10 )) ""
}

# Success message
msg_success() {
    echo -e "${GREEN}${ICON_SUCCESS} ${BOLD}$1${NC}"
}

# Error message (with optional exit code)
msg_error() {
    echo -e "${RED}${ICON_ERROR} ${BOLD}$1${NC}"
    [[ -n "${2:-}" ]] && exit "$2"
}

# Warning message
msg_warn() {
    echo -e "${YELLOW}${ICON_WARN} $1${NC}"
}

# Info message
msg_info() {
    echo -e "${BLUE}${ICON_INFO} $1${NC}"
}

# Print a key-value detail line
msg_detail() {
    echo -e "  ${DIM}${ICON_BULLET} ${1}:${NC} ${WHITE}${2}${NC}"
}

# ── Dependency Check ─────────────────────────────────────────────────────────
check_dependencies() {
    if ! command -v openssl &>/dev/null; then
        msg_error "OpenSSL tidak ditemukan! Silakan install: sudo apt install openssl" 1
    fi
}

# ── Menu Display ─────────────────────────────────────────────────────────────
show_menu() {
    echo -e "${BOLD}  ${WHITE}Pilih Operasi:${NC}"
    echo
    echo -e "  ${GREEN}[1]${NC} ${ICON_LOCK} ${WHITE}Encrypt File${NC}  ${DIM}— Amankan file dengan AES-256${NC}"
    echo -e "  ${GREEN}[2]${NC} ${ICON_UNLOCK} ${WHITE}Decrypt File${NC}  ${DIM}— Kembalikan file terenkripsi${NC}"
    echo -e "  ${GREEN}[3]${NC} ${ICON_INFO}  ${WHITE}Bantuan${NC}        ${DIM}— Tampilkan informasi penggunaan${NC}"
    echo -e "  ${GREEN}[0]${NC} ${DIM}Keluar${NC}"
    echo
    print_divider
}

# ── Show Help ────────────────────────────────────────────────────────────────
show_help() {
    echo
    print_box "📖 PETUNJUK PENGGUNAAN" "$BLUE"
    echo
    echo -e "  ${BOLD}Cara Pakai:${NC}"
    echo -e "    ${DIM}\$${NC} bash $SCRIPT_NAME"
    echo
    echo -e "  ${BOLD}Mode Encrypt:${NC}"
    echo -e "    ${ICON_BULLET} Pilih opsi ${GREEN}1${NC}"
    echo -e "    ${ICON_BULLET} Masukkan path file yang ingin diamankan"
    echo -e "    ${ICON_BULLET} Masukkan password (tidak ditampilkan)"
    echo -e "    ${ICON_BULLET} Output: <namafile>.enc"
    echo
    echo -e "  ${BOLD}Mode Decrypt:${NC}"
    echo -e "    ${ICON_BULLET} Pilih opsi ${GREEN}2${NC}"
    echo -e "    ${ICON_BULLET} Masukkan path file ${YELLOW}.enc${NC}"
    echo -e "    ${ICON_BULLET} Masukkan password yang sama"
    echo -e "    ${ICON_BULLET} Output: file asli (tanpa .enc)"
    echo
    echo -e "  ${BOLD}Cipher:${NC}      ${CYAN}$CIPHER${NC}"
    echo -e "  ${BOLD}Versi:${NC}        ${CYAN}$VERSION${NC}"
    echo
    print_divider
    echo
    read -rp "$(echo -e ${YELLOW}Tekan ENTER untuk kembali...${NC})"
}

# ── Get file size in human-readable format ───────────────────────────────────
human_size() {
    local bytes
    bytes=$(stat -c%s "$1" 2>/dev/null || stat -f%z "$1" 2>/dev/null || echo "?")
    if [[ "$bytes" =~ ^[0-9]+$ ]]; then
        if (( bytes >= 1073741824 )); then
            printf "%.2f GB" "$(bc -l <<< "$bytes/1073741824" 2>/dev/null || echo 0)"
        elif (( bytes >= 1048576 )); then
            printf "%.2f MB" "$(bc -l <<< "$bytes/1048576" 2>/dev/null || echo 0)"
        elif (( bytes >= 1024 )); then
            printf "%.2f KB" "$(bc -l <<< "$bytes/1024" 2>/dev/null || echo 0)"
        else
            printf "%d B" "$bytes"
        fi
    else
        echo "? B"
    fi
}

# ── Encryption Function ──────────────────────────────────────────────────────
encrypt_file() {
    echo
    print_box "${ICON_LOCK} ENKRIPSI FILE" "$GREEN"
    echo

    read -rp "$(echo -e ${CYAN}${ICON_FILE} Masukkan path file: ${NC})" file

    if [[ ! -f "$file" ]]; then
        msg_error "File tidak ditemukan: '$file'" 1
    fi

    local fsize
    fsize=$(human_size "$file")
    local outfile="${file}.enc"

    # If output already exists, warn
    if [[ -f "$outfile" ]]; then
        msg_warn "File output sudah ada dan akan ditimpa: $outfile"
        read -rp "$(echo -e ${YELLOW}Lanjut? (y/n): ${NC})" confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || { msg_info "Dibatalkan."; return; }
    fi

    echo
    msg_info "Detail File:"
    msg_detail "Nama" "$(basename "$file")"
    msg_detail "Ukuran" "$fsize"
    msg_detail "Cipher" "$CIPHER"
    msg_detail "Output" "$outfile"
    echo

    read -sp "$(echo -e ${MAGENTA}${ICON_KEY} Masukkan password: ${NC})" password
    echo
    read -sp "$(echo -e ${MAGENTA}${ICON_KEY} Konfirmasi password: ${NC})" password2
    echo

    if [[ "$password" != "$password2" ]]; then
        msg_error "Password tidak cocok!" 1
    fi
    if [[ -z "$password" ]]; then
        msg_error "Password tidak boleh kosong!" 1
    fi

    echo
    print_divider

    # Run openssl in background with spinner
    (
        openssl enc -"$CIPHER" -salt -pbkdf2 -in "$file" -out "$outfile" \
            -pass pass:"$password" 2>/dev/null
    ) &
    local pid=$!
    spinner "Mengenkripsi file..." "$pid"
    wait "$pid"
    local rc=$?

    print_divider
    echo
    if [[ $rc -eq 0 && -f "$outfile" ]]; then
        local osize
        osize=$(human_size "$outfile")
        msg_success "File berhasil dienkripsi!"
        echo
        msg_detail "Output" "$outfile"
        msg_detail "Ukuran" "$osize"
        msg_detail "Status" "${GREEN}Terenkripsi${NC} ${ICON_LOCK}"
        echo
    else
        msg_error "Gagal mengenkripsi file. Periksa password atau file." 1
    fi
}

# ── Decryption Function ──────────────────────────────────────────────────────
decrypt_file() {
    echo
    print_box "${ICON_UNLOCK} DEKRIPSI FILE" "$CYAN"
    echo

    read -rp "$(echo -e ${CYAN}${ICON_FILE} Masukkan path file .enc: ${NC})" file

    if [[ ! -f "$file" ]]; then
        msg_error "File tidak ditemukan: '$file'" 1
    fi

    local fsize
    fsize=$(human_size "$file")
    local outfile="${file%.enc}"
    [[ "$outfile" == "$file" ]] && outfile="${file}.dec"

    if [[ -f "$outfile" ]]; then
        msg_warn "File output sudah ada dan akan ditimpa: $outfile"
        read -rp "$(echo -e ${YELLOW}Lanjut? (y/n): ${NC})" confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || { msg_info "Dibatalkan."; return; }
    fi

    echo
    msg_info "Detail File:"
    msg_detail "Nama" "$(basename "$file")"
    msg_detail "Ukuran" "$fsize"
    msg_detail "Cipher" "$CIPHER"
    msg_detail "Output" "$outfile"
    echo

    read -sp "$(echo -e ${MAGENTA}${ICON_KEY} Masukkan password: ${NC})" password
    echo

    if [[ -z "$password" ]]; then
        msg_error "Password tidak boleh kosong!" 1
    fi

    echo
    print_divider

    (
        openssl enc -d -"$CIPHER" -pbkdf2 -in "$file" -out "$outfile" \
            -pass pass:"$password" 2>/dev/null
    ) &
    local pid=$!
    spinner "Mendekripsi file..." "$pid"
    wait "$pid"
    local rc=$?

    print_divider
    echo
    if [[ $rc -eq 0 && -f "$outfile" ]]; then
        local osize
        osize=$(human_size "$outfile")
        msg_success "File berhasil didekripsi!"
        echo
        msg_detail "Output" "$outfile"
        msg_detail "Ukuran" "$osize"
        msg_detail "Status" "${GREEN}Terdekripsi${NC} ${ICON_UNLOCK}"
        echo
    else
        msg_error "Gagal mendekripsi. Password salah atau file korup." 1
    fi
}

# ── Pause & Exit ─────────────────────────────────────────────────────────────
pause() {
    echo
    read -rp "$(echo -e ${DIM}Tekan ENTER untuk melanjutkan...${NC})"
}

# ── Main Loop ─────────────────────────────────────────────────────────────
main() {
    check_dependencies

    while true; do
        show_banner
        show_menu

        read -rp "$(echo -e ${BOLD}${YELLOW}➤ Pilihan [0-3]: ${NC})" choice

        case "$choice" in
            1) encrypt_file;  pause ;;
            2) decrypt_file;  pause ;;
            3) show_help ;;
            0)
                echo
                msg_info "Terima kasih telah menggunakan tool ini! ${ICON_SHIELD}"
                echo
                exit 0
                ;;
            *)
                msg_error "Pilihan tidak valid! Pilih 0-3."
                sleep 1
                ;;
        esac
    done
}

main "$@"
