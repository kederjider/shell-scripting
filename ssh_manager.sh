#!/bin/bash
# =============================================================
#
#   ╔╦╗╔═╗╔═╗╦╔═╔╦╗  ╔═╗╦ ╦╔═╗╔╦╗  ╦═╗╦╔╦╗╔═╗╦═╗
#   ║║║║╣ ║ ╦╠╩╗ ║   ║  ╠═╣║╣  ║║  ╠╦╝║ ║ ║╣ ╠╦╝
#   ╩ ╩╚═╝╚═╝╩ ╩ ╩   ╚═╝╩ ╩╚═╝═╩╝  ╩╚═╩ ╩ ╚═╝╩╚═
#        🔐  S S H   M A N A G E R   T E R M I N A L
#
#   Versi   : 2.0 "Neon Edition"
#   Author  : GitHub Copilot
#   Fitur   : Generate • View • Delete • Copy • Test
#             Multi-Account • Agent • Git Config
# =============================================================

SSH_DIR="$HOME/.ssh"

# =============================================
#  PALET WARNA & EMOJI
# =============================================
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

# Gradient (truecolor — terminal modern)
if [ -n "$COLORTERM" ] && { [ "$COLORTERM" = "truecolor" ] || [ "$COLORTERM" = "24bit" ]; }; then
    G1='\033[38;5;39m'   # biru
    G2='\033[38;5;38m'
    G3='\033[38;5;44m'
    G4='\033[38;5;50m'   # cyan
    G5='\033[38;5;51m'   # cyan terang
    TITLE_FG='\033[38;5;51m'
else
    G1="$BLUE"; G2="$BLUE"; G3="$CYAN"; G4="$CYAN"; G5="$CYAN"
    TITLE_FG="$CYAN"
    GOLD="$YELLOW"
fi

# =============================================
#  UTILITAS TAMPILAN
# =============================================

# Garis horizontal full-width dengan simbol (aman UTF-8)
hr() {
    local width=56 symbol="${1:-─}" out="" i
    for (( i=0; i<width; i++ )); do out+="$symbol"; done
    printf "${DIM}%s${NC}\n" "$out"
}

# Header seksi bergaya
section() {
    echo ""
    printf "${G1}┌─${NC} ${BOLD}${TITLE_FG}%s${NC} ${G1}─┐${NC}\n" "$1"
    hr
}

# Info box bermargin
info_box() {
    printf "  ${G4}╭─${NC} %s\n" "$1"
    shift
    for line in "$@"; do
        printf "  ${G4}│${NC}  %s\n" "$line"
    done
    printf "  ${G4}╰─────────────${NC}\n"
}

# Pesan status
msg_ok()     { printf "  ${GREEN}✔${NC} %b\n" "$1"; }
msg_err()    { printf "  ${RED}✘${NC} %b\n" "$1"; }
msg_warn()   { printf "  ${YELLOW}⚠${NC} %b\n" "$1"; }
msg_info()   { printf "  ${G4}ℹ${NC} %b\n" "$1"; }
msg_step()   { printf "  ${DIM}▸${NC} %b ${DIM}%b${NC}\n" "$1" "${2:-…}"; }

# Spinner animasi: spinner "pid" & pesan
spinner() {
    local pid=$1 msg=$2 sp='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    printf "\r  ${G4}%s${NC} ${DIM}%s${NC}" '⠋' "$msg"
    while kill -0 "$pid" 2>/dev/null; do
        for (( j=0; j<${#sp}; j++ )); do
            printf "\r  ${G5}%s${NC} ${DIM}%s${NC}" "${sp:$j:1}" "$msg"
            sleep 0.08
        done
    done
    printf "\r\033[K"
}

# Progress bar sederhana
progress_bar() {
    local pct=$1 label="${2:-Memproses}"
    local filled=$(( pct * 30 / 100 ))
    printf "\r  ${G5}[${NC}"
    for (( k=0; k<filled; k++ )); do printf "${G4}█${NC}"; done
    for (( k=filled; k<30; k++ )); do printf "${DIM}░${NC}"; done
    printf "${G5}]${NC} %3d%% ${DIM}%s${NC}" "$pct" "$label"
}

# Tampilkan dengan efek typewriter (cepat) — aman untuk UTF-8/emoji
typewriter() {
    local text="$1" delay="${2:-0.01}" i=0 ch
    while [ $i -lt ${#text} ]; do
        printf "%s" "${text:$i:1}"
        ((i++))
    done
    echo ""
}

# Bersihkan layar dengan header tetap terlihat
clear_screen() {
    clear
    print_banner
}

# Banner gradient — per-karakter agar alignment aman
print_banner() {
    echo -e ""
    echo -e "  ${G1}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${G1}║${NC}                                                          ${G1}║${NC}"
    echo -e "  ${G1}║${NC}    ${G1}S${G2}S${G3}H${NC} ${G4}&${NC} ${G4}G${G5}I${G5}T${NC} ${G5}M${G5}A${G5}N${G5}A${G5}G${G5}E${G5}R${NC}                                     ${G1}║${NC}"
    echo -e "  ${G1}║${NC}                                                          ${G1}║${NC}"
    echo -e "  ${G1}║${NC}    ${DIM}🔐 T E R M I N A L   E D I T I O N   v 2 . 0${NC}          ${G1}║${NC}"
    echo -e "  ${G1}║${NC}                                                          ${G1}║${NC}"
    echo -e "  ${G1}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Prompt pilihan dengan styling
prompt() {
    printf "  ${G5}❯${NC} ${BOLD}%b${NC}" "$1"
}

separator_alert() {
    printf "  ${RED}▓▒░ %b ░▒▓${NC}\n" "$1"
}

# =============================================
#  FUNGSI-FUNGSI UTAMA
# =============================================

init_ssh_dir() {
    if [ ! -d "$SSH_DIR" ]; then
        mkdir -p "$SSH_DIR" && chmod 700 "$SSH_DIR"
        msg_ok "Folder ${BOLD}~/.ssh${NC} dibuat (permission 700)"
    fi
}

# Kumpulkan semua public key ke array global KEYS
collect_keys() {
    KEYS=()
    while IFS= read -r f; do
        [ -n "$f" ] && KEYS+=("$f")
    done < <(find "$SSH_DIR" -maxdepth 1 -name "*.pub" -type f 2>/dev/null | sort)
}

# Tampilkan tabel key dengan nomor
display_keys_table() {
    printf "  ${DIM}┌────┬─────────────────────────┬──────────────────────────────┐${NC}\n"
    printf "  ${DIM}│ ${BOLD}${G4}No.${NC}${DIM} │ ${BOLD}${G4}Nama Key${NC}               │ ${BOLD}${G4}Comment / Email${NC}             ${DIM}│${NC}\n"
    printf "  ${DIM}├────┼─────────────────────────┼──────────────────────────────┤${NC}\n"
    local i=1
    for pub in "${KEYS[@]}"; do
        local name=$(basename "$pub")
        local comment=$(ssh-keygen -l -f "$pub" 2>/dev/null | awk '{print $NF}')
        printf "  ${DIM}│${NC} ${G5}%-2d${NC} ${DIM}│${NC} ${CYAN}%-23s${NC} ${DIM}│${NC} ${DIM}%s${NC}\n" "$i" "$name" "$comment"
        ((i++))
    done
    printf "  ${DIM}└────┴─────────────────────────┴──────────────────────────────┘${NC}\n"
}

select_key() {  # $1 = judul aksi, hasil: SELECTED_PUB
    collect_keys
    if [ ${#KEYS[@]} -eq 0 ]; then
        msg_warn "Belum ada SSH key di ${BOLD}~/.ssh${NC}. Buat dulu lewat menu ${G5}[1]${NC}."
        return 1
    fi
    section "$1"
    echo ""
    display_keys_table
    echo ""
    prompt "Pilih nomor key: "
    read choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#KEYS[@]} ]; then
        SELECTED_PUB="${KEYS[$((choice-1))]}"
        return 0
    fi
    msg_err "Pilihan tidak valid."
    return 1
}

# ---------- MENU 1 : GENERATE ----------
generate_ssh_key() {
    section "⚡ GENERATE SSH KEY BARU"
    echo ""

    # Animasi kecil sebelum input
    printf "  ${G4}◆${NC} ${DIM}Algoritma: Ed25519 (modern, aman, ringan)${NC}\n\n"

    prompt "Email GitHub kamu        : "
    read email
    [ -z "$email" ] && { msg_err "Email wajib diisi."; return; }

    prompt "Nama file (id_ed25519)   : "
    read key_name
    key_name=${key_name:-id_ed25519}
    key_path="$SSH_DIR/$key_name"

    if [ -f "$key_path" ]; then
        msg_warn "Key ${BOLD}'$key_name'${NC} sudah ada!"
        prompt "Timpa key lama? (y/n)    : "
        read confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            msg_err "Dibatalkan."
            return
        fi
        rm -f "$key_path" "$key_path.pub"
    fi

    # Generate dengan progress animation
    echo ""
    ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N "" -q 2>/dev/null &
    local pid=$!
    if kill -0 $pid 2>/dev/null; then
        spinner $pid "Membuat key Ed25519..."
        wait $pid
    fi

    if [ -f "$key_path.pub" ]; then
        echo ""
        msg_ok "${BOLD}SSH key berhasil dibuat!${NC} 🎉"
        echo ""
        info_box "📁 Lokasi File" \
                 "Private  → $key_path" \
                 "Public   → $key_path.pub"
        echo ""

        # Tambah ke agent
        msg_step "Mendaftarkan ke ssh-agent..."
        eval "$(ssh-agent -s)" >/dev/null 2>&1
        ssh-add "$key_path" 2>/dev/null && msg_ok "Key aktif di ssh-agent" || msg_warn "Gagal menambah ke agent (tidak masalah)"

        echo ""
        separator_alert "PENTING — SALIN KE GITHUB"
        echo -e "  ${G4}GitHub → Settings → SSH and GPG keys → New SSH key${NC}"
        echo ""
        printf "  ${DIM}┌${NC} ${BOLD}${G5}PUBLIC KEY${NC} ${DIM}────────────────────────────────────┐${NC}\n"
        printf "  ${DIM}│${NC} "
        cat "$key_path.pub" | head -c 60
        printf "...${NC}\n"
        printf "  ${DIM}└──────────────────────────────────────────────────┘${NC}\n"
        echo ""
        msg_info "Lihat full key lewat menu ${G5}[3]${NC} atau salin lewat menu ${G5}[5]${NC}."
    else
        msg_err "Gagal membuat SSH key."
    fi
}

# ---------- MENU 2 : LIST ----------
list_ssh_keys() {
    collect_keys
    section "📋 DAFTAR SSH KEY"
    echo ""
    if [ ${#KEYS[@]} -eq 0 ]; then
        msg_warn "Tidak ada SSH key ditemukan di ${BOLD}~/.ssh${NC}"
        echo ""
        local c
        prompt "Buat sekarang? (y/n): "
        read c
        [ "$c" = "y" ] || [ "$c" = "Y" ] && generate_ssh_key
        return
    fi
    display_keys_table
    local total=${#KEYS[@]}
    echo ""
    msg_info "Total: ${BOLD}${G5}$total${NC} key terdaftar ${DIM}($SSH_DIR)${NC}"
}

# ---------- MENU 3 : VIEW ----------
view_public_key() {
    select_key "👁  LIHAT PUBLIC KEY" || return
    local pub="$SELECTED_PUB"

    echo ""
    printf "  ${DIM}┌${NC} ${BOLD}${G5}PUBLIC KEY${NC} ${DIM}— $(basename "$pub")${NC} ${DIM}────────────┐${NC}\n"
    echo -e "  ${DIM}│${NC}"
    while IFS= read -r line; do
        echo -e "  ${DIM}│${NC} ${CYAN}$line${NC}"
    done < "$pub"
    echo -e "  ${DIM}│${NC}"
    printf "  ${DIM}└──────────────────────────────────────────────────┘${NC}\n"
}

# ---------- MENU 4 : DELETE ----------
delete_ssh_key() {
    select_key "🗑  HAPUS SSH KEY" || return
    local pub="$SELECTED_PUB"
    local private="${pub%.pub}"

    echo ""
    printf "  ${RED}┌─ ⚠ PERINGATAN ────────────────────────────────────┐${NC}\n"
    printf "  ${RED}│${NC} Key berikut akan dihapus permanen:            ${RED}│${NC}\n"
    printf "  ${RED}└──────────────────────────────────────────────────┘${NC}\n"
    echo -e "    ${RED}✘${NC} ${YELLOW}$pub${NC}"
    echo -e "    ${RED}✘${NC} ${YELLOW}$private${NC}"
    echo ""
    prompt "Yakin ingin menghapus? ${RED}(ketik: hapus)${NC} : "
    read confirm
    if [ "$confirm" = "hapus" ]; then
        rm -f "$pub" "$private"
        msg_ok "SSH key berhasil dihapus. 🗑"
    else
        msg_info "Dibatalkan — key tetap aman. ✅"
    fi
}

# ---------- MENU 5 : COPY ----------
copy_public_key() {
    select_key "📋 SALIN PUBLIC KEY" || return
    local pub="$SELECTED_PUB"

    echo ""
    if command -v xclip &>/dev/null; then
        xclip -selection clipboard < "$pub"
        msg_ok "Public key disalin ke clipboard ${DIM}(xclip)${NC} 📋"
    elif command -v xsel &>/dev/null; then
        xsel --clipboard --input < "$pub"
        msg_ok "Public key disalin ke clipboard ${DIM}(xsel)${NC} 📋"
    elif command -v wl-copy &>/dev/null; then
        wl-copy < "$pub"
        msg_ok "Public key disalin ke clipboard ${DIM}(wl-copy/Wayland)${NC} 📋"
    elif command -v pbcopy &>/dev/null; then
        pbcopy < "$pub"
        msg_ok "Public key disalin ke clipboard ${DIM}(pbcopy/macOS)${NC} 📋"
    else
        msg_warn "Tidak ada clipboard tool. Install: ${G4}sudo apt install xclip${NC}"
        echo ""
        msg_info "Salin manual key di bawah ini:"
        echo ""
        printf "  ${DIM}┌${NC} ${BOLD}${G5}PUBLIC KEY${NC} ${DIM}────────────────────────────────────┐${NC}\n"
        sed 's/^/  │ /' "$pub"
        printf "  ${DIM}└──────────────────────────────────────────────────┘${NC}\n"
    fi
}

# ---------- MENU 6 : TEST ----------
test_github_connection() {
    section "🛰  TEST KONEKSI KE GITHUB"
    echo ""
    msg_step "Menghubungi ${G4}git@github.com${NC} ..."

    # progress palsu biar keren
    for pct in 10 30 50 70 90 100; do progress_bar $pct "menghubungi github.com"; sleep 0.15; done
    printf "\r\033[K"

    local output
    output=$(ssh -Tn git@github.com 2>&1)
    echo ""

    if echo "$output" | grep -q "successfully authenticated"; then
        msg_ok "🎉 ${BOLD}Koneksi berhasil!${NC} GitHub mengenal kamu."
        echo ""
        local user=$(echo "$output" | sed -n 's/Hi \(.*\)! You.*/\1/p' | tr -d "'")
        [ -n "$user" ] && info_box "🐙 GitHub User" "Username → $user"
    elif echo "$output" | grep -q "Permission denied"; then
        msg_err "❌ Koneksi ditolak (Permission denied)."
        echo ""
        info_box "💡 Solusi Cepat" \
                 "1. Pastikan public key sudah ditambah di GitHub" \
                 "2. Jalankan menu [9] untuk reload ssh-agent" \
                 "3. Cek ~/.ssh/config jika pakai multi-account"
    else
        msg_warn "Respon tidak dikenal:"
        echo -e "  ${DIM}$output${NC}"
    fi
}

# ---------- MENU 7 : MULTI ACCOUNT ----------
setup_ssh_config() {
    select_key "🧩 SETUP SSH CONFIG (MULTI-ACCOUNT)" || return
    local pub="$SELECTED_PUB"
    local private="${pub%.pub}"

    echo ""
    prompt "Host alias (github-work) : "
    read host_alias
    host_alias=${host_alias:-github-work}

    prompt "Username GitHub          : "
    read gh_user

    local config_file="$SSH_DIR/config"
    touch "$config_file"

    cat >> "$config_file" <<EOF

# ── $gh_user ─ $(date +%Y-%m-%d) ──
Host $host_alias
    HostName github.com
    User git
    IdentityFile $private
    IdentitiesOnly yes
EOF

    echo ""
    msg_ok "Config ${BOLD}'$host_alias'${NC} ditambahkan ke ~/.ssh/config 🧩"
    echo ""
    info_box "🔗 Cara Pakai" \
             "Clone   → git clone git@${host_alias}:${gh_user}/repo.git" \
             "Remote  → git remote set-url git@${host_alias}:${gh_user}/repo.git"
}

# ---------- MENU 8 : VIEW CONFIG ----------
view_ssh_config() {
    section "📄 SSH CONFIG (~/.ssh/config)"
    echo ""
    local config_file="$SSH_DIR/config"
    if [ -f "$config_file" ] && [ -s "$config_file" ]; then
        # Tampilkan config dengan highlight Host
        while IFS= read -r line; do
            case "$line" in
                Host\ *)  echo -e "  ${G5}${BOLD}$line${NC}" ;;
                \#*)      echo -e "  ${DIM}$line${NC}" ;;
                "")       echo "" ;;
                *)        echo -e "  ${CYAN}$line${NC}" ;;
            esac
        done < "$config_file"
    else
        msg_warn "File config masih kosong / belum ada."
        msg_info "Buat lewat menu ${G5}[7]${NC} (Setup Multi-Account)."
    fi
}

# ---------- MENU 9 : SSH AGENT ----------
start_ssh_agent() {
    section "🤖 SSH AGENT MANAGER"
    echo ""
    collect_keys
    if [ ${#KEYS[@]} -eq 0 ]; then
        msg_warn "Tidak ada SSH key ditemukan."
        return
    fi

    eval "$(ssh-agent -s)" >/dev/null 2>&1
    msg_ok "ssh-agent berjalan ${DIM}(PID: $SSH_AGENT_PID)${NC}"
    echo ""

    for pub in "${KEYS[@]}"; do
        local private="${pub%.pub}"
        if [ -f "$private" ]; then
            ssh-add "$private" 2>/dev/null \
                && msg_ok "Loaded  → $(basename "$private")" \
                || msg_err "Gagal   → $(basename "$private")"
        fi
    done

    echo ""
    msg_step "Key aktif di agent:"
    local count=0
    while IFS= read -r line; do
        [ -n "$line" ] && { echo -e "  ${G4}◆${NC} ${DIM}$line${NC}"; ((count++)); }
    done < <(ssh-add -l 2>/dev/null)
    [ "$count" -eq 0 ] && msg_warn "Tidak ada key di agent."
}

# ---------- MENU 10 : GIT CONFIG ----------
setup_git_config() {
    section "⚙️  GIT GLOBAL CONFIG"
    echo ""

    # Tampilkan config saat ini
    local cur_name=$(git config --global user.name 2>/dev/null)
    local cur_email=$(git config --global user.email 2>/dev/null)
    if [ -n "$cur_name" ] || [ -n "$cur_email" ]; then
        info_box "📌 Config Saat Ini" \
                 "user.name  = ${cur_name:-—}" \
                 "user.email = ${cur_email:-—}"
        echo ""
    fi

    prompt "Nama GitHub              : "
    read git_name
    prompt "Email GitHub             : "
    read git_email
    [ -z "$git_name" ] || [ -z "$git_email" ] && { msg_err "Nama & email wajib diisi."; return; }

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main

    echo ""
    msg_ok "Git global config tersimpan! ⚙️"
    echo ""
    info_box "✅ Aktif Sekarang" \
             "user.name       → $git_name" \
             "user.email      → $git_email" \
             "defaultBranch   → main"
}

# ---------- MENU 11 : BANTUAN ----------
show_help() {
    section "❓ PANDUAN CEPAT"
    echo ""
    info_box "🚀 Baru pertama kali? Ikuti urutan ini" \
             "[1]  Generate SSH key baru" \
             "[5]  Salin public key ke clipboard" \
             "     → Buka github.com → Settings → SSH keys → paste" \
             "[6]  Test koneksi (harus muncul 'Hi <username>!')" \
             "[10] Set identitas git (nama & email)"
    echo ""
    info_box "🧩 Multi-Account GitHub" \
             "[7]  Daftarkan tiap akun dengan alias berbeda" \
             "     Contoh: github-work → kunci kantor" \
             "             github-personal → kunci pribadi" \
             "     Pakai git@github-work:user/repo.git saat clone"
    echo ""
    info_box "💡 Tips" \
             "[9] Jalankan ulang agent kalau key tidak terbaca" \
             "[4] Hapus key butuh konfirmasi ketik 'hapus' (aman dari salah tekan)" \
             "     Script & key ada di ~/.ssh — jangan dibagikan private key!"
}

# =============================================
#  MENU UTAMA
# =============================================
show_menu() {
    clear_screen
    # Status ringkas di bawah banner
    local n_keys=0
    collect_keys; n_keys=${#KEYS[@]}
    local agent_status=$(ssh-add -l &>/dev/null | head -1)
    if [ "$n_keys" -gt 0 ]; then
        printf "  ${DIM}Status:${NC} ${GREEN}●${NC} %s key di ~/.ssh   ${DIM}│${NC}  🐙 github.com\n" "$n_keys"
    else
        printf "  ${DIM}Status:${NC} ${YELLOW}●${NC} belum ada key   ${DIM}│${NC}  🐙 github.com\n"
    fi
    echo ""

    echo -e "  ${G1}╭───${NC} ${BOLD}${G5}MENU UTAMA${NC}"
    echo -e "  ${G1}│${NC}"
    echo -e "  ${G1}│${NC}   ${G5}01${NC} ${CYAN}⚡${NC}  Generate SSH Key Baru"
    echo -e "  ${G1}│${NC}   ${G5}02${NC} ${CYAN}📋${NC}  Lihat Daftar SSH Key"
    echo -e "  ${G1}│${NC}   ${G5}03${NC} ${CYAN}👁${NC}   Lihat Isi Public Key"
    echo -e "  ${G1}│${NC}   ${G5}04${NC} ${CYAN}🗑${NC}   Hapus SSH Key"
    echo -e "  ${G1}│${NC}   ${G5}05${NC} ${CYAN}📋${NC}  Salin Public Key ke Clipboard"
    echo -e "  ${G1}│${NC}   ${G5}06${NC} ${CYAN}🛰${NC}   Test Koneksi ke GitHub"
    echo -e "  ${G1}│${NC}   ${G5}07${NC} ${CYAN}🧩${NC}  Setup Multi-Account GitHub"
    echo -e "  ${G1}│${NC}   ${G5}08${NC} ${CYAN}📄${NC}  Lihat SSH Config"
    echo -e "  ${G1}│${NC}   ${G5}09${NC} ${CYAN}🤖${NC}  SSH Agent Manager"
    echo -e "  ${G1}│${NC}   ${G5}10${NC} ${CYAN}⚙️${NC}  Git Global Config"
    echo -e "  ${G1}│${NC}   ${G5}11${NC} ${CYAN}❓${NC}  Panduan / Bantuan"
    echo -e "  ${G1}│${NC}"
    echo -e "  ${G1}│${NC}   ${RED}00${NC} ${RED}🚪${NC}  Keluar"
    echo -e "  ${G1}│${NC}"
    echo -e "  ${G1}╰${NC}"
    echo ""

    prompt "Pilih menu ${DIM}[00–11]${NC} : "
    read choice

    case $choice in
        1|01)  generate_ssh_key ;;
        2|02)  list_ssh_keys ;;
        3|03)  view_public_key ;;
        4|04)  delete_ssh_key ;;
        5|05)  copy_public_key ;;
        6|06)  test_github_connection ;;
        7|07)  setup_ssh_config ;;
        8|08)  view_ssh_config ;;
        9|09)  start_ssh_agent ;;
        10)    setup_git_config ;;
        11)    show_help ;;
        0|00)  goodbye ;;
        *)     echo ""; msg_err "Pilihan tidak valid — coba lagi." ;;
    esac
}

goodbye() {
    echo ""
    # Animasi progress "menutup"
    for pct in 100; do progress_bar $pct "menutup sesi..."; done
    printf "\r\033[K"
    echo ""
    typewriter "  🔐 Session aman ditutup. Sampai jumpa! 👋" 0.02
    echo ""
    exit 0
}

# =============================================
#  INIT — satu siklus eksekusi, tanpa loop abadi
# =============================================
trap 'echo ""; echo -e "  ${YELLOW}⚠ Dihentikan oleh user.${NC}"; exit 1' INT TERM

init_ssh_dir
show_menu

# Setelah aksi selesai: tanya sekali, lanjut atau keluar
echo ""
hr
prompt "Kembali ke menu? ${DIM}(Enter = ya / n = keluar)${NC} : "
read -r again
if [ "$again" != "n" ] && [ "$again" != "N" ]; then
    show_menu   # tampilkan menu terakhir kali; pilih 00 untuk keluar
fi
# Siklus berakhir — script selesai alami, tidak ada loop abadi
