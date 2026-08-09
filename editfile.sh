#!/bin/bash

# ── ANSI Color & Style ──────────────────────────────────────────
BLK='\033[0;30m';  RED='\033[0;31m';  GRN='\033[0;32m';  YLW='\033[0;33m'
BLU='\033[0;34m';  MGT='\033[0;35m';  CYN='\033[0;36m';  WHT='\033[0;37m'
BRED='\033[1;31m'; BGRN='\033[1;32m'; BYLW='\033[1;33m'; BBLU='\033[1;34m'
BMGT='\033[1;35m'; BCYN='\033[1;36m'; BWHT='\033[1;37m'
BG_BLK='\033[40m'; BG_RED='\033[41m'; BG_GRN='\033[42m'; BG_YLW='\033[43m'
BG_BLU='\033[44m'; BG_MGT='\033[45m'; BG_CYN='\033[46m'; BG_WHT='\033[47m'
BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'


styled_input() {
    printf "  ${BCYN}❯${NC} ${BYLW}%-32s${NC}${BCYN}:${NC} " "$1"
    read -r "$2"
}

print_submenu_header() {
    local num="$1" title="$2" color="$3" icon="$4"
    clear
    echo ""
    echo -e "${BBLU}  ╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BBLU}  ║${NC}${BG_BLU}${BWHT}${BOLD}    ⚙  SERVICE MANAGER  ─  Ubuntu systemd Tools  ⚙        ${NC}${BBLU}║${NC}"
    echo -e "${BBLU}  ╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${color}${BG_BLK}${BOLD} ${icon} MENU ${num} — ${title} ${NC}"
    sep_thick
    echo ""
}

# ── Separator ───────────────────────────────────────────────────
sep_thin()  { echo -e "${DIM}${BLU}  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄${NC}"; }
sep_thick() { echo -e "${BBLU}  ════════════════════════════════════════════════════════${NC}"; }
sep_dash()  { echo -e "${DIM}  ────────────────────────────────────────────────────────${NC}"; }

# ── Animasi loading ──────────────────────────────────────────────
loading() {
    local msg="${1:-Loading}"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    local end=$((SECONDS + 1))
    while [[ $SECONDS -lt $end ]]; do
        printf "\r  ${BCYN}${frames[$i]}${NC} ${CYN}${msg}...${NC}"
        i=$(( (i+1) % ${#frames[@]} ))
        sleep 0.08
    done
    printf "\r  ${BGRN}✔${NC} ${GRN}${msg} selesai.${NC}        \n"
}

# ── Badge status ─────────────────────────────────────────────────
badge_running()  { echo -e " ${BG_GRN}${BLK}${BOLD}  RUNNING  ${NC}"; }
badge_stopped()  { echo -e " ${BG_RED}${BWHT}${BOLD}  STOPPED  ${NC}"; }
badge_failed()   { echo -e " ${BG_RED}${BYLW}${BOLD}  FAILED   ${NC}"; }
badge_inactive() { echo -e " ${BG_BLK}${WHT}${BOLD}  INACTIVE ${NC}"; }
badge_enabled()  { echo -e " ${BG_GRN}${BLK}${BOLD}  ENABLED  ${NC}"; }
badge_disabled() { echo -e " ${BG_YLW}${BLK}${BOLD}  DISABLED ${NC}"; }

# ── Pesan ─────────────────────────────────────────────────────────
msg_ok()   { echo -e "\n  ${BG_GRN}${BLK}${BOLD} ✔ SUKSES ${NC}  ${BGRN}$1${NC}"; }
msg_err()  { echo -e "\n  ${BG_RED}${BWHT}${BOLD} ✗ ERROR  ${NC}  ${BRED}$1${NC}"; }
msg_warn() { echo -e "\n  ${BG_YLW}${BLK}${BOLD} ⚠ PERINGATAN ${NC}  ${BYLW}$1${NC}"; }
msg_info() { echo -e "  ${BG_BLU}${BWHT}${BOLD} ℹ INFO   ${NC}  ${BCYN}$1${NC}"; }

pause_return() {
    echo ""
    sep_thin
    echo -e "  ${DIM}${CYN}↩  Tekan ${BCYN}[Enter]${CYN} untuk kembali ke menu utama...${NC}"
    read -r
}

require_service_file() {
    local name="$1"
    if [[ ! -f "/usr/local/bin/${name}" ]]; then
        msg_err "File '/usr/local/bin/${name}' tidak ditemukan."
        pause_return; return 1
    fi
    return 0
}



menu_cat_edit_service() {
    print_submenu_header "" "Tampilkan / Edit File" "${BCYN}" "📝"


    echo -e "\033[1;36mDaftar Script:\033[0m"
    echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    local FOLDER="/usr/local/bin"
    local files=()
    local nomor file SERVICE_FILE

    # Simpan hanya file biasa agar nomor daftar selalu konsisten.
    mapfile -t files < <(find "$FOLDER" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null | sort)

    if (( ${#files[@]} == 0 )); then
        msg_err "Tidak ada file di '${FOLDER}'."
        pause_return
        return
    fi

    local i
    for i in "${!files[@]}"; do
        printf "  %3d) %s\n" "$((i + 1))" "${files[$i]}"
    done

    echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

        # Pilih file dan ulangi pertanyaan sampai nomornya valid.
        while true; do
            read -rp "Masukkan nomor file yang ingin dilihat atau diedit: " nomor
            if [[ "$nomor" =~ ^[0-9]+$ ]] && (( nomor >= 1 && nomor <= ${#files[@]} )); then
                file="${files[$((nomor - 1))]}"
                SERVICE_FILE="${FOLDER}/${file}"
                break
            fi
            msg_err "Nomor tidak valid. Pilih nomor 1-${#files[@]}."
        done
    echo -e "  ${BG_CYN}${BLK}${BOLD}  [1]  🔎  TAMPILKAN ISI FILE (cat)  ${NC}"
    echo -e "  ${BG_YLW}${BLK}${BOLD}  [2]  ✏   EDIT FILE MANUAL (nano)   ${NC}"
        msg_info "File terpilih: ${file}"
        echo ""
    echo ""
    printf "  ${BCYN}❯ Pilihan [1/2]${NC} : "
    read -r AKSI; echo ""

    case $AKSI in
        1)
            sep_thick
            echo -e "  ${BG_CYN}${BLK}${BOLD}  📄 ISI FILE: ${SERVICE_FILE}  ${NC}"
            sep_thick; echo ""
            local lnum=0
            while IFS= read -r ln || [[ -n "$ln" ]]; do
                (( lnum++ ))
                printf "  ${DIM}%3d${NC}  " "$lnum"
                if [[ "$ln" =~ ^\[.*\]$ ]]; then
                    echo -e "${BG_BLU}${BWHT}${BOLD} ${ln} ${NC}"
                elif [[ "$ln" =~ ^#.* ]]; then
                    echo -e "${DIM}${GRN}${ln}${NC}"
                elif [[ "$ln" =~ ^[A-Za-z].*= ]]; then
                    local key; key=$(echo "$ln" | cut -d= -f1)
                    local val; val=$(echo "$ln" | cut -d= -f2-)
                    echo -e "${BCYN}${key}${NC}${DIM}=${NC}${BWHT}${val}${NC}"
                elif [[ -z "$ln" ]]; then
                    echo ""
                else
                    echo -e "${DIM}${ln}${NC}"
                fi
            done < "$SERVICE_FILE"
            echo ""; sep_thick
            ;;
        2)
            if ! command -v nano &>/dev/null; then
                msg_err "nano tidak ditemukan. Install: apt install nano"
                pause_return; return
            fi
            echo -e "  ${BYLW}▶ Membuka${NC} ${BWHT}${SERVICE_FILE}${NC} ${BYLW}di nano...${NC}"
            echo -e "  ${DIM}  Simpan: Ctrl+O → Enter  |  Keluar: Ctrl+X${NC}"
            sleep 1
            nano "$SERVICE_FILE"
            msg_ok "File disimpan."
            echo ""
            ;;
        *) msg_err "Pilihan tidak valid." ;;
    esac
    pause_return
}

# Jalankan menu utama jika script dieksekusi langsung
menu_cat_edit_service