#!/bin/bash
# ===============================
# WARNA & STYLING
# ===============================
RST='\033[0m'
BOLD='\033[1m'
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
MAGENTA='\033[95m'
CYAN='\033[96m'
WHITE='\033[97m'

# ===============================
# CEK SUDO
# ===============================
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[!]${RST} Script ini butuh akses ${BOLD}sudo${RST}. Meminta izin..."
    sudo -v || { echo -e "${RED}[-]${RST} Gagal mendapatkan akses sudo.${RST}"; exit 1; }
fi

# ===============================
# FUNGSI HEADER
# ===============================
header() {
    clear
    echo -e "${MAGENTA}${BOLD}╔═══════════════════════════════════════════╗${RST}"
    echo -e "${MAGENTA}${BOLD}║${RST}     ${CYAN}SCREEN MENU UNTUK SSH TOOLS${RST}           ${MAGENTA}${BOLD}║${RST}"
    echo -e "${MAGENTA}${BOLD}║${RST}       ${YELLOW}Kelola Background Sessions${RST}          ${MAGENTA}${BOLD}║${RST}"
    echo -e "${MAGENTA}${BOLD}╚═══════════════════════════════════════════╝${RST}"
    echo ""
}

# ===============================
# FUNGSI TAMPIL SESSION
# ===============================
tampil_session() {
    echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
    SESSION_LIST=$(screen -ls 2>/dev/null | grep -E '^\s+[0-9]+\.' | awk '{print $1}')
    if [ -z "$SESSION_LIST" ]; then
        echo -e "${CYAN}│${RST} ${YELLOW}Tidak ada session aktif.${RST}"
    else
        while IFS= read -r session; do
            STATUS=$(screen -ls 2>/dev/null | grep "$session" | grep -oE '\(Detached\)|\(Attached\)')
            if [ "$STATUS" = "(Attached)" ]; then
                echo -e "${CYAN}│${RST} ${GREEN}${BOLD}${session}${RST} ${GREEN}[Attached]${RST}"
            else
                echo -e "${CYAN}│${RST} ${WHITE}${session}${RST} ${YELLOW}[Detached]${RST}"
            fi
        done <<< "$SESSION_LIST"
    fi
    echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
}

# ===============================
# MENU
# ===============================
header
echo -e "${CYAN}${BOLD}PILIH MENU:${RST}"
echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[1]${RST} Install screen                      ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[2]${RST} Buat session baru screen            ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[3]${RST} Lihat daftar session (screen -ls)   ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[4]${RST} Masuk ke session (screen -r)        ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[5]${RST} Paksa masuk session (screen -r -d)  ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${RED}${BOLD}[0]${RST} Kembali ke Menu Utama               ${CYAN}│${RST}"
    echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
    echo -e ""
    echo -e "${CYAN}┌───(${YELLOW}Screen${RST}${CYAN})──[Module]"
    read -p "$(echo -e ${CYAN}└──▶️ ${RST}) " pilih
    echo ""

    case "$pilih" in
        1)
            if command -v screen >/dev/null 2>&1; then
                echo -e "${GREEN}[+]${RST} ${BOLD}Screen sudah terinstall!${RST}"
            else
                echo -e "${YELLOW}[*]${RST} Menginstall screen..."
                sudo apt update && sudo apt install -y screen
                if command -v screen >/dev/null 2>&1; then
                    echo -e "${GREEN}[+]${RST} ${BOLD}Screen berhasil diinstall!${RST}"
                else
                    echo -e "${RED}[-]${RST} Gagal install screen."
                fi
            fi
            ;;

        2)
            if ! command -v screen >/dev/null 2>&1; then
                echo -e "${RED}[-]${RST} Screen belum terinstall. Pilih menu ${BOLD}1${RST} dulu."
                read -p "$(echo -e ${CYAN}[Enter untuk lanjut...]${RST})"
                exec "$0"
            fi
            read -p "$(echo -e ${MAGENTA}[?]${RST} Masukkan nama session: ) " nama_session
            if [ -z "$nama_session" ]; then
                echo -e "${RED}[-]${RST} Nama session tidak boleh kosong!"
                read -p "$(echo -e ${CYAN}[Enter untuk lanjut...]${RST})"
                exec "$0"
            fi
            echo ""
            echo -e "${GREEN}[+]${RST} Membuat session: ${BOLD}${CYAN}${nama_session}${RST}"
            echo -e "${YELLOW}[*]${RST} Tips: Tekan ${BOLD}${CYAN}Ctrl + A${RST} lalu ${BOLD}${CYAN}D${RST} untuk detach."
            sleep 2
            screen -S "$nama_session"
            ;;

        3)
            if ! command -v screen >/dev/null 2>&1; then
                echo -e "${RED}[-]${RST} Screen belum terinstall."
            else
                echo -e "${GREEN}[+]${RST} ${BOLD}Daftar session aktif:${RST}"
                tampil_session
            fi
            ;;

        4)
            if ! command -v screen >/dev/null 2>&1; then
                echo -e "${RED}[-]${RST} Screen belum terinstall."
                read -p "$(echo -e ${CYAN}[Enter untuk lanjut...]${RST})"
                exec "$0"
            fi
            echo -e "${GREEN}[+]${RST} ${BOLD}Daftar session aktif:${RST}"
            tampil_session
            echo ""

            SESSION_LIST=$(screen -ls 2>/dev/null | grep -E '^\s+[0-9]+\.' | awk '{print $1}')
            if [ -z "$SESSION_LIST" ]; then
                read -p "$(echo -e ${CYAN}[Enter untuk lanjut...]${RST})"
                exec "$0"
            fi

            echo -e "${CYAN}┌────[${YELLOW}Masukkan nama session${RST}${CYAN}]${RST}"
            read -p "$(echo -e ${CYAN}└──▶️${RST} ) " nama_session
            if [ -z "$nama_session" ]; then
                echo -e "${RED}[-]${RST} Nama session tidak boleh kosong!"
                read -p "$(echo -e ${CYAN}[Enter untuk lanjut...]${RST})"
                exec "$0"
            fi
            echo ""
            echo -e "${GREEN}[+]${RST} Masuk ke session: ${BOLD}${CYAN}${nama_session}${RST}"
            screen -r "$nama_session"
            ;;

        5)
            if ! command -v screen >/dev/null 2>&1; then
                echo -e "${RED}[-]${RST} Screen belum terinstall."
                read -p "$(echo -e ${CYAN}[Enter untuk lanjut...]${RST})"
                exec "$0"
            fi
            echo -e "${GREEN}[+]${RST} ${BOLD}Daftar session aktif:${RST}"
            tampil_session
            echo ""

            SESSION_LIST=$(screen -ls 2>/dev/null | grep -E '^\s+[0-9]+\.' | awk '{print $1}')
            if [ -z "$SESSION_LIST" ]; then
                read -p "$(echo -e ${CYAN}[Enter untuk lanjut...]${RST})"
                exec "$0"
            fi

            read -p "$(echo -e ${MAGENTA}[?]${RST} Masukkan nama session: )" nama_session
            if [ -z "$nama_session" ]; then
                echo -e "${RED}[-]${RST} Nama session tidak boleh kosong!"
                read -p "$(echo -e ${CYAN}[Enter untuk lanjut...]${RST})"
                exec "$0"
            fi
            echo ""
            echo -e "${YELLOW}[*]${RST} Paksa masuk ke session: ${BOLD}${CYAN}${nama_session}${RST}"
            screen -r -d "$nama_session"
            ;;

        0)
            clear
            exec newmenu
            ;;

        *)
            echo -e "${RED}[-]${RST} Pilihan tidak valid!"
            read -p "$(echo -e ${CYAN}[Enter untuk lanjut...]${RST})"
            exec "$0"
            ;;
    esac

    echo ""
    read -p "$(echo -e ${CYAN}[Enter untuk kembali ke menu...]${RST})"
    exec "$0"