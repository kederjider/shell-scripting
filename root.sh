#!/bin/bash
# root-deluxe.sh - Enable Root SSH + Set Password dengan Tampilan Mewah
# Dibuat oleh Mamat untuk pecundang yang hobi pamer terminal berwarna.

set -e  # Biar script langsung berhenti kalo ada error, jangan ngeyel.

# ===================== DEFINISI WARNA & IKON =====================
RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"
ITALIC="\e[3m"
UNDERLINE="\e[4m"
BLACK="\e[30m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
BG_RED="\e[41m"
BG_GREEN="\e[42m"
BG_YELLOW="\e[43m"
BG_BLUE="\e[44m"
BG_MAGENTA="\e[45m"
BG_CYAN="\e[46m"

# Ikon (gunakan emoji jika terminal support, jika tidak fallback ke teks)
CHECK_MARK="✅"
CROSS_MARK="❌"
WARNING="⚠️"
INFO="ℹ️"
KEY="🔑"
GEAR="⚙️"
LOCK="🔒"
UNLOCK="🔓"
ROCKET="🚀"
BOX="📦"
SHIELD="🛡️"
LINK="🔗"
ARROW="➡️"
STAR="⭐"
BROKEN="💔"
QUESTION="❓"
HAPPY="😎"
ANGRY="😡"
FIRE="🔥"

# Cek apakah terminal support emoji (fallback ke teks biasa jika tidak)
if [[ "$LANG" != *.UTF-8 ]] || ! tty -s; then
    CHECK_MARK="[OK]"
    CROSS_MARK="[FAIL]"
    WARNING="[WARN]"
    INFO="[INFO]"
    KEY="(key)"
    GEAR="(gear)"
    LOCK="(locked)"
    UNLOCK="(unlocked)"
    ROCKET="(rocket)"
    BOX="(box)"
    SHIELD="(shield)"
    LINK="(link)"
    ARROW="->"
    STAR="(*)"
    BROKEN="(broken)"
    QUESTION="(?)"
    HAPPY=":)"
    ANGRY=">:("
    FIRE="(fire)"
fi

# Fungsi utilitas untuk output berwarna
print_header() {
    echo -e "${BOLD}${CYAN}${STAR} ${1} ${STAR}${RESET}"
    echo -e "${DIM}${CYAN}$(printf '─%.0s' {1..50})${RESET}"
}

print_success() {
    echo -e "${GREEN}${CHECK_MARK} ${BOLD}${1}${RESET}"
}

print_error() {
    echo -e "${RED}${CROSS_MARK} ${BOLD}${1}${RESET}" >&2
}

print_warning() {
    echo -e "${YELLOW}${WARNING} ${BOLD}${1}${RESET}"
}

print_info() {
    echo -e "${BLUE}${INFO} ${1}${RESET}"
}

print_step() {
    echo -e "${MAGENTA}${ARROW} ${BOLD}Step ${1}:${RESET} ${2}"
}

ask_password() {
    local prompt="$1"
    local password
    echo -en "${BOLD}${YELLOW}${prompt}${RESET}"
    read -s password
    echo
    if [[ -z "$password" ]]; then
        print_error "Password tidak boleh kosong."
        exit 1
    fi
    echo "$password"
}

# ===================== MULAI EKSEKUSI =====================
clear
echo -e "\n${BOLD}${BG_CYAN}${BLACK}  ROOT SSH ENABLER  ${RESET}\n"
echo -e "${DIM}Created by Mamat - For educational & personal use only${RESET}\n"

# Cek root/sudo
if [[ "$EUID" -ne 0 ]]; then
    print_error "Script ini harus dijalankan dengan sudo, bangsat!"
    echo -e "${DIM}Gunakan: sudo bash $0${RESET}"
    exit 1
fi

# ===================== LANGKAH 1: SET PASSWORD ROOT =====================
print_step 1 "Konfigurasi Password Root"
echo -e "${DIM}Kita mulai dengan password root yang baru. Jangan pake '123456', tolol.${RESET}\n"

# Tampilkan petunjuk password yang kuat
echo -e "${ITALIC}${DIM}   • Minimal 8 karakter${RESET}"
echo -e "${ITALIC}${DIM}   • Kombinasi huruf besar/kecil, angka, simbol${RESET}"
echo -e "${ITALIC}${DIM}   • Jangan pake nama binatang peliharaan lo${RESET}\n"

echo -en "${BOLD}${YELLOW}${KEY} Masukkan password root baru: ${RESET}"
read -s root_pass
echo
echo -en "${BOLD}${YELLOW}${KEY} Konfirmasi password root: ${RESET}"
read -s root_pass_confirm
echo

if [[ "$root_pass" != "$root_pass_confirm" ]]; then
    print_error "Password tidak cocok."
    exit 1
fi

if [[ ${#root_pass} -lt 8 ]]; then
    print_warning "Password minimal 8 karakter."
    exit 1
fi

    # Set password root non-interaktif
    echo ""
    if echo "root:$root_pass" | chpasswd >/dev/null 2>&1; then
        print_success "Password root berhasil diset."
    else
        print_error "Gagal menyetel password root. Periksa error di atas."
        exit 1
    fi

    # Unlock akun root jika terkunci
    passwd -u root >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        print_success "Akun root sudah di-unlock (bila sebelumnya terkunci)."
    else
        print_warning "Tidak bisa unlock akun root, mungkin sudah unlocked."
    fi


# ===================== LANGKAH 2: KONFIGURASI SSH =====================
print_step 2 "Konfigurasi SSH Server"
echo -e "${DIM}Mengaktifkan PermitRootLogin dan memastikan PasswordAuthentication on...${RESET}\n"

ssh_config="/etc/ssh/sshd_config"
backup="${ssh_config}.bak-deluxe-$(date +%Y%m%d-%H%M%S)"

# Backup file konfigurasi
cp "$ssh_config" "$backup"
if [[ -f "$backup" ]]; then
    print_success "Backup konfigurasi SSH disimpan di: ${UNDERLINE}${backup}${RESET}"
else
    print_error "Gagal membuat backup. Hentikan."
    exit 1
fi

# Baca status sebelumnya untuk ditampilkan
old_permit=$(grep -E '^\s*PermitRootLogin\s+' "$ssh_config" | tail -1 | awk '{print $2}')
old_password=$(grep -E '^\s*PasswordAuthentication\s+' "$ssh_config" | tail -1 | awk '{print $2}')
[[ -z "$old_permit" ]] && old_permit="(tidak diset)"
[[ -z "$old_password" ]] && old_password="(default)"

# Fungsi set_config
set_config() {
    local key="$1" value="$2"
    if grep -Eq "^\s*${key}\s+" "$ssh_config"; then
        sed -i "s|^[#\s]*${key}\s.*|${key} ${value}|" "$ssh_config"
    else
        echo "${key} ${value}" >> "$ssh_config"
    fi
}

# Ubah konfigurasi
set_config "PermitRootLogin" "yes"
set_config "PasswordAuthentication" "yes"

# Baca status baru
new_permit=$(grep -E '^\s*PermitRootLogin\s+' "$ssh_config" | tail -1 | awk '{print $2}')
new_password=$(grep -E '^\s*PasswordAuthentication\s+' "$ssh_config" | tail -1 | awk '{print $2}')

# ===================== TABEL PERUBAHAN =====================
echo -e "\n${BOLD}${WHITE}TABEL PERUBAHAN KONFIGURASI SSH${RESET}"
printf "${DIM}%s${RESET}\n" "──────────────────────────────────────────"
printf "%-30s ${YELLOW}%s${RESET} ${GREEN}%s${RESET}\n" "Parameter" "Sebelum" "Sesudah"
printf "%s\n" "──────────────────────────────────────────"
printf "%-30s ${YELLOW}%-15s${RESET} ${GREEN}%-15s${RESET}\n" "PermitRootLogin" "$old_permit" "$new_permit"
printf "%-30s ${YELLOW}%-15s${RESET} ${GREEN}%-15s${RESET}\n" "PasswordAuthentication" "$old_password" "$new_password"
printf "%s\n" "──────────────────────────────────────────"

# ===================== LANGKAH 3: RESTART SSH SERVICE =====================
print_step 3 "Restart SSH Service"
echo -e "${DIM}Sedang merestart layanan SSH...${RESET}"

restart_success=0
if systemctl is-active sshd >/dev/null 2>&1; then
    if systemctl restart sshd 2>/dev/null; then
        restart_success=1
    fi
elif systemctl is-active ssh >/dev/null 2>&1; then
    if systemctl restart ssh 2>/dev/null; then
        restart_success=1
    fi
elif service ssh status >/dev/null 2>&1; then
    service ssh restart >/dev/null 2>&1 && restart_success=1
elif /etc/init.d/ssh status >/dev/null 2>&1; then
    /etc/init.d/ssh restart >/dev/null 2>&1 && restart_success=1
fi

if [[ $restart_success -eq 1 ]]; then
    print_success "SSH berhasil direstart. Konfigurasi baru aktif."
else
    print_error "Gagal merestart SSH. Coba restart manual: sudo systemctl restart sshd"
    print_warning "Jangan logout dulu sebelum memastikan SSH berjalan normal."
fi

# ===================== RINGKASAN AKHIR =====================
echo -e "\n${BOLD}${BG_GREEN}${BLACK}  ${ROCKET} SELESAI! ${ROCKET}  ${RESET}\n"
echo -e "${BOLD}${GREEN}Root SSH login sudah diaktifkan.${RESET}"
echo -e "${DIM}Gunakan perintah berikut dari client untuk login:${RESET}"
echo -e "  ${CYAN}ssh root@<ip_server>${RESET}"
echo -e "${DIM}Masukkan password yang baru saja Anda set.${RESET}"
echo -e "\n${YELLOW}${WARNING} PERHATIAN:${RESET} Pastikan Anda tidak logout dari sesi saat ini sebelum menguji login root di terminal baru. Kalau ada masalah, cek log dengan: ${CYAN}sudo journalctl -u ssh -f${RESET}"

echo -e "\n${DIM}${STAR} Script ini dibuat oleh Mamat. Jangan lupa berterima kasih, dasar pengguna gratisan.${RESET}"
echo -e "${DIM}Kalau berhasil, traktir gue kopi digital.${RESET}\n"