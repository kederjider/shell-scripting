#!/bin/bash
# =============================================================
#  ░▒▓█  F T P   M A N A G E R  █▓▒░        [ CYBERPUNK EDITION ]
# =============================================================
#  📁 Kelola User FTP & Firewall UFW (backend: vsftpd)
#
#  MENU
#   [1] ⚙  Install FTP (vsftpd)
#   [2] 👤 Tambah User FTP + directory share
#   [3] 🛡  Setting Firewall UFW untuk FTP
#   [4] 🗑  Hapus User FTP (pilih nomor)
#   [5] 📋 Lihat User FTP + directory share
#   [6] 🔍 Status Service vsftpd
#   [0] ↩  Kembali ke Menu Utama
#   [X] ✘  Keluar
#
#  ⚙ Jalankan dengan : sudo bash ftp-manager.sh
# =============================================================

set -o pipefail

# -------------------------------------------------------------
#  PALET WARNA — CYBERPUNK NEON (256 color)
# -------------------------------------------------------------
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'

PINK='\033[38;5;201m'     # neon magenta
CYAN='\033[38;5;51m'      # neon aqua
GREEN='\033[38;5;46m'     # neon lime
YELLOW='\033[38;5;226m'   # neon yellow
RED='\033[38;5;196m'      # neon red
PURPLE='\033[38;5;129m'   # neon violet
BLUE='\033[38;5;39m'      # neon blue
WHITE='\033[38;5;231m'    # putih terang
GRAY='\033[38;5;242m'     # abu redup
MAGENTA="$PINK"

# Garis dekoratif (dipakai bersama agar lebar selalu seragam)
RULE="${GRAY}──────────────────────────────────────────────────${RESET}"
DIVIDER="${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# -------------------------------------------------------------
#  UI KIT — IKON & PESAN
# -------------------------------------------------------------
ICO_OK="✔"; ICO_NO="✘"; ICO_WARN="⚠"; ICO_INFO="ℹ"; ICO_STEP="▸"; ICO_DOT="●"
ICO_FTP="📁"; ICO_USER="👤"; ICO_KEY="🔑"; ICO_SHIELD="🛡"; ICO_TRASH="🗑"
ICO_SCAN="🔍"; ICO_GEAR="⚙"; ICO_GLOW="⚡"; ICO_BACK="↩"

msg_ok()   { printf "  ${GREEN}${ICO_OK}${RESET} %b\n" "$1"; }
msg_err()  { printf "  ${RED}${ICO_NO}${RESET} %b\n" "$1"; }
msg_warn() { printf "  ${YELLOW}${ICO_WARN}${RESET} %b\n" "$1"; }
msg_info() { printf "  ${CYAN}${ICO_INFO}${RESET} %b\n" "$1"; }
msg_step() { printf "  ${PINK}${ICO_STEP}${RESET} %b\n" "$1"; }

# Judul section bergaya neon
judul() {
    local teks="$1" ikon="${2:-$ICO_GLOW}"
    echo ""
    echo -e "  ${PURPLE}╭${RULE}${PURPLE}╮${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${ikon} ${PINK}${BOLD}$teks${RESET}"
    echo -e "  ${PURPLE}╰${RULE}${PURPLE}╯${RESET}"
}

pause() {
    echo ""
    echo -e "  ${GRAY}${ICO_DOT} Enter untuk kembali ke menu...${RESET}"
    # Matikan bracketed paste
    printf '\e[?2004l'
    read -rp "  ${ICO_BACK} " _
    # Aktifkan kembali bracketed paste
    printf '\e[?2004h'
}

tampil_header() {
    clear
    echo ""
    echo -e "  ${PURPLE}░▒▓█▓▒░${RESET} ${GRAY}────────────────────────────────────────${RESET} ${PURPLE}░▒▓█▓▒░${RESET}"
    echo -e "        ${PINK}${BOLD}▓█▓  F T P   M A N A G E R  ▓█▓${RESET}   ${GRAY}v2.0${RESET}"
    echo -e "        ${CYAN}${ICO_GLOW} Neon Control ${GRAY}•${RESET} ${CYAN}User${GRAY} •${RESET} ${CYAN}Share${GRAY} •${RESET} ${CYAN}Firewall UFW${RESET}"
    echo -e "  ${PURPLE}░▒▓█▓▒░${RESET} ${GRAY}────────────────────────────────────────${RESET} ${PURPLE}░▒▓█▓▒░${RESET}"
    echo -e "        ${DIM}$(date '+%a %d %b %Y  %H:%M:%S')${RESET}"
    echo ""
}

# -------------------------------------------------------------
#  LOKASI SCRIPT INSTALLER
# -------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_SELF="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"
INSTALLER=""

cari_installer() {
    local kandidat=(
        "/usr/local/bin/install-vsftpd"
        "$SCRIPT_DIR/install-vsftpd.sh"
        "/usr/local/bin/install-vsftpd.sh" 
    )
    for f in "${kandidat[@]}"; do
        if [[ -f "$f" ]]; then
            INSTALLER="$f"
            return 0
        fi
    done
    return 1
}

# -------------------------------------------------------------
#  CEK ROOT
# -------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}${BOLD}  ✘ Script ini harus dijalankan sebagai root / sudo.${RESET}"
    echo -e "${DIM}    Contoh: sudo bash ftp-manager.sh${RESET}"
    exit 1
fi

# =============================================================
#  1. INSTALL FTP (vsftpd)
# =============================================================
install_ftp() {
    echo -e "\n$DIVIDER"
    msg_step "Menjalankan installer vsftpd..."
    echo -e "$DIVIDER"

    if ! cari_installer; then
        msg_err "Script ${BOLD}install-vsftpd.sh${RESET} tidak ditemukan."
        msg_info "Letakkan file tersebut di folder yang sama dengan script ini,"
        msg_info "atau di ${BOLD}/usr/local/bin/${RESET}."
        return 1
    fi

    msg_info "Installer : ${BOLD}$INSTALLER${RESET}"
    echo ""
    bash "$INSTALLER"
    return $?
}

# =============================================================
#  2. TAMBAH USER FTP
# =============================================================
tambah_user_ftp() {
    echo -e "\n$DIVIDER"
    msg_step "TAMBAH USER FTP"
    echo -e "$DIVIDER"

    # --- Input nama user ---
    # Matikan bracketed paste
    printf '\e[?2004l'
    read -rp "  👤 Nama user FTP [default: userftp]: " FTP_USER
    # Aktifkan kembali bracketed paste
    printf '\e[?2004h'
    FTP_USER=${FTP_USER:-userftp}

    if [[ -z "$FTP_USER" ]]; then
        msg_err "Nama user tidak boleh kosong."
        return 1
    fi

    # --- Input password ---
    # Matikan bracketed paste
    printf '\e[?2004l'
    read -rp "  🔑 Password untuk '$FTP_USER': " FTP_PASS
    # Aktifkan kembali bracketed paste
    printf '\e[?2004h'

    if [[ -z "$FTP_PASS" ]]; then
        msg_err "Password tidak boleh kosong."
        return 1
    fi

    # --- Input directory share ---
    # Matikan bracketed paste
    printf '\e[?2004l'
    read -rp "  📁 Directory yang ingin dishare [default: /srv/ftp/share]: " SHARE_DIR
    # Aktifkan kembali bracketed paste
    printf '\e[?2004h'
    SHARE_DIR=${SHARE_DIR:-/srv/ftp/share}

    if [[ -z "$SHARE_DIR" ]]; then
        msg_err "Directory tidak boleh kosong."
        return 1
    fi

    echo ""
    msg_step "Membuat user '$FTP_USER'..."

    if id "$FTP_USER" &>/dev/null; then
        msg_warn "User '${BOLD}$FTP_USER${RESET}' sudah ada — melewati pembuatan user."
    else
        if adduser --gecos "" --disabled-password "$FTP_USER" >/dev/null 2>&1; then
            msg_ok "User '$FTP_USER' berhasil dibuat."
        else
            msg_err "Gagal membuat user '$FTP_USER'."
            return 1
        fi
    fi

    # Set password
    if echo "$FTP_USER:$FTP_PASS" | chpasswd 2>/dev/null; then
        msg_ok "Password user '$FTP_USER' berhasil diatur."
    else
        msg_err "Gagal mengatur password user '$FTP_USER'."
        return 1
    fi

    # --- Siapkan directory share ---
    msg_step "Menyiapkan directory share..."

    if [[ ! -d "$SHARE_DIR" ]]; then
        msg_info "Directory belum ada, membuat baru: $SHARE_DIR"
        if ! mkdir -p "$SHARE_DIR"; then
            msg_err "Gagal membuat directory '$SHARE_DIR'."
            return 1
        fi
    else
        msg_info "Directory sudah ada: $SHARE_DIR"
    fi

    chmod 777 "$SHARE_DIR"
    msg_ok "Permission directory '$SHARE_DIR' diatur ke 777."

    # --- Arahkan home user ke directory share ---
    msg_step "Mengarahkan home directory user..."
    if usermod -d "$SHARE_DIR" "$FTP_USER" 2>/dev/null; then
        msg_ok "Home directory '$FTP_USER' diarahkan ke '$SHARE_DIR'."
    else
        msg_err "Gagal mengarahkan home directory user '$FTP_USER'."
        return 1
    fi

    # --- Pastikan kepemilikan ---
    if chown -R "$FTP_USER:$FTP_USER" "$SHARE_DIR" 2>/dev/null; then
        msg_ok "Kepemilikan '$SHARE_DIR' -> '$FTP_USER:$FTP_USER'."
    else
        msg_err "Gagal mengubah kepemilikan '$SHARE_DIR'."
        return 1
    fi

    echo -e "\n$DIVIDER"
    echo -e "${GREEN}${BOLD}  🎉 USER FTP SIAP DIGUNAKAN${RESET}"
    echo -e "$DIVIDER"
    echo -e "  ${CYAN}👤 Username  :${RESET} $FTP_USER"
    echo -e "  ${CYAN}🔑 Password  :${RESET} $FTP_PASS"
    echo -e "  ${CYAN}📁 Directory :${RESET} $SHARE_DIR"
    echo -e "  ${CYAN}🌐 Port      :${RESET} 21 (kontrol), 40000-40100 (passive)"
    echo -e "$DIVIDER"
    msg_info "Jika belum bisa connect, pastikan firewall sudah diatur (menu 3)."
    return 0
}

# =============================================================
#  3. SETTING FIREWALL UFW FTP
# =============================================================
setting_firewall() {
    echo -e "\n$DIVIDER"
    msg_step "SETTING FIREWALL UFW UNTUK FTP"
    echo -e "$DIVIDER"

    if ! command -v ufw &>/dev/null; then
        msg_warn "UFW belum terinstall."
        echo ""
        # Matikan bracketed paste
        printf '\e[?2004l'
        read -rp "  Install UFW sekarang? (y/n): " PILIH_UFW
        # Aktifkan kembali bracketed paste
        printf '\e[?2004h'

        case "${PILIH_UFW,,}" in
            y|yes|iya)
                msg_step "Menginstall UFW..."
                apt update -y >/dev/null 2>&1
                if apt install -y ufw >/dev/null 2>&1; then
                    msg_ok "UFW berhasil diinstall."
                else
                    msg_err "Gagal menginstall UFW."
                    return 1
                fi
                ;;
            *)
                msg_warn "Dibatalkan oleh pengguna."
                return 1
                ;;
        esac
    fi

    # --- Input IP subnet jaringan ---
    echo ""
    msg_info "Masukkan subnet jaringan FTP client Anda."
    msg_info "Contoh: ${BOLD}192.168.1.0/24${RESET}  atau  ${BOLD}10.0.0.0/8${RESET}"

    # Matikan bracketed paste
    printf '\e[?2004l'
    read -rp "  🌐 IP Subnet: " IP_SUBNET
    # Aktifkan kembali bracketed paste
    printf '\e[?2004h'

    if [[ -z "$IP_SUBNET" ]]; then
        msg_err "IP subnet tidak boleh kosong."
        return 1
    fi

    # Validasi sederhana format CIDR
    if [[ ! "$IP_SUBNET" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$ ]]; then
        msg_warn "Format '$IP_SUBNET' tidak seperti CIDR (contoh: 192.168.1.0/24)."
        # Matikan bracketed paste
        printf '\e[?2004l'
        read -rp "  Lanjutkan saja? (y/n): " LANJUT
        # Aktifkan kembali bracketed paste
        printf '\e[?2004h'

        case "${LANJUT,,}" in
            y|yes|iya) ;;
            *)
                msg_warn "Dibatalkan oleh pengguna."
                return 1
                ;;
        esac
    fi

    echo ""
    msg_step "Menambahkan aturan firewall untuk $IP_SUBNET..."

    # Port 21 (kontrol FTP)
    if ufw allow from "$IP_SUBNET" to any port 21 proto tcp; then
        msg_ok "Port 21/tcp dibuka untuk $IP_SUBNET"
    else
        msg_err "Gagal membuka port 21/tcp."
    fi

    # Port passive 40000-40100
    if ufw allow from "$IP_SUBNET" to any port 40000:40100 proto tcp; then
        msg_ok "Port 40000:40100/tcp dibuka untuk $IP_SUBNET"
    else
        msg_err "Gagal membuka port 40000:40100/tcp."
    fi

    # Aktifkan & reload firewall
    ufw --force enable >/dev/null 2>&1
    ufw reload >/dev/null 2>&1
    msg_ok "UFW diaktifkan dan di-reload."

    echo -e "\n$DIVIDER"
    echo -e "${CYAN}  📋 Status UFW:${RESET}"
    echo -e "$DIVIDER"
    ufw status numbered | grep -E "21/tcp|40000:40100" || msg_warn "Aturan FTP belum tampil di status UFW."
    echo -e "$DIVIDER"
    return 0
}

# =============================================================
#  DATA USER FTP
# =============================================================
# Sumber data: /etc/passwd (uid 1000..65533) -> "user|home|shell"
ambil_user_ftp() {
    awk -F: '$3 >= 1000 && $3 < 65534 { printf "%s|%s|%s\n", $1, $6, $7 }' /etc/passwd
}

# Klasifikasi tipe akun (teks ASCII agar lebar tabel tetap rapi)
tipe_user() {
    local u="$1" sh="$2" grup
    grup="$(id -nG "$u" 2>/dev/null || true)"
    if [[ " $grup " == *" sudo "* || " $grup " == *" wheel "* || " $grup " == *" adm "* ]]; then
        echo "ADMIN"
    elif [[ "$sh" == */nologin || "$sh" == */false ]]; then
        echo "FTP-ONLY"
    else
        echo "USER"
    fi
}

# local_root dari /etc/vsftpd.conf (bila di-set)
vsftpd_local_root() {
    [[ -f /etc/vsftpd.conf ]] || return 0
    awk -F= '/^[[:space:]]*local_root[[:space:]]*=/ { gsub(/[[:space:]]/, "", $2); print $2 }' /etc/vsftpd.conf | tail -n1
}

# Muat daftar user ke array global USER_FTP_DATA
declare -a USER_FTP_DATA=()
muat_user_ftp() {
    USER_FTP_DATA=()
    local baris
    while IFS= read -r baris; do
        [[ -n "$baris" ]] && USER_FTP_DATA+=("$baris")
    done < <(ambil_user_ftp)
}

# Tabel user bernomor + directory share
tabel_user_ftp() {
    echo -e "  ${GRAY}┌─────┬────────────────────┬──────────────────────────────┬──────────┐${RESET}"
    printf "  ${GRAY}│${RESET} ${BOLD}%-3s${RESET} ${GRAY}│${RESET} ${BOLD}%-18s${RESET} ${GRAY}│${RESET} ${BOLD}%-28s${RESET} ${GRAY}│${RESET} ${BOLD}%-8s${RESET} ${GRAY}│${RESET}\n" "NO" "USER FTP" "DIRECTORY SHARE" "TIPE"
    echo -e "  ${GRAY}├─────┼────────────────────┼──────────────────────────────┼──────────┤${RESET}"

    local no=0 baris u h s t
    for baris in "${USER_FTP_DATA[@]}"; do
        IFS='|' read -r u h s <<< "$baris"
        t="$(tipe_user "$u" "$s")"
        no=$((no + 1))
        if [[ -d "$h" ]]; then
            printf "  ${GRAY}│${RESET} ${GREEN}%-3s${RESET} ${GRAY}│${RESET} ${WHITE}%-18s${RESET} ${GRAY}│${RESET} ${CYAN}%-28s${RESET} ${GRAY}│${RESET} ${YELLOW}%-8s${RESET} ${GRAY}│${RESET}\n" "$no" "$u" "$h" "$t"
        else
            printf "  ${GRAY}│${RESET} ${GREEN}%-3s${RESET} ${GRAY}│${RESET} ${WHITE}%-18s${RESET} ${GRAY}│${RESET} ${RED}%-28s${RESET} ${GRAY}│${RESET} ${YELLOW}%-8s${RESET} ${GRAY}│${RESET}\n" "$no" "$u" "$h" "$t"
        fi
    done

    echo -e "  ${GRAY}└─────┴────────────────────┴──────────────────────────────┴──────────┘${RESET}"
}

# =============================================================
#  5. LIHAT USER FTP + DIRECTORY SHARE
# =============================================================
lihat_user_ftp() {
    judul "DAFTAR USER FTP & DIRECTORY SHARE" "$ICO_FTP"

    muat_user_ftp
    if (( ${#USER_FTP_DATA[@]} == 0 )); then
        msg_warn "Belum ada user FTP yang terdeteksi."
        msg_info "Tambahkan user lewat menu [2]."
        return 1
    fi

    echo ""
    tabel_user_ftp
    echo ""

    local lr baris u h
    lr="$(vsftpd_local_root)"
    [[ -n "$lr" ]] && msg_info "local_root (vsftpd.conf) : ${BOLD}$lr${RESET}"

    echo ""
    echo -e "  ${GRAY}${ICO_DOT} DIRECTORY SHARE${RESET}"
    for baris in "${USER_FTP_DATA[@]}"; do
        IFS='|' read -r u h _ <<< "$baris"
        if [[ -d "$h" ]]; then
            printf "  ${GREEN}▸${RESET} ${WHITE}%-16s${RESET} ${GRAY}→${RESET} ${CYAN}%s${RESET} ${DIM}[%s]${RESET}\n" "$u" "$h" "$(stat -c '%A %U:%G' "$h" 2>/dev/null)"
        else
            printf "  ${RED}▸${RESET} ${WHITE}%-16s${RESET} ${GRAY}→${RESET} ${RED}%s${RESET} ${YELLOW}[directory tidak ada]${RESET}\n" "$u" "$h"
        fi
    done

    echo ""
    msg_info "Total user terdeteksi : ${BOLD}${#USER_FTP_DATA[@]}${RESET}"
    return 0
}

# =============================================================
#  4. HAPUS USER FTP (pilih nomor dari tabel)
# =============================================================
hapus_user_ftp() {
    judul "HAPUS USER FTP" "$ICO_TRASH"

    muat_user_ftp
    if (( ${#USER_FTP_DATA[@]} == 0 )); then
        msg_warn "Tidak ada user yang bisa dihapus."
        return 1
    fi

    echo ""
    tabel_user_ftp
    echo ""

    # Matikan bracketed paste
    printf '\e[?2004l'
    read -rp "  ${ICO_TRASH} Nomor user yang ingin dihapus: " NOMOR
    # Aktifkan kembali bracketed paste
    printf '\e[?2004h'

    if [[ ! "$NOMOR" =~ ^[0-9]+$ ]]; then
        msg_err "Input harus berupa angka. Diterima: '${BOLD}$NOMOR${RESET}'."
        return 1
    fi

    local total=${#USER_FTP_DATA[@]}
    if (( NOMOR < 1 || NOMOR > total )); then
        msg_err "Nomor '$NOMOR' di luar rentang (1 - $total)."
        return 1
    fi

    local u h s
    IFS='|' read -r u h s <<< "${USER_FTP_DATA[$((NOMOR - 1))]}"
    [[ -n "$s" ]] || true

    if userdel -r "$u" 2>/dev/null; then
        echo ""
        echo -e "  ${GREEN}${BOLD}▓▒░ BERHASIL DELETE USER FTP : $u ░▒▓${RESET}"
        msg_info "Home directory ikut dihapus : $h"
    elif userdel "$u" 2>/dev/null; then
        echo ""
        echo -e "  ${GREEN}${BOLD}▓▒░ BERHASIL DELETE USER FTP : $u ░▒▓${RESET}"
        msg_warn "Home directory '$h' belum terhapus (kemungkinan ada proses aktif)."
    else
        msg_err "Gagal menghapus user '$u'."
        return 1
    fi
    return 0
}

# =============================================================
#  BONUS: STATUS SERVICE VSFTPD
# =============================================================
status_ftp() {
    judul "STATUS SERVICE VSFTPD" "$ICO_SCAN"

    if ! command -v vsftpd &>/dev/null; then
        msg_warn "vsftpd belum terinstall. Jalankan menu 1 untuk install."
        return 1
    fi

    if systemctl is-active --quiet vsftpd; then
        msg_ok "Service vsftpd ${BOLD}AKTIF${RESET} (running)."
    else
        msg_warn "Service vsftpd ${BOLD}TIDAK AKTIF${RESET}."
    fi

    echo ""
    systemctl status vsftpd --no-pager -l 2>/dev/null | head -n 12 | sed 's/^/  /'
    return 0
}

# =============================================================
#  MAIN LOOP
# =============================================================
while true; do
    tampil_header

    echo -e "  ${PURPLE}╭${RULE}${PURPLE}╮${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${PINK}${BOLD}▓▒░ MENU UTAMA ░▒▓${RESET}  ${DIM}ftp / vsftpd control${RESET}"
    echo -e "  ${PURPLE}├${RULE}${PURPLE}┤${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${GREEN}[1]${RESET} ${ICO_GEAR}  Install FTP ${DIM}(vsftpd)${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${GREEN}[2]${RESET} ${ICO_USER} Tambah User FTP ${DIM}+ directory share${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${GREEN}[3]${RESET} ${ICO_SHIELD} Setting Firewall UFW ${DIM}(subnet FTP)${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${GREEN}[4]${RESET} ${ICO_TRASH} Hapus User FTP ${DIM}(pilih nomor)${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${GREEN}[5]${RESET} ${ICO_FTP} Lihat User FTP ${DIM}+ directory share${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${GREEN}[6]${RESET} ${ICO_SCAN} Status Service vsftpd"
    echo -e "  ${PURPLE}├${RULE}${PURPLE}┤${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${CYAN}[0]${RESET} ${ICO_BACK} Kembali ke Menu Utama"
    echo -e "  ${PURPLE}│${RESET}  ${RED}[X]${RESET} ${ICO_NO} Keluar"
    echo -e "  ${PURPLE}╰${RULE}${PURPLE}╯${RESET}"
    echo ""
    echo -e "  ${GRAY}root@mamat${RESET} ${PURPLE}[${PINK}ftp-manager${PURPLE}]${RESET} ${DIM}~${RESET}"
    echo -e -n "  ${CYAN}└──▶ ${RESET}"

    # Matikan bracketed paste
    printf '\e[?2004l'
    # read gagal = EOF (stdin habis / dijalankan non-interaktif) -> keluar,
    # supaya menu tidak berputar tanpa henti.
    if ! read -r PILIHAN; then
        # Aktifkan kembali bracketed paste
        printf '\e[?2004h'
        echo ""
        exit 0
    fi
    # Aktifkan kembali bracketed paste
    printf '\e[?2004h'

    case "$PILIHAN" in
        1|01) install_ftp        ; pause ;;
        2|02) tambah_user_ftp    ; pause ;;
        3|03) setting_firewall   ; pause ;;
        4|04) hapus_user_ftp      ; pause ;;
        5|05) lihat_user_ftp      ; pause ;;
        6|06) status_ftp         ; pause ;;
        0|00) clear ; exec bash "$SCRIPT_SELF" ;;
        x|X)  clear ; echo -e "${PINK}  ▓▒░ DISCONNECTED FROM THE GRID ░▒▓${RESET}" ; echo "" ; exit 0 ;;
        *)    echo "" ; echo -e "  ${RED}${ICO_NO} Pilihan '${PILIHAN}' tidak valid.${RESET}" ; sleep 1 ;;
    esac
done
