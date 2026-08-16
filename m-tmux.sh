#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                        🎨 TMUX SESSION MANAGER v2.0                          ║
# ║                   Advanced Terminal Multiplexer Toolkit                      ║
# ║                Created for Beginners & Power Users Alike                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# 📖 Dokumentasi lengkap: scroll ke bawah atau pilih menu [H] Help
# 💡 Tips: Tmux = Terminal Multiplexer, bisa split terminal, multi-window, dll.
#
# ===============================
# 🎨 WARNA & STYLING
# ===============================
RST='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# Warna dasar
BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'

# Warna terang (bright)
BRED='\033[91m'
BGREEN='\033[92m'
BYELLOW='\033[93m'
BBLUE='\033[94m'
BMAGENTA='\033[95m'
BCYAN='\033[96m'
BWHITE='\033[97m'

# Background warna
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# ===============================
# 🔧 KONFIGURASI GLOBAL
# ===============================
SCRIPT_NAME="Tmux Manager"
SCRIPT_VERSION="2.0"
TMUX_CONFIG_DIR="$HOME/.tmux"
TMUX_CONFIG_FILE="$HOME/.tmux.conf"
TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"
LOG_FILE="$HOME/.tmux/tmux-manager.log"

# ===============================
# 🔐 CEK SUDO
# ===============================
if [ "$EUID" -ne 0 ]; then
    echo -e "${BYELLOW}⚠️  ${RST} Script ini butuh akses ${BOLD}sudo${RST} untuk installasi."
    echo -e "${DIM}   Beberapa fitur memerlukan akses root.${RST}"
    sudo -v 2>/dev/null || {
        echo -e "${BRED}❌${RST} Gagal mendapatkan akses sudo. Melanjutkan tanpa sudo..."
        SUDO_AVAILABLE=false
    }
    SUDO_AVAILABLE=true
else
    SUDO_AVAILABLE=true
fi

# ===============================
# 📝 FUNGSI LOGGING
# ===============================
log_action() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$LOG_FILE" 2>/dev/null
}

# ===============================
# 🖥️  FUNGSI HEADER UTAMA
# ===============================
header() {
    clear
    echo ""
    echo -e "${BCYAN}${BLACK}${BOLD}  ╔══════════════════════════════════════════════════════════════╗  ${RST}"
    echo -e "${BCYAN}${BLACK}${BOLD}  ║                                                              ║  ${RST}"
    echo -e "${BCYAN}${BLACK}${BOLD}  ║${RST}  ${BMAGENTA}🖥️   TMUX SESSION MANAGER v2.0${RST}                               ${BCYAN}${BLACK}${BOLD}║  ${RST}"
    echo -e "${BCYAN}${BLACK}${BOLD}  ║${RST}  ${DIM}Terminal Multiplexer • Multi-Window • Split Pane${RST}            ${BCYAN}${BLACK}${BOLD}║  ${RST}"
    echo -e "${BCYAN}${BLACK}${BOLD}  ║${RST}  ${BYELLOW}Author: Shell Scripting Toolkit${RST}                             ${BCYAN}${BLACK}${BOLD}║  ${RST}"
    echo -e "${BCYAN}${BLACK}${BOLD}  ║                                                              ║  ${RST}"
    echo -e "${BCYAN}${BLACK}${BOLD}  ╚══════════════════════════════════════════════════════════════╝  ${RST}"
    echo ""
}

# ===============================
# 📊 FUNGSI STATUS BAR
# ===============================
status_bar() {
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
    # Cek tmux terinstall
    if command -v tmux >/dev/null 2>&1; then
        local tmux_ver=$(tmux -V 2>/dev/null | cut -d' ' -f2)
        local session_count=$(tmux ls 2>/dev/null | wc -l)
        echo -ne "${BGREEN}${BLACK} ✔ Tmux ${tmux_ver} terinstall ${RST}  "
        echo -ne "${BYELLOW}📋 Sessions: ${BOLD}${session_count}${RST}  "
    else
        echo -ne "${BRED} ✘ Tmux BELUM terinstall ${RST}  "
    fi
    # Cek config file
    if [ -f "$TMUX_CONFIG_FILE" ]; then
        echo -ne "${BGREEN}⚙️  Config: Ada${RST}  "
    else
        echo -ne "${DIM}⚙️  Config: Tidak ada${RST}  "
    fi
    echo ""
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
    echo ""
}

# ===============================
# 📋 FUNGSI TAMPIL SESSION (DETAIL)
# ===============================
tampil_session_detail() {
    echo -e "${BCYAN}┌─────────────────────────────────────────────────────────────────────────────┐${RST}"
    echo -e "${BCYAN}│${RST} ${BOLD}${BWHITE}📋 DAFTAR TMUX SESSION AKTIF${RST}                                                ${BCYAN}│${RST}"
    echo -e "${BCYAN}├─────────────────────────────────────────────────────────────────────────────┤${RST}"

    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BCYAN}│${RST} ${BRED}❌ Tmux belum terinstall! Pilih menu [1] untuk install.${RST}                     ${BCYAN}│${RST}"
    else
        local SESSION_LIST=$(tmux ls 2>/dev/null)
        if [ -z "$SESSION_LIST" ]; then
            echo -e "${BCYAN}│${RST} ${BYELLOW}⚠️  Tidak ada session aktif.${RST}                                              ${BCYAN}│${RST}"
            echo -e "${BCYAN}│${RST} ${DIM}   Gunakan menu [2] untuk membuat session baru.${RST}                         ${BCYAN}│${RST}"
        else
            local count=1
            while IFS= read -r line; do
                local session_name=$(echo "$line" | cut -d':' -f1)
                local session_status=$(echo "$line" | grep -o '(attached)' || echo "(detached)")
                local session_windows=$(tmux list-windows -t "$session_name" 2>/dev/null | wc -l)
                local session_date=$(echo "$line" | grep -oP 'created:.*?\d{4}' | head -1 || echo "N/A")

                if [[ "$session_status" == "(attached)" ]]; then
                    echo -e "${BCYAN}│${RST} ${BGREEN}🟢 ${BOLD}${session_name}${RST} ${GREEN}[ATTACHED]${RST}  ${DIM}🪟  Windows: ${session_windows}${RST}    ${BCYAN}│${RST}"
                else
                    echo -e "${BCYAN}│${RST} ${BYELLOW}🟡 ${BOLD}${session_name}${RST} ${YELLOW}[DETACHED]${RST}  ${DIM}🪟  Windows: ${session_windows}${RST}    ${BCYAN}│${RST}"
                fi
                ((count++))
            done <<< "$SESSION_LIST"
        fi
    fi
    echo -e "${BCYAN}└─────────────────────────────────────────────────────────────────────────────┘${RST}"
    echo ""
}

# ===============================
# 🔍 FUNGSI TAMPIL SESSION (SIMPEL)
# ===============================
tampil_session_simple() {
    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BRED}❌ Tmux belum terinstall.${RST}"
        return
    fi
    local SESSION_LIST=$(tmux ls 2>/dev/null)
    if [ -z "$SESSION_LIST" ]; then
        echo -e "${BYELLOW}⚠️  Tidak ada session aktif.${RST}"
    else
        echo -e "${BCYAN}📋 Session aktif:${RST}"
        echo -e "${DIM}─────────────────────────────────────────────${RST}"
        while IFS= read -r line; do
            echo -e "  ${BWHITE}▸ ${line}${RST}"
        done <<< "$SESSION_LIST"
        echo -e "${DIM}─────────────────────────────────────────────${RST}"
    fi
}

# ===============================
# 🎯 FUNGSI PILIH SESSION
# ===============================
pilih_session() {
    local prompt_msg="${1:-Masukkan nama session}"
    local SESSION_LIST=$(tmux ls 2>/dev/null | cut -d':' -f1)

    if [ -z "$SESSION_LIST" ]; then
        echo -e "${BRED}❌ Tidak ada session tersedia!${RST}"
        return 1
    fi

    echo -e "${BCYAN}┌────[${BYELLOW}Session tersedia${RST}${BCYAN}]${RST}"
    local i=1
    declare -gA SESSION_MAP
    while IFS= read -r s; do
        echo -e "${BCYAN}│${RST} ${BOLD}[${i}]${RST} ${BWHITE}${s}${RST}"
        SESSION_MAP[$i]="$s"
        ((i++))
    done <<< "$SESSION_LIST"
    echo -e "${BCYAN}└─────────────────────────────${RST}"

    read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Pilih nomor/ nama]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️  ${RST})" pilihan

    # Jika input angka, ambil dari map
    if [[ "$pilihan" =~ ^[0-9]+$ ]] && [ -n "${SESSION_MAP[$pilihan]}" ]; then
        echo "${SESSION_MAP[$pilihan]}"
        return 0
    # Jika input string, cek langsung
    elif tmux has-session -t "$pilihan" 2>/dev/null; then
        echo "$pilihan"
        return 0
    else
        echo -e "${BRED}❌ Session '${pilihan}' tidak ditemukan!${RST}"
        return 1
    fi
}

# ===============================
# 📦 [1] INSTALL TMUX
# ===============================
install_tmux() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}📦 INSTALL TMUX${RST}                                 ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    if command -v tmux >/dev/null 2>&1; then
        local current_ver=$(tmux -V 2>/dev/null)
        echo -e "${BGREEN}✅ Tmux sudah terinstall!${RST}"
        echo -e "${DIM}   Versi: ${BWHITE}${current_ver}${RST}"
        echo -e "${DIM}   Lokasi: ${BWHITE}$(which tmux)${RST}"
        echo ""
        echo -e "${BYELLOW}💡 Mau reinstall/upgrade?${RST}"
        read -p "$(echo -e ${BCYAN}[y/N]${RST} ) " reinstall
        if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    echo -e "${BCYAN}📦 Pilih metode installasi:${RST}"
    echo -e "${DIM}─────────────────────────────────────────────${RST}"
    echo -e "  ${BOLD}[1]${RST} ${BGREEN}APT${RST} (Ubuntu/Debian)    - Versi stabil dari repo"
    echo -e "  ${BOLD}[2]${RST} ${BYELLOW}Source${RST} (compile)      - Versi terbaru dari GitHub"
    echo -e "  ${BOLD}[3]${RST} ${BMAGENTA}Homebrew${RST} (Linux)    - Via Linuxbrew"
    echo -e "  ${BOLD}[0]${RST} ${DIM}Kembali${RST}"
    echo -e "${DIM}─────────────────────────────────────────────${RST}"
    read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Pilih metode]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️  ${RST})" metode

    case "$metode" in
        1)
            echo ""
            echo -e "${BYELLOW}📥 Menginstall tmux via APT...${RST}"
            echo -e "${DIM}   sudo apt update && sudo apt install -y tmux${RST}"
            echo ""
            if [ "$SUDO_AVAILABLE" = true ]; then
                sudo apt update -y && sudo apt install -y tmux
            else
                apt update -y && apt install -y tmux 2>/dev/null || {
                    echo -e "${BRED}❌ Gagal install. Coba jalankan dengan sudo.${RST}"
                    return 1
                }
            fi
            ;;
        2)
            echo ""
            echo -e "${BYELLOW}📥 Compile tmux dari source...${RST}"
            echo -e "${DIM}   Membutuhkan: libevent-dev, ncurses-dev, build-essential, bison, pkg-config${RST}"
            echo ""

            # Install dependencies
            if [ "$SUDO_AVAILABLE" = true ]; then
                sudo apt update -y
                sudo apt install -y libevent-dev ncurses-dev build-essential bison pkg-config git automake autoconf
            else
                echo -e "${BRED}❌ Compile dari source butuh sudo.${RST}"
                return 1
            fi

            local BUILD_DIR=$(mktemp -d)
            cd "$BUILD_DIR"
            echo -e "${BYELLOW}📥 Cloning tmux repository...${RST}"
            git clone https://github.com/tmux/tmux.git --depth 1
            cd tmux
            echo -e "${BYELLOW}🔧 Compiling...${RST}"
            sh autogen.sh
            ./configure && make
            sudo make install
            cd /tmp
            rm -rf "$BUILD_DIR"
            ;;
        3)
            echo ""
            echo -e "${BYELLOW}📥 Menginstall tmux via Homebrew...${RST}"
            if ! command -v brew >/dev/null 2>&1; then
                echo -e "${BYELLOW}⚠️  Homebrew belum terinstall. Menginstall Homebrew dulu...${RST}"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install tmux
            ;;
        0)
            return
            ;;
        *)
            echo -e "${BRED}❌ Pilihan tidak valid!${RST}"
            ;;
    esac

    echo ""
    if command -v tmux >/dev/null 2>&1; then
        echo -e "${BGREEN}╔══════════════════════════════════════════════════════════════╗${RST}"
        echo -e "${BGREEN}║${RST}  ${BWHITE}✅ Tmux berhasil diinstall!${RST}                                 ${BGREEN}║${RST}"
        echo -e "${BGREEN}║${RST}  ${BWHITE}Versi: $(tmux -V 2>/dev/null)${RST}                                         ${BGREEN}║${RST}"
        echo -e "${BGREEN}╚══════════════════════════════════════════════════════════════╝${RST}"
        log_action "Tmux berhasil diinstall: $(tmux -V)"
    else
        echo -e "${BRED}❌ Gagal menginstall tmux.${RST}"
        log_action "Gagal install tmux"
    fi
    echo ""
    read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
}

# ===============================
# 🆕 [2] BUAT SESSION BARU
# ===============================
buat_session() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}🆕 BUAT SESSION BARU${RST}                            ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BRED}❌ Tmux belum terinstall! Pilih menu [1] dulu.${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    # Tampilkan session yang sudah ada
    tampil_session_simple

    echo -e "${BCYAN}┌────[${BYELLOW}Konfigurasi Session Baru${RST}${BCYAN}]${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}💡 Tips: Nama session sebaiknya deskriptif${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}   Contoh: 'coding', 'monitoring', 'server-ssh'${RST}"
    echo -e "${BCYAN}│${RST}"

    # Input nama session
    read -p "$(echo -e ${BCYAN}│${RST} ${BOLD}📝 Nama session:${RST} ) " nama_session
    if [ -z "$nama_session" ]; then
        echo -e "${BCYAN}│${RST} ${BRED}❌ Nama tidak boleh kosong!${RST}"
        echo -e "${BCYAN}└─────────────────────────────────────────────${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    # Cek session sudah ada
    if tmux has-session -t "$nama_session" 2>/dev/null; then
        echo -e "${BCYAN}│${RST} ${BYELLOW}⚠️  Session '${nama_session}' sudah ada!${RST}"
        echo -e "${BCYAN}│${RST} ${DIM}   Pilih [Attach] untuk masuk, atau [Buat] untuk nama lain.${RST}"
        echo -e "${BCYAN}└─────────────────────────────────────────────${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    # Path default
    read -p "$(echo -e ${BCYAN}│${RST} ${BOLD}📁 Working directory${RST} ${DIM}[default: \$HOME]${RST}: ) " work_dir
    work_dir="${work_dir:-$HOME}"

    # Window name
    read -p "$(echo -e ${BCYAN}│${RST} ${BOLD}🪟  Nama window pertama${RST} ${DIM}[default: main]${RST}: ) " win_name
    win_name="${win_name:-main}"

    echo -e "${BCYAN}└─────────────────────────────────────────────${RST}"
    echo ""

    echo -e "${BCYAN}🔄 Pilih mode pembuatan session:${RST}"
    echo -e "${DIM}─────────────────────────────────────────────${RST}"
    echo -e "  ${BOLD}[1]${RST} ${BGREEN}Normal${RST}      - Buat session & langsung attach"
    echo -e "  ${BOLD}[2]${RST} ${BYELLOW}Detached${RST}    - Buat session tanpa attach (background)"
    echo -e "  ${BOLD}[3]${RST} ${BMAGENTA}Split Pane${RST}  - Buat session dengan 2 pane (atas/bawah)"
    echo -e "  ${BOLD}[4]${RST} ${BCYAN}4-Pane Grid${RST} - Buat session dengan 4 pane grid"
    echo -e "${DIM}─────────────────────────────────────────────${RST}"
    read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Pilih mode]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️  ${RST})" mode

    case "$mode" in
        2)
            echo ""
            echo -e "${BGREEN}✅ Membuat session detached: ${BOLD}${nama_session}${RST}"
            tmux new-session -d -s "$nama_session" -c "$work_dir" -n "$win_name"
            echo -e "${DIM}   Session berjalan di background.${RST}"
            echo -e "${DIM}   Gunakan menu [3] untuk attach nanti.${RST}"
            log_action "Session detached dibuat: $nama_session ($work_dir)"
            ;;
        3)
            echo ""
            echo -e "${BGREEN}✅ Membuat session split pane: ${BOLD}${nama_session}${RST}"
            tmux new-session -d -s "$nama_session" -c "$work_dir" -n "$win_name"
            tmux split-window -t "$nama_session" -v -c "$work_dir"
            tmux select-layout -t "$nama_session" even-vertical
            echo -e "${DIM}   Layout: 2 pane vertikal (atas & bawah).${RST}"
            echo -e "${DIM}   Gunakan ${BOLD}Ctrl+B, ↑/↓${RST} untuk pindah pane.${RST}"
            log_action "Session split pane dibuat: $nama_session"
            ;;
        4)
            echo ""
            echo -e "${BGREEN}✅ Membuat session 4-pane grid: ${BOLD}${nama_session}${RST}"
            tmux new-session -d -s "$nama_session" -c "$work_dir" -n "$win_name"
            tmux split-window -t "$nama_session" -v -c "$work_dir"
            tmux split-window -t "$nama_session" -h -c "$work_dir"
            tmux select-pane -t "$nama_session" -t 0
            tmux split-window -t "$nama_session" -h -c "$work_dir"
            tmux select-layout -t "$nama_session" tiled
            echo -e "${DIM}   Layout: 4 pane grid (2x2).${RST}"
            echo -e "${DIM}   Gunakan ${BOLD}Ctrl+B, arrow keys${RST} untuk navigasi.${RST}"
            log_action "Session 4-pane grid dibuat: $nama_session"
            ;;
        *)
            echo ""
            echo -e "${BGREEN}✅ Membuat session: ${BOLD}${nama_session}${RST}"
            echo -e "${BYELLOW}💡 Tips:${RST} ${DIM}Tekan${RST} ${BOLD}${BCYAN}Ctrl+B${RST} ${DIM}lalu${RST} ${BOLD}${BCYAN}D${RST} ${DIM}untuk detach.${RST}"
            echo -e "${DIM}   Ctrl+B lalu ?  → Tampilkan semua shortcut${RST}"
            sleep 2
            tmux new-session -s "$nama_session" -c "$work_dir" -n "$win_name"
            log_action "Session dibuat & attached: $nama_session ($work_dir)"
            ;;
    esac

    echo ""
    read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
}

# ===============================
# 👁️  [3] ATTACH KE SESSION
# ===============================
attach_session() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}👁️  ATTACH KE SESSION${RST}                            ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BRED}❌ Tmux belum terinstall!${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    tampil_session_detail

    local SESSION_LIST=$(tmux ls 2>/dev/null | cut -d':' -f1)
    if [ -z "$SESSION_LIST" ]; then
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    echo -e "${BCYAN}┌────[${BYELLOW}Pilih mode attach${RST}${BCYAN}]${RST}"
    echo -e "${BCYAN}│${RST} ${BOLD}[1]${RST} ${BGREEN}Normal Attach${RST}     - tmux attach -t <session>"
    echo -e "${BCYAN}│${RST} ${BOLD}[2]${RST} ${BYELLOW}Force Attach${RST}      - tmux attach -d -t <session> (putus koneksi lain)"
    echo -e "${BCYAN}│${RST} ${BOLD}[3]${RST} ${BMAGENTA}Read-Only Attach${RST}  - tmux attach -r -t <session> (hanya lihat)"
    echo -e "${BCYAN}└─────────────────────────────────────────────${RST}"
    read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Pilih mode]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️  ${RST})" attach_mode

    local chosen
    chosen=$(pilih_session "Pilih session untuk attach")
    [ $? -ne 0 ] && { read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"; return; }

    case "$attach_mode" in
        2)
            echo -e "${BYELLOW}⚡ Force attach ke: ${BOLD}${chosen}${RST}"
            log_action "Force attach: $chosen"
            tmux attach -d -t "$chosen"
            ;;
        3)
            echo -e "${BMAGENTA}👁️  Read-only attach ke: ${BOLD}${chosen}${RST}"
            echo -e "${DIM}   Kamu tidak bisa mengetik di session ini.${RST}"
            log_action "Read-only attach: $chosen"
            tmux attach -r -t "$chosen"
            ;;
        *)
            echo -e "${BGREEN}🔗 Attach ke: ${BOLD}${chosen}${RST}"
            log_action "Attach: $chosen"
            tmux attach -t "$chosen"
            ;;
    esac
}

# ===============================
# 🔍 [4] LIHAT DETAIL SESSION
# ===============================
lihat_detail_session() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}🔍 DETAIL SESSION${RST}                               ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BRED}❌ Tmux belum terinstall!${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    local chosen
    chosen=$(pilih_session "Pilih session untuk dilihat")
    [ $? -ne 0 ] && { read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"; return; }

    echo ""
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST} ${BOLD}📊 DETAIL: ${BWHITE}${chosen}${RST}${BCYAN}║${RST}"
    echo -e "${BCYAN}╠══════════════════════════════════════════════════════════════╣${RST}"

    # Info session
    local session_info=$(tmux list-sessions -F "#{session_name} | #{session_created} | #{session_windows} windows | #{session_width}x#{session_height}" 2>/dev/null | grep "^${chosen}")
    echo -e "${BCYAN}║${RST} ${DIM}Info:${RST} ${BWHITE}${session_info}${RST}"

    # List windows
    echo -e "${BCYAN}╠══════════════════════════════════════════════════════════════╣${RST}"
    echo -e "${BCYAN}║${RST} ${BOLD}🪟  WINDOWS: ${RST}"
    local windows=$(tmux list-windows -t "$chosen" -F "#{window_index}:#{window_name} [#{window_panes} panes] #{?window_active,🟢,*}" 2>/dev/null)
    while IFS= read -r w; do
        echo -e "${BCYAN}║${RST}   ${BWHITE}▸ ${w}${RST}"
    done <<< "$windows"

    # List panes
    echo -e "${BCYAN}╠══════════════════════════════════════════════════════════════╣${RST}"
    echo -e "${BCYAN}║${RST} ${BOLD}📐 PANES:${RST}"
    local panes=$(tmux list-panes -t "$chosen" -F "#{pane_index}: #{pane_width}x#{pane_height} #{?pane_active,🟢,⚫} PID=#{pane_pid}" 2>/dev/null)
    while IFS= read -r p; do
        echo -e "${BCYAN}║${RST}   ${DIM}▸ ${p}${RST}"
    done <<< "$panes"

    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
}

# ===============================
# 💀 [5] KILL SESSION
# ===============================
kill_session() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}💀 KILL SESSION${RST}                                 ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BRED}❌ Tmux belum terinstall!${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    tampil_session_detail

    local SESSION_LIST=$(tmux ls 2>/dev/null | cut -d':' -f1)
    if [ -z "$SESSION_LIST" ]; then
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    echo -e "${BCYAN}┌────[${BYELLOW}Pilih opsi kill${RST}${BCYAN}]${RST}"
    echo -e "${BCYAN}│${RST} ${BOLD}[1]${RST} ${BRED}💀 Kill satu session${RST}       - Pilih session spesifik"
    echo -e "${BCYAN}│${RST} ${BOLD}[2]${RST} ${BRED}☠️  Kill SEMUA session${RST}      - Hapus semua session"
    echo -e "${BCYAN}│${RST} ${BOLD}[3]${RST} ${BYELLOW}🧹 Kill detached saja${RST}      - Hanya session yg tidak terpakai"
    echo -e "${BCYAN}│${RST} ${BOLD}[0]${RST} ${DIM}Kembali${RST}"
    echo -e "${BCYAN}└─────────────────────────────────────────────${RST}"
    read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Pilih]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️  ${RST})" kill_mode

    case "$kill_mode" in
        1)
            local chosen
            chosen=$(pilih_session "Pilih session untuk di-kill")
            [ $? -ne 0 ] && { read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"; return; }
            echo ""
            read -p "$(echo -e ${BRED}⚠️  Yakin kill session '${chosen}'? [y/N]:${RST} ) " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                tmux kill-session -t "$chosen"
                echo -e "${BGREEN}✅ Session '${chosen}' berhasil di-kill.${RST}"
                log_action "Kill session: $chosen"
            else
                echo -e "${DIM}   Dibatalkan.${RST}"
            fi
            ;;
        2)
            echo ""
            read -p "$(echo -e ${BRED}☠️  Yakin kill SEMUA session? [y/N]:${RST} ) " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                local all_sessions=$(tmux ls 2>/dev/null | cut -d':' -f1)
                while IFS= read -r s; do
                    tmux kill-session -t "$s" 2>/dev/null
                    echo -e "${BRED}💀 Killed: ${s}${RST}"
                done <<< "$all_sessions"
                echo -e "${BGREEN}✅ Semua session telah di-kill.${RST}"
                log_action "Kill all sessions"
            else
                echo -e "${DIM}   Dibatalkan.${RST}"
            fi
            ;;
        3)
            echo ""
            local detached=$(tmux ls 2>/dev/null | grep -v '(attached)' | cut -d':' -f1)
            if [ -z "$detached" ]; then
                echo -e "${BYELLOW}⚠️  Tidak ada session detached.${RST}"
            else
                echo -e "${BYELLOW}🧹 Membersihkan session detached...${RST}"
                while IFS= read -r s; do
                    tmux kill-session -t "$s" 2>/dev/null
                    echo -e "${BYELLOW}🧹 Cleaned: ${s}${RST}"
                done <<< "$detached"
                echo -e "${BGREEN}✅ Session detached dibersihkan.${RST}"
                log_action "Clean detached sessions"
            fi
            ;;
        0) return ;;
        *) echo -e "${BRED}❌ Pilihan tidak valid!${RST}" ;;
    esac

    echo ""
    read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
}

# ===============================
# ✏️  [6] RENAME SESSION
# ===============================
rename_session() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}✏️  RENAME SESSION${RST}                               ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BRED}❌ Tmux belum terinstall!${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    tampil_session_simple

    local chosen
    chosen=$(pilih_session "Pilih session untuk di-rename")
    [ $? -ne 0 ] && { read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"; return; }

    read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Nama baru]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️  ${RST})" new_name

    if [ -z "$new_name" ]; then
        echo -e "${BRED}❌ Nama baru tidak boleh kosong!${RST}"
    elif tmux has-session -t "$new_name" 2>/dev/null; then
        echo -e "${BRED}❌ Session '${new_name}' sudah ada!${RST}"
    else
        tmux rename-session -t "$chosen" "$new_name"
        echo -e "${BGREEN}✅ Session '${chosen}' → '${new_name}' berhasil di-rename!${RST}"
        log_action "Rename session: $chosen -> $new_name"
    fi

    echo ""
    read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
}

# ===============================
# 🪟 [7] WINDOW MANAGEMENT
# ===============================
window_management() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}🪟  WINDOW MANAGEMENT${RST}                            ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BRED}❌ Tmux belum terinstall!${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    local chosen
    chosen=$(pilih_session "Pilih session")
    [ $? -ne 0 ] && { read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"; return; }

    while true; do
        header
        echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
        echo -e "${BCYAN}║${RST}          ${BOLD}🪟 WINDOWS: ${BWHITE}${chosen}${RST}                              ${BCYAN}║${RST}"
        echo -e "${BCYAN}╠══════════════════════════════════════════════════════════════╣${RST}"

        # List windows
        local windows=$(tmux list-windows -t "$chosen" -F "#{window_index}:#{window_name} [#{window_panes} panes] #{?window_active,🟢,⚫} #{window_layout}" 2>/dev/null)
        while IFS= read -r w; do
            echo -e "${BCYAN}║${RST} ${BWHITE}${w}${RST}"
        done <<< "$windows"

        echo -e "${BCYAN}╠══════════════════════════════════════════════════════════════╣${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}[1]${RST} ➕ New Window       ${BOLD}[4]${RST} ✏️  Rename Window    ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}[2]${RST} 💀 Kill Window      ${BOLD}[5]${RST} 🔄 Swap Window      ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}[3]${RST} 📋 List Windows     ${BOLD}[6]${RST} 🔗 Link Window      ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}[0]${RST} ↩️  Kembali${RST}                                          ${BCYAN}║${RST}"
        echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
        read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Window Menu]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️  ${RST})" win_menu

        case "$win_menu" in
            1)
                read -p "$(echo -e ${BCYAN}📝 Nama window baru:${RST} ) " new_win
                [ -n "$new_win" ] && tmux new-window -t "$chosen" -n "$new_win" && echo -e "${BGREEN}✅ Window '${new_win}' dibuat.${RST}"
                ;;
            2)
                read -p "$(echo -e ${BRED}💀 Nomor window yang di-kill:${RST} ) " kill_win
                [ -n "$kill_win" ] && tmux kill-window -t "${chosen}:${kill_win}" && echo -e "${BGREEN}✅ Window ${kill_win} di-kill.${RST}"
                ;;
            3)
                echo ""
                tmux list-windows -t "$chosen"
                ;;
            4)
                read -p "$(echo -e ${BCYAN}📝 Nomor window:${RST} ) " rn_win
                read -p "$(echo -e ${BCYAN}📝 Nama baru:${RST} ) " rn_name
                [ -n "$rn_win" ] && [ -n "$rn_name" ] && tmux rename-window -t "${chosen}:${rn_win}" "$rn_name" && echo -e "${BGREEN}✅ Window di-rename.${RST}"
                ;;
            5)
                read -p "$(echo -e ${BCYAN}🔄 Swap source window:${RST} ) " sw_src
                read -p "$(echo -e ${BCYAN}🔄 Swap target window:${RST} ) " sw_dst
                [ -n "$sw_src" ] && [ -n "$sw_dst" ] && tmux swap-window -s "${chosen}:${sw_src}" -t "${chosen}:${sw_dst}" && echo -e "${BGREEN}✅ Window di-swap.${RST}"
                ;;
            6)
                read -p "$(echo -e ${BCYAN}🔗 Source window:${RST} ) " lk_src
                read -p "$(echo -e ${BCYAN}🔗 Target window:${RST} ) " lk_dst
                [ -n "$lk_src" ] && [ -n "$lk_dst" ] && tmux link-window -s "${chosen}:${lk_src}" -t "${chosen}:${lk_dst}" && echo -e "${BGREEN}✅ Window di-link.${RST}"
                ;;
            0) break ;;
            *) echo -e "${BRED}❌ Pilihan tidak valid!${RST}" ;;
        esac
        echo ""
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
    done
}

# ===============================
# 📐 [8] PANE MANAGEMENT
# ===============================
pane_management() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}📐 PANE MANAGEMENT${RST}                              ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BRED}❌ Tmux belum terinstall!${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    local chosen
    chosen=$(pilih_session "Pilih session")
    [ $? -ne 0 ] && { read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"; return; }

    while true; do
        header
        echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
        echo -e "${BCYAN}║${RST}          ${BOLD}📐 PANES: ${BWHITE}${chosen}${RST}                                 ${BCYAN}║${RST}"
        echo -e "${BCYAN}╠══════════════════════════════════════════════════════════════╣${RST}"

        # List panes
        local panes=$(tmux list-panes -t "$chosen" -F "#{pane_index}: #{pane_width}x#{pane_height} #{?pane_active,🟢,⚫} PID=#{pane_pid}" 2>/dev/null)
        while IFS= read -r p; do
            echo -e "${BCYAN}║${RST} ${DIM}${p}${RST}"
        done <<< "$panes"

        echo -e "${BCYAN}╠══════════════════════════════════════════════════════════════╣${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}[1]${RST} ⬇️  Split Vertikal   ${BOLD}[5]${RST} 🔄 Swap Pane        ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}[2]${RST} ➡️  Split Horizontal ${BOLD}[6]${RST} 💀 Kill Pane         ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}[3]${RST} 🖼️  Break Pane       ${BOLD}[7]${RST} 🔀 Rotate Pane       ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}[4]${RST} 🔲 Join Pane         ${BOLD}[8]${RST} 📐 Resize Pane       ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}[0]${RST} ↩️  Kembali${RST}                                          ${BCYAN}║${RST}"
        echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
        read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Pane Menu]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️  ${RST})" pane_menu

        case "$pane_menu" in
            1)
                tmux split-window -t "$chosen" -v
                echo -e "${BGREEN}✅ Pane vertikal dibuat.${RST}"
                ;;
            2)
                tmux split-window -t "$chosen" -h
                echo -e "${BGREEN}✅ Pane horizontal dibuat.${RST}"
                ;;
            3)
                read -p "$(echo -e ${BCYAN}🖼️  Pane index untuk break:${RST} ) " brk_idx
                [ -n "$brk_idx" ] && tmux break-pane -t "${chosen}:.${brk_idx}" && echo -e "${BGREEN}✅ Pane di-break ke window baru.${RST}"
                ;;
            4)
                read -p "$(echo -e ${BCYAN}🔲 Source pane index:${RST} ) " jn_src
                read -p "$(echo -e ${BCYAN}🔲 Target pane index:${RST} ) " jn_dst
                [ -n "$jn_src" ] && [ -n "$jn_dst" ] && tmux join-pane -s "${chosen}:.${jn_src}" -t "${chosen}:.${jn_dst}" && echo -e "${BGREEN}✅ Pane di-join.${RST}"
                ;;
            5)
                read -p "$(echo -e ${BCYAN}🔄 Source pane:${RST} ) " sp_src
                read -p "$(echo -e ${BCYAN}🔄 Target pane:${RST} ) " sp_dst
                [ -n "$sp_src" ] && [ -n "$sp_dst" ] && tmux swap-pane -s "${chosen}:.${sp_src}" -t "${chosen}:.${sp_dst}" && echo -e "${BGREEN}✅ Pane di-swap.${RST}"
                ;;
            6)
                read -p "$(echo -e ${BRED}💀 Pane index untuk kill:${RST} ) " kp_idx
                [ -n "$kp_idx" ] && tmux kill-pane -t "${chosen}:.${kp_idx}" && echo -e "${BGREEN}✅ Pane di-kill.${RST}"
                ;;
            7)
                tmux rotate-window -t "$chosen"
                echo -e "${BGREEN}✅ Pane di-rotate.${RST}"
                ;;
            8)
                read -p "$(echo -e ${BCYAN}📐 Pane index:${RST} ) " rz_idx
                read -p "$(echo -e ${BCYAN}📐 Arah (U/D/L/R):${RST} ) " rz_dir
                read -p "$(echo -e ${BCYAN}📐 Jumlah cell:${RST} ) " rz_amt
                [ -n "$rz_idx" ] && [ -n "$rz_dir" ] && [ -n "$rz_amt" ] && tmux resize-pane -t "${chosen}:.${rz_idx}" -"${rz_dir}" "${rz_amt}" && echo -e "${BGREEN}✅ Pane di-resize.${RST}"
                ;;
            0) break ;;
            *) echo -e "${BRED}❌ Pilihan tidak valid!${RST}" ;;
        esac
        echo ""
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
    done
}

# ===============================
# ⚙️  [9] KONFIGURASI TMUX
# ===============================
konfigurasi_tmux() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}⚙️  KONFIGURASI TMUX${RST}                             ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    while true; do
        echo -e "${BCYAN}┌────[${BYELLOW}Pilih Aksi${RST}${BCYAN}]${RST}"
        echo -e "${BCYAN}│${RST} ${BOLD}[1]${RST} 📝 Buat file konfigurasi baru (~/.tmux.conf)"
        echo -e "${BCYAN}│${RST} ${BOLD}[2]${RST} 👁️  Lihat konfigurasi saat ini"
        echo -e "${BCYAN}│${RST} ${BOLD}[3]${RST} 📋 Terapkan template konfigurasi keren"
        echo -e "${BCYAN}│${RST} ${BOLD}[4]${RST} 💾 Backup konfigurasi"
        echo -e "${BCYAN}│${RST} ${BOLD}[5]${RST} 🔄 Reload konfigurasi (source ~/.tmux.conf)"
        echo -e "${BCYAN}│${RST} ${BOLD}[6]${RST} 📦 Install TPM (Tmux Plugin Manager)"
        echo -e "${BCYAN}│${RST} ${BOLD}[7]${RST} 🗑️  Hapus konfigurasi"
        echo -e "${BCYAN}│${RST} ${BOLD}[0]${RST} ↩️  Kembali"
        echo -e "${BCYAN}└─────────────────────────────────────────────${RST}"
        read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Pilih]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️  ${RST})" config_menu

        case "$config_menu" in
            1)
                if [ -f "$TMUX_CONFIG_FILE" ]; then
                    echo -e "${BYELLOW}⚠️  File ~/.tmux.conf sudah ada.${RST}"
                    read -p "$(echo -e ${BCYAN}Timpa? [y/N]:${RST} ) " timpa
                    [[ ! "$timpa" =~ ^[Yy]$ ]] && continue
                fi
                cat > "$TMUX_CONFIG_FILE" << 'TMUXEOF'
# ===========================================
# 🎨 TMUX CONFIGURATION
# ===========================================

# --- Prefix Key ---
# Ubah prefix dari Ctrl+B ke Ctrl+A (lebih mudah dijangkau)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# --- Mouse Support ---
set -g mouse on

# --- Split Panes ---
# | untuk vertical split, - untuk horizontal split
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# --- Reload Config ---
bind r source-file ~/.tmux.conf \; display "🔄 Config reloaded!"

# --- Pane Navigation (vim-style) ---
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# --- Resize Pane ---
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# --- Window Management ---
bind c new-window -c "#{pane_current_path}"
set -g base-index 1
setw -g pane-base-index 1

# --- Visual ---
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"
set -g status-position top
set -g status-style 'bg=#1a1b26,fg=#a9b1d6'
set -g status-left '#[fg=#7aa2f7,bold] #S #[fg=#565f89]│ '
set -g status-right '#[fg=#565f89]│ %Y-%m-%d #[fg=#7aa2f7]%H:%M '
set -g window-status-current-style 'fg=#7aa2f7,bg=#24283b,bold'
set -g window-status-style 'fg=#565f89'

# --- History ---
set -g history-limit 50000

# --- Faster Escape ---
set -sg escape-time 0

# --- Automatically renumber windows ---
set -g renumber-windows on

# --- Focus events ---
set -g focus-events on
TMUXEOF
                echo -e "${BGREEN}✅ Konfigurasi dibuat di ~/.tmux.conf${RST}"
                echo -e "${BYELLOW}💡 Jalankan 'tmux source ~/.tmux.conf' atau prefix + r untuk reload.${RST}"
                log_action "Membuat tmux.conf baru"
                ;;
            2)
                echo ""
                if [ -f "$TMUX_CONFIG_FILE" ]; then
                    echo -e "${BCYAN}📄 ~/.tmux.conf:${RST}"
                    echo -e "${DIM}─────────────────────────────────────────────${RST}"
                    cat -n "$TMUX_CONFIG_FILE"
                    echo -e "${DIM}─────────────────────────────────────────────${RST}"
                else
                    echo -e "${BYELLOW}⚠️  Belum ada file ~/.tmux.conf${RST}"
                fi
                echo ""
                ;;
            3)
                echo ""
                echo -e "${BCYAN}📋 Pilih template:${RST}"
                echo -e "  ${BOLD}[1]${RST} 🎨 Tokyo Night (gelap, ungu/biru)"
                echo -e "  ${BOLD}[2]${RST} 🌿 Gruvbox (retro, hangat)"
                echo -e "  ${BOLD}[3]${RST} ⚡ Minimal (sederhana, cepat)"
                read -p "$(echo -e ${BCYAN}Pilih:${RST} ) " tpl

                case "$tpl" in
                    1) theme_bg='#1a1b26'; theme_fg='#a9b1d6'; theme_accent='#7aa2f7';;
                    2) theme_bg='#282828'; theme_fg='#ebdbb2'; theme_accent='#fabd2f';;
                    3) theme_bg='#000000'; theme_fg='#ffffff'; theme_accent='#00ff00';;
                    *) echo -e "${BRED}❌ Tidak valid.${RST}"; continue ;;
                esac

                cat > "$TMUX_CONFIG_FILE" << EOF
# ╔══════════════════════════════════════════════╗
# ║         🎨 TMUX CONFIG TEMPLATE             ║
# ╚══════════════════════════════════════════════╝

unbind C-b
set -g prefix C-a
bind C-a send-prefix
set -g mouse on
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %
bind r source-file ~/.tmux.conf \; display "🔄 Config reloaded!"
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
bind c new-window -c "#{pane_current_path}"
set -g base-index 1
setw -g pane-base-index 1
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"
set -g status-position top
set -g status-style 'bg=${theme_bg},fg=${theme_fg}'
set -g status-left '#[fg=${theme_accent},bold] #S #[fg=#565f89]│ '
set -g status-right '#[fg=#565f89]│ %Y-%m-%d #[fg=${theme_accent}]%H:%M '
set -g window-status-current-style 'fg=${theme_accent},bg=#24283b,bold'
set -g window-status-style 'fg=#565f89'
set -g history-limit 50000
set -sg escape-time 0
set -g renumber-windows on
set -g focus-events on
EOF
                echo -e "${BGREEN}✅ Template diterapkan!${RST}"
                log_action "Template tmux.conf diterapkan"
                ;;
            4)
                if [ -f "$TMUX_CONFIG_FILE" ]; then
                    local backup_file="$TMUX_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
                    cp "$TMUX_CONFIG_FILE" "$backup_file"
                    echo -e "${BGREEN}✅ Backup disimpan: ${backup_file}${RST}"
                    log_action "Backup tmux.conf: $backup_file"
                else
                    echo -e "${BYELLOW}⚠️  Tidak ada file untuk di-backup.${RST}"
                fi
                ;;
            5)
                if [ -f "$TMUX_CONFIG_FILE" ]; then
                    tmux source-file "$TMUX_CONFIG_FILE" 2>/dev/null
                    echo -e "${BGREEN}✅ Konfigurasi di-reload!${RST}"
                    log_action "Reload tmux.conf"
                else
                    echo -e "${BRED}❌ Tidak ada ~/.tmux.conf${RST}"
                fi
                ;;
            6)
                echo ""
                echo -e "${BYELLOW}📦 Menginstall TPM (Tmux Plugin Manager)...${RST}"
                if [ -d "$TMUX_PLUGIN_DIR/tpm" ]; then
                    echo -e "${BYELLOW}⚠️  TPM sudah terinstall.${RST}"
                else
                    mkdir -p "$TMUX_PLUGIN_DIR"
                    git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_DIR/tpm"
                    echo -e "${BGREEN}✅ TPM terinstall!${RST}"
                    echo -e "${DIM}   Tambahkan ini ke ~/.tmux.conf:${RST}"
                    echo -e "${DIM}   set -g @plugin 'tmux-plugins/tpm'${RST}"
                    echo -e "${DIM}   run '~/.tmux/plugins/tpm/tpm'${RST}"
                    log_action "TPM diinstall"
                fi
                ;;
            7)
                if [ -f "$TMUX_CONFIG_FILE" ]; then
                    read -p "$(echo -e ${BRED}🗑️  Yakin hapus ~/.tmux.conf? [y/N]:${RST} ) " del_confirm
                    if [[ "$del_confirm" =~ ^[Yy]$ ]]; then
                        rm "$TMUX_CONFIG_FILE"
                        echo -e "${BGREEN}✅ Konfigurasi dihapus.${RST}"
                        log_action "Hapus tmux.conf"
                    fi
                else
                    echo -e "${BYELLOW}⚠️  Tidak ada file untuk dihapus.${RST}"
                fi
                ;;
            0) break ;;
            *) echo -e "${BRED}❌ Pilihan tidak valid!${RST}" ;;
        esac
        echo ""
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
    done
}

# ===============================
# 📖 [H] HELP & DOKUMENTASI
# ===============================
help_dokumentasi() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}📖 HELP & DOKUMENTASI${RST}                           ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    while true; do
        echo -e "${BCYAN}┌────[${BYELLOW}📚 Pilih Topik${RST}${BCYAN}]${RST}"
        echo -e "${BCYAN}│${RST} ${BOLD}[1]${RST} 🎓 Apa itu Tmux? (Pengenalan untuk Pemula)"
        echo -e "${BCYAN}│${RST} ${BOLD}[2]${RST} ⌨️  Cheatsheet Keyboard Shortcuts"
        echo -e "${BCYAN}│${RST} ${BOLD}[3]${RST} 🪟 Konsep Session, Window, Pane"
        echo -e "${BCYAN}│${RST} ${BOLD}[4]${RST} 📋 Perintah Dasar (CLI Commands)"
        echo -e "${BCYAN}│${RST} ${BOLD}[5]${RST} 🎨 Customisasi & Plugin"
        echo -e "${BCYAN}│${RST} ${BOLD}[6]${RST} 💡 Tips & Trik"
        echo -e "${BCYAN}│${RST} ${BOLD}[7]${RST} 🐛 Troubleshooting"
        echo -e "${BCYAN}│${RST} ${BOLD}[0]${RST} ↩️  Kembali"
        echo -e "${BCYAN}└─────────────────────────────────────────────${RST}"
        read -p "$(echo -e ${BCYAN}┌──${RST}${BYELLOW}[Pilih]${RST})"$'\n'"$(echo -e ${BCYAN}└──▶️   ${RST})" help_menu

        case "$help_menu" in
            1)
                clear
                echo ""
                echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
                echo -e "${BCYAN}║${RST}           ${BOLD}🎓 APA ITU TMUX?${RST}                                   ${BCYAN}║${RST}"
                echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
                echo ""
                echo -e "${BWHITE}${BOLD}Tmux = Terminal Multiplexer${RST}"
                echo ""
                echo -e "${GREEN}🔹 Bayangkan kamu bisa:${RST}"
                echo -e "  ${DIM}▸${RST} Split terminal jadi beberapa bagian (pane)"
                echo -e "  ${DIM}▸${RST} Buka banyak tab/window dalam 1 terminal"
                echo -e "  ${DIM}▸${RST} Jalanin program, lalu detach (tinggalin) & attach lagi nanti"
                echo -e "  ${DIM}▸${RST} SSH ke server, jalanin proses, close laptop, buka lagi"
                echo -e "  ${DIM}▸${RST} Proses tetap jalan meskipun koneksi SSH putus!"
                echo ""
                echo -e "${YELLOW}🔹 Kenapa lebih baik dari Screen?${RST}"
                echo -e "  ${DIM}▸${RST} Client-server architecture (lebih stabil)"
                echo -e "  ${DIM}▸${RST} Status bar lebih informatif"
                echo -e "  ${DIM}▸${RST} Scripting & automation lebih mudah"
                echo -e "  ${DIM}▸${RST} Lebih banyak plugin & tema"
                echo -e "  ${DIM}▸${RST} Layout preset (tiled, even-horizontal, dll)"
                echo ""
                echo -e "${MAGENTA}🔹 Use Case Umum:${RST}"
                echo -e "  ${DIM}▸${RST} ${BOLD}Remote Server${RST}: SSH, jalanin tmux, proses tetap hidup"
                echo -e "  ${DIM}▸${RST} ${BOLD}Development${RST}: 1 pane editor, 1 pane terminal, 1 pane log"
                echo -e "  ${DIM}▸${RST} ${BOLD}Monitoring${RST}: Pantau banyak server/service sekaligus"
                echo -e "  ${DIM}▸${RST} ${BOLD}Pair Programming${RST}: Beberapa user attach ke session sama"
                echo ""
                echo -e "${CYAN}🔹 Analogi:${RST}"
                echo -e "  ${DIM}Session = Project${RST}"
                echo -e "  ${DIM}Window  = Tab${RST}"
                echo -e "  ${DIM}Pane    = Split${RST}"
                echo ""
                ;;
            2)
                clear
                echo ""
                echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
                echo -e "${BCYAN}║${RST}           ${BOLD}⌨️  CHEATSHEET KEYBOARD SHORTCUTS${RST}                   ${BCYAN}║${RST}"
                echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
                echo ""
                echo -e "${BYELLOW}${BOLD}📌 PREFIX KEY: Ctrl+B (default)${RST}"
                echo -e "${DIM}   Tekan Ctrl+B, lepas, lalu tekan tombol berikutnya.${RST}"
                echo ""

                echo -e "${BOLD}${BGREEN}🪟 SESSION${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}Prefix + d${RST}      Detach dari session"
                echo -e "  ${BOLD}Prefix + (${RST}      Pindah ke session sebelumnya"
                echo -e "  ${BOLD}Prefix + )${RST}      Pindah ke session berikutnya"
                echo -e "  ${BOLD}Prefix + s${RST}      Pilih session dari list"
                echo -e "  ${BOLD}Prefix + \$${RST}     Rename session"
                echo ""

                echo -e "${BOLD}${BCYAN}🪟 WINDOW${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}Prefix + c${RST}      Buat window baru"
                echo -e "  ${BOLD}Prefix + ,${RST}      Rename window"
                echo -e "  ${BOLD}Prefix + &${RST}      Kill window (konfirmasi)"
                echo -e "  ${BOLD}Prefix + 0-9${RST}    Pindah ke window 0-9"
                echo -e "  ${BOLD}Prefix + n${RST}      Next window"
                echo -e "  ${BOLD}Prefix + p${RST}      Previous window"
                echo -e "  ${BOLD}Prefix + f${RST}      Cari window berdasarkan nama"
                echo -e "  ${BOLD}Prefix + w${RST}      Pilih window dari list"
                echo ""

                echo -e "${BOLD}${BMAGENTA}📐 PANE${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}Prefix + \"${RST}      Split horizontal (atas/bawah)"
                echo -e "  ${BOLD}Prefix + %${RST}      Split vertical (kiri/kanan)"
                echo -e "  ${BOLD}Prefix + x${RST}      Kill pane (konfirmasi)"
                echo -e "  ${BOLD}Prefix + z${RST}      Zoom pane (fullscreen toggle)"
                echo -e "  ${BOLD}Prefix + !${RST}      Convert pane ke window baru"
                echo -e "  ${BOLD}Prefix + o${RST}      Pindah ke pane berikutnya"
                echo -e "  ${BOLD}Prefix + ;${RST}      Pindah ke pane sebelumnya"
                echo -e "  ${BOLD}Prefix + ↑↓←→${RST}   Navigasi antar pane"
                echo -e "  ${BOLD}Prefix + Ctrl+↑↓${RST} Resize pane (tahan Ctrl)"
                echo -e "  ${BOLD}Prefix + {${RST}      Swap pane ke kiri"
                echo -e "  ${BOLD}Prefix + }${RST}      Swap pane ke kanan"
                echo -e "  ${BOLD}Prefix + Space${RST}   Cycle layout preset"
                echo ""

                echo -e "${BOLD}${BYELLOW}📋 LAIN-LAIN${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}Prefix + ?${RST}      Tampilkan semua shortcut"
                echo -e "  ${BOLD}Prefix + :${RST}      Command mode (ketik perintah)"
                echo -e "  ${BOLD}Prefix + [${RST}      Scroll mode (PgUp/PgDn, q keluar)"
                echo -e "  ${BOLD}Prefix + ]${RST}      Paste dari buffer"
                echo -e "  ${BOLD}Prefix + t${RST}      Tampilkan jam besar"
                echo ""
                ;;
            3)
                clear
                echo ""
                echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
                echo -e "${BCYAN}║${RST}        ${BOLD}🪟  KONSEP: SESSION, WINDOW, PANE${RST}                      ${BCYAN}║${RST}"
                echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
                echo ""
                echo -e "${BOLD}${BGREEN}📦 SESSION${RST} ${DIM}(Level Tertinggi)${RST}"
                echo -e "  ${DIM}▸${RST} Grup windows yang berjalan di server tmux"
                echo -e "  ${DIM}▸${RST} Bisa attach/detach tanpa menghentikan proses"
                echo -e "  ${DIM}▸${RST} Contoh: session 'coding', session 'monitoring'"
                echo -e "  ${DIM}▸${RST} ${BOLD}tmux new -s nama${RST} → buat session"
                echo -e "  ${DIM}▸${RST} ${BOLD}tmux attach -t nama${RST} → masuk session"
                echo ""
                echo -e "${BOLD}${BCYAN}🪟 WINDOW${RST} ${DIM}(Level Menengah)${RST}"
                echo -e "  ${DIM}▸${RST} Seperti 'tab' di browser"
                echo -e "  ${DIM}▸${RST} Setiap session bisa punya banyak window"
                echo -e "  ${DIM}▸${RST} Window berisi 1 atau lebih pane"
                echo -e "  ${DIM}▸${RST} ${BOLD}Ctrl+B, c${RST} → buat window baru"
                echo -e "  ${DIM}▸${RST} ${BOLD}Ctrl+B, 0-9${RST} → pindah window"
                echo ""
                echo -e "${BOLD}${BMAGENTA}📐 PANE${RST} ${DIM}(Level Terendah)${RST}"
                echo -e "  ${DIM}▸${RST} Split dari window"
                echo -e "  ${DIM}▸${RST} Bisa horizontal (atas/bawah) atau vertikal (kiri/kanan)"
                echo -e "  ${DIM}▸${RST} ${BOLD}Ctrl+B, \"${RST} → split horizontal"
                echo -e "  ${DIM}▸${RST} ${BOLD}Ctrl+B, %${RST} → split vertical"
                echo ""

                echo -e "${DIM}┌──────────────────────────────────────────────┐${RST}"
                echo -e "${DIM}│${RST}  ${BOLD}SERVER TMUX${RST}                                 ${DIM}│${RST}"
                echo -e "${DIM}│${RST}  ├─ 📦 Session: coding                       ${DIM}│${RST}"
                echo -e "${DIM}│${RST}  │  ├─ 🪟 Window 1: editor                    ${DIM}│${RST}"
                echo -e "${DIM}│${RST}  │  │  ├─ 📐 Pane 0: vim                     ${DIM}│${RST}"
                echo -e "${DIM}│${RST}  │  │  └─ 📐 Pane 1: terminal                ${DIM}│${RST}"
                echo -e "${DIM}│${RST}  │  └─ 🪟 Window 2: logs                      ${DIM}│${RST}"
                echo -e "${DIM}│${RST}  │     └─ 📐 Pane 0: tail -f app.log         ${DIM}│${RST}"
                echo -e "${DIM}│${RST}  └─ 📦 Session: monitoring                   ${DIM}│${RST}"
                echo -e "${DIM}│${RST}     └─ 🪟 Window 1: htop                      ${DIM}│${RST}"
                echo -e "${DIM}└──────────────────────────────────────────────┘${RST}"
                echo ""
                ;;
            4)
                clear
                echo ""
                echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
                echo -e "${BCYAN}║${RST}           ${BOLD}📋 PERINTAH DASAR CLI${RST}                              ${BCYAN}║${RST}"
                echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
                echo ""
                echo -e "${BOLD}${BGREEN}📋 MANAJEMEN SESSION${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}tmux${RST}                        Buat session baru (tanpa nama)"
                echo -e "  ${BOLD}tmux new -s nama${RST}           Buat session dengan nama"
                echo -e "  ${BOLD}tmux new -s nama -d${RST}        Buat session detached"
                echo -e "  ${BOLD}tmux ls${RST}                     List semua session"
                echo -e "  ${BOLD}tmux attach -t nama${RST}        Attach ke session"
                echo -e "  ${BOLD}tmux attach -d -t nama${RST}    Attach & detach yang lain"
                echo -e "  ${BOLD}tmux kill-session -t nama${RST}  Kill session"
                echo -e "  ${BOLD}tmux rename-session -t old new${RST} Rename session"
                echo ""
                echo -e "${BOLD}${BCYAN}📋 MANAJEMEN WINDOW${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}tmux new-window -t sesi -n nama${RST}  Buat window"
                echo -e "  ${BOLD}tmux list-windows -t sesi${RST}         List windows"
                echo -e "  ${BOLD}tmux select-window -t sesi:0${RST}      Pilih window"
                echo -e "  ${BOLD}tmux kill-window -t sesi:0${RST}        Kill window"
                echo -e "  ${BOLD}tmux rename-window -t sesi:0 nama${RST} Rename window"
                echo ""
                echo -e "${BOLD}${BMAGENTA}📋 MANAJEMEN PANE${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}tmux split-window -h${RST}          Split horizontal"
                echo -e "  ${BOLD}tmux split-window -v${RST}          Split vertical"
                echo -e "  ${BOLD}tmux kill-pane -t sesi:0.0${RST}     Kill pane"
                echo -e "  ${BOLD}tmux swap-pane -s 0.0 -t 0.1${RST}   Swap pane"
                echo -e "  ${BOLD}tmux resize-pane -D 10${RST}         Resize pane ke bawah"
                echo ""
                echo -e "${BOLD}${BYELLOW}📋 INFO & LAINNYA${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}tmux info${RST}                    Info server tmux"
                echo -e "  ${BOLD}tmux source ~/.tmux.conf${RST}    Reload config"
                echo -e "  ${BOLD}tmux show -g${RST}                 Tampilkan semua opsi"
                echo -e "  ${BOLD}tmux clock${RST}                   Tampilkan jam"
                echo ""
                ;;
            5)
                clear
                echo ""
                echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
                echo -e "${BCYAN}║${RST}           ${BOLD}🎨 CUSTOMISASI & PLUGIN${RST}                            ${BCYAN}║${RST}"
                echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
                echo ""
                echo -e "${BOLD}${BGREEN}🎨 FILE KONFIGURASI${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${DIM}▸${RST} File: ${BOLD}~/.tmux.conf${RST}"
                echo -e "  ${DIM}▸${RST} Reload: ${BOLD}tmux source ~/.tmux.conf${RST}"
                echo -e "  ${DIM}▸${RST} Atau: ${BOLD}Prefix + :${RST} lalu ketik ${BOLD}source ~/.tmux.conf${RST}"
                echo ""
                echo -e "${BOLD}${BYELLOW}🎨 SETTING POPULER${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${DIM}▸${RST} ${BOLD}set -g mouse on${RST}              Enable mouse"
                echo -e "  ${DIM}▸${RST} ${BOLD}set -g prefix C-a${RST}            Ganti prefix ke Ctrl+A"
                echo -e "  ${DIM}▸${RST} ${BOLD}set -g base-index 1${RST}          Window mulai dari 1"
                echo -e "  ${DIM}▸${RST} ${BOLD}set -g history-limit 10000${RST}  Scrollback buffer"
                echo -e "  ${DIM}▸${RST} ${BOLD}set -g status-position top${RST}  Status bar di atas"
                echo ""
                echo -e "${BOLD}${BMAGENTA}🔌 PLUGIN POPULER${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${DIM}▸${RST} ${BOLD}tmux-plugins/tpm${RST}          Plugin Manager"
                echo -e "  ${DIM}▸${RST} ${BOLD}tmux-plugins/tmux-sensible${RST} Setting default yang baik"
                echo -e "  ${DIM}▸${RST} ${BOLD}tmux-plugins/tmux-resurrect${RST} Save/restore session"
                echo -e "  ${DIM}▸${RST} ${BOLD}tmux-plugins/tmux-continuum${RST} Auto-save & auto-restore"
                echo -e "  ${DIM}▸${RST} ${BOLD}catppuccin/tmux${RST}            Theme Catppuccin"
                echo -e "  ${DIM}▸${RST} ${BOLD}dracula/tmux${RST}               Theme Dracula"
                echo -e "  ${DIM}▸${RST} ${BOLD}tmux-plugins/tmux-yank${RST}     Copy ke system clipboard"
                echo ""
                echo -e "${BOLD}${BCYAN}📦 CARA INSTALL PLUGIN dengan TPM${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${DIM}1.${RST} git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
                echo -e "  ${DIM}2.${RST} Tambahkan ke ~/.tmux.conf:"
                echo -e "     ${DIM}set -g @plugin 'tmux-plugins/tpm'${RST}"
                echo -e "     ${DIM}set -g @plugin 'tmux-plugins/tmux-sensible'${RST}"
                echo -e "     ${DIM}run '~/.tmux/plugins/tpm/tpm'${RST}"
                echo -e "  ${DIM}3.${RST} Reload tmux: ${BOLD}Prefix + I${RST} (huruf i besar)"
                echo ""
                ;;
            6)
                clear
                echo ""
                echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
                echo -e "${BCYAN}║${RST}           ${BOLD}💡 TIPS & TRIK${RST}                                     ${BCYAN}║${RST}"
                echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
                echo ""
                echo -e "${BOLD}${BGREEN}🚀 PRODUCTIVITY${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}1.${RST} ${BWHITE}Auto-start tmux di SSH:${RST}"
                echo -e "     Tambahkan ke ~/.bashrc:"
                echo -e "     ${DIM}if [ -z \"\$TMUX\" ]; then tmux attach || tmux new; fi${RST}"
                echo ""
                echo -e "  ${BOLD}2.${RST} ${BWHITE}Script untuk setup layout:${RST}"
                echo -e "     ${DIM}#!/bin/bash${RST}"
                echo -e "     ${DIM}tmux new-session -d -s dev${RST}"
                echo -e "     ${DIM}tmux split-window -h -t dev${RST}"
                echo -e "     ${DIM}tmux send-keys -t dev:0.0 'vim' Enter${RST}"
                echo -e "     ${DIM}tmux send-keys -t dev:0.1 'ls' Enter${RST}"
                echo -e "     ${DIM}tmux attach -t dev${RST}"
                echo ""
                echo -e "  ${BOLD}3.${RST} ${BWHITE}Nested tmux:${RST}"
                echo -e "     ${DIM}Prefix + Ctrl+B${RST} untuk kirim prefix ke tmux dalam"
                echo ""
                echo -e "${BOLD}${BYELLOW}🔧 POWER USER${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${BOLD}▸${RST} ${BOLD}tmux pipe-pane${RST} - Log output pane ke file"
                echo -e "  ${BOLD}▸${RST} ${BOLD}tmux send-keys${RST} - Kirim input ke pane dari script"
                echo -e "  ${BOLD}▸${RST} ${BOLD}tmux capture-pane${RST} - Ambil screenshot pane"
                echo -e "  ${BOLD}▸${RST} ${BOLD}tmux choose-tree${RST} - Pilih session/window interaktif"
                echo -e "  ${BOLD}▸${RST} ${BOLD}tmux command-prompt${RST} - Prompt untuk command kompleks"
                echo ""
                echo -e "${BOLD}${BMAGENTA}💡 PRO TIPS${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo -e "  ${DIM}▸${RST} Gunakan ${BOLD}Prefix + z${RST} untuk zoom pane sementara"
                echo -e "  ${DIM}▸${RST} Gunakan ${BOLD}Prefix + :neww${RST} untuk buat window dari command"
                echo -e "  ${DIM}▸${RST} ${BOLD}Prefix + :setw synchronize-panes${RST} → ketik di semua pane"
                echo -e "  ${DIM}▸${RST} ${BOLD}Prefix + [${RST} lalu ${BOLD}/kata${RST} → search di scrollback"
                echo -e "  ${DIM}▸${RST} ${BOLD}Prefix + :resize-pane -Z${RST} → toggle zoom"
                echo ""
                ;;
            7)
                clear
                echo ""
                echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
                echo -e "${BCYAN}║${RST}           ${BOLD}🐛 TROUBLESHOOTING${RST}                                 ${BCYAN}║${RST}"
                echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
                echo ""
                echo -e "${BOLD}${BRED}❌ MASALAH UMUM${RST}"
                echo -e "${DIM}─────────────────────────────────────────────${RST}"
                echo ""
                echo -e "  ${BOLD}🔴 'no sessions' / 'no server running'${RST}"
                echo -e "  ${DIM}→${RST} Server tmux belum jalan. Cukup buat session baru:"
                echo -e "  ${DIM}→${RST} ${BOLD}tmux new -s nama${RST}"
                echo ""
                echo -e "  ${BOLD}🔴 'session not found'${RST}"
                echo -e "  ${DIM}→${RST} Cek nama session: ${BOLD}tmux ls${RST}"
                echo -e "  ${DIM}→${RST} Nama case-sensitive. 'Dev' ≠ 'dev'"
                echo ""
                echo -e "  ${BOLD}🔴 'lost server'${RST}"
                echo -e "  ${DIM}→${RST} Server tmux crash atau di-kill."
                echo -e "  ${DIM}→${RST} Cek: ${BOLD}tmux info${RST} atau ${BOLD}ps aux | grep tmux${RST}"
                echo -e "  ${DIM}→${RST} Restart: buat session baru"
                echo ""
                echo -e "  ${BOLD}🔴 Mouse tidak berfungsi${RST}"
                echo -e "  ${DIM}→${RST} Cek & tambahkan: ${BOLD}set -g mouse on${RST} di ~/.tmux.conf"
                echo -e "  ${DIM}→${RST} Reload: ${BOLD}tmux source ~/.tmux.conf${RST}"
                echo ""
                echo -e "  ${BOLD}🔴 Warna tidak muncul / 256 color${RST}"
                echo -e "  ${DIM}→${RST} Cek terminal: ${BOLD}echo \$TERM${RST} (harus 256color)"
                echo -e "  ${DIM}→${RST} Tambahkan: ${BOLD}set -g default-terminal \"screen-256color\"${RST}"
                echo -e "  ${DIM}→${RST} Tambahkan: ${BOLD}set -ga terminal-overrides \",*256col*:Tc\"${RST}"
                echo ""
                echo -e "  ${BOLD}🔴 Session tidak bisa di-attach${RST}"
                echo -e "  ${DIM}→${RST} Coba force attach: ${BOLD}tmux attach -d -t nama${RST}"
                echo -e "  ${DIM}→${RST} Atau kill dulu: ${BOLD}tmux kill-session -t nama${RST}"
                echo ""
                echo -e "  ${BOLD}🔴 Clipboard tidak sync${RST}"
                echo -e "  ${DIM}→${RST} Install xclip/xsel: ${BOLD}sudo apt install xclip${RST}"
                echo -e "  ${DIM}→${RST} Gunakan plugin tmux-yank"
                echo ""
                ;;
            0) break ;;
            *) echo -e "${BRED}❌ Pilihan tidak valid!${RST}" ;;
        esac
        echo ""
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
    done
}

# ===============================
# 🖥️  [A] SHOW SERVER INFO
# ===============================
server_info() {
    header
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BCYAN}║${RST}              ${BOLD}🖥️  TMUX SERVER INFO${RST}                             ${BCYAN}║${RST}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""

    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${BRED}❌ Tmux belum terinstall!${RST}"
        read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
        return
    fi

    echo -e "${BCYAN}┌─────────────────────────────────────────────────────────────┐${RST}"
    echo -e "${BCYAN}│${RST} ${BOLD}${BWHITE}📊 SERVER INFORMATION${RST}                                       ${BCYAN}│${RST}"
    echo -e "${BCYAN}├─────────────────────────────────────────────────────────────┤${RST}"

    local tmux_ver=$(tmux -V 2>/dev/null)
    local tmux_path=$(which tmux)
    local server_pid=$(tmux start-server \; display -p "#{pid}" 2>/dev/null)
    local socket_path=$(tmux display -p "#{socket_path}" 2>/dev/null)
    local session_count=$(tmux ls 2>/dev/null | wc -l)
    local total_windows=$(tmux list-windows -a 2>/dev/null | wc -l)
    local total_panes=$(tmux list-panes -a 2>/dev/null | wc -l)

    echo -e "${BCYAN}│${RST} ${DIM}Versi:${RST}        ${BWHITE}${tmux_ver}${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}Path:${RST}         ${BWHITE}${tmux_path}${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}Server PID:${RST}   ${BWHITE}${server_pid:-N/A}${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}Socket:${RST}       ${BWHITE}${socket_path:-N/A}${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}Session:${RST}      ${BWHITE}${session_count}${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}Total Windows:${RST} ${BWHITE}${total_windows}${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}Total Panes:${RST}   ${BWHITE}${total_panes}${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}Config File:${RST}  ${BWHITE}$([ -f "$TMUX_CONFIG_FILE" ] && echo "Ada" || echo "Tidak ada")${RST}"
    echo -e "${BCYAN}│${RST} ${DIM}TPM Plugin:${RST}   ${BWHITE}$([ -d "$TMUX_PLUGIN_DIR/tpm" ] && echo "Terinstall" || echo "Tidak ada")${RST}"
    echo -e "${BCYAN}└─────────────────────────────────────────────────────────────┘${RST}"
    echo ""

    # Buffer info
    echo -e "${BCYAN}┌─────────────────────────────────────────────────────────────┐${RST}"
    echo -e "${BCYAN}│${RST} ${BOLD}${BWHITE}📋 BUFFERS${RST}                                                  ${BCYAN}│${RST}"
    echo -e "${BCYAN}├─────────────────────────────────────────────────────────────┤${RST}"
    local buffers=$(tmux list-buffers 2>/dev/null)
    if [ -z "$buffers" ]; then
        echo -e "${BCYAN}│${RST} ${DIM}(tidak ada buffer)${RST}"
    else
        while IFS= read -r buf; do
            echo -e "${BCYAN}│${RST} ${DIM}${buf}${RST}"
        done <<< "$buffers"
    fi
    echo -e "${BCYAN}└─────────────────────────────────────────────────────────────┘${RST}"
    echo ""

    read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
}

# ===============================
# 🎯 MAIN MENU
# ===============================
main_menu() {
    while true; do
        header
        status_bar
        tampil_session_detail

        echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════╗${RST}"
        echo -e "${BCYAN}║${RST} ${BOLD}${BWHITE}📋 MENU UTAMA${RST}                                                ${BCYAN}║${RST}"
        echo -e "${BCYAN}╠══════════════════════════════════════════════════════════════╣${RST}"
        echo -e "${BCYAN}║${RST}                                                              ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST}  ${BOLD}${BGREEN}📦${RST} ${BOLD}[1]${RST}  Install Tmux          ${DIM}┃${RST}  ${BOLD}${BCYAN}🪟${RST}  ${BOLD}[7]${RST}  Window Management  ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST}  ${BOLD}${BGREEN}🆕${RST} ${BOLD}[2]${RST}  Buat Session Baru     ${DIM}┃${RST}  ${BOLD}${BMAGENTA}📐${RST} ${BOLD}[8]${RST}  Pane Management    ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST}  ${BOLD}${BGREEN}👁️ ${RST} ${BOLD}[3]${RST}  Attach ke Session     ${DIM}┃${RST}  ${BOLD}${BYELLOW}⚙️ ${RST} ${BOLD}[9]${RST}  Konfigurasi Tmux   ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST}  ${BOLD}${BGREEN}🔍${RST} ${BOLD}[4]${RST}  Lihat Detail Session  ${DIM}┃${RST}  ${BOLD}${BCYAN}🖥️ ${RST} ${BOLD}[A]${RST}  Server Info        ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST}  ${BOLD}${BRED}💀${RST} ${BOLD}[5]${RST}  Kill Session          ${DIM}┃${RST}  ${BOLD}${BGREEN}📖${RST} ${BOLD}[H]${RST}  Help & Dokumentasi ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST}  ${BOLD}${BGREEN}✏️ ${RST} ${BOLD}[6]${RST}  Rename Session        ${DIM}┃${RST}  ${BOLD}${BRED}🚪${RST} ${BOLD}[0]${RST}  Keluar             ${BCYAN}║${RST}"
        echo -e "${BCYAN}║${RST}                                                              ${BCYAN}║${RST}"
        echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════╝${RST}"
        echo ""

        echo -e "${BCYAN}┌──(${BYELLOW}${SCRIPT_NAME} v${SCRIPT_VERSION}${RST}${BCYAN})${RST}"
        read -p "$(echo -e ${BCYAN}└──▶️  ${RST}) " pilih
        echo ""

        case "$pilih" in
            1)  install_tmux ;;
            2)  buat_session ;;
            3)  attach_session ;;
            4)  lihat_detail_session ;;
            5)  kill_session ;;
            6)  rename_session ;;
            7)  window_management ;;
            8)  pane_management ;;
            9)  konfigurasi_tmux ;;
            [Aa]) server_info ;;
            [Hh]) help_dokumentasi ;;
            0)
                clear
                echo ""
                echo -e "${BGREEN}╔══════════════════════════════════════════════════════════════╗${RST}"
                echo -e "${BGREEN}║${RST}  ${BWHITE}👋 Terima kasih telah menggunakan Tmux Manager!${RST}             ${BGREEN}║${RST}"
                echo -e "${BGREEN}║${RST}  ${DIM}💡 Tip: Jalankan 'tmux' kapan saja dari terminal.${RST}           ${BGREEN}║${RST}"
                echo -e "${BGREEN}╚══════════════════════════════════════════════════════════════╝${RST}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${BRED}❌ Pilihan tidak valid!${RST}"
                echo -e "${DIM}   Pilih angka 1-9, H untuk Help, A untuk Server Info, 0 untuk Keluar.${RST}"
                read -p "$(echo -e ${BCYAN}[Enter untuk lanjut...]${RST})"
                ;;
        esac
    done
}

# ===============================
# 🚀 START PROGRAM
# ===============================

# Buat direktori tmux jika belum ada
mkdir -p "$TMUX_CONFIG_DIR" 2>/dev/null

# Cek dependencies
if ! command -v tmux >/dev/null 2>&1; then
    echo ""
    echo -e "${BYELLOW}╔══════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${BYELLOW}║${RST}  ${BWHITE}⚠️  Tmux belum terinstall!${RST}                                   ${BYELLOW}║${RST}"
    echo -e "${BYELLOW}║${RST}  ${DIM}Jalankan menu [1] untuk menginstall tmux terlebih dahulu.${RST}   ${BYELLOW}║${RST}"
    echo -e "${BYELLOW}╚══════════════════════════════════════════════════════════════╝${RST}"
    echo ""
    sleep 2
fi

# Logging
log_action "Tmux Manager dimulai"

# Jalankan main menu
main_menu