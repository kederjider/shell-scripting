#!/bin/bash

# ================================================================
#   ███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗
#   ██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝
#   ███████╗█████╗  ██████╔╝██║   ██║██║██║     █████╗
#   ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ██╔══╝
#   ███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████╗
#   ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝
#            M A N A G E R  —  Ubuntu systemd Tools
# ================================================================

# ── ANSI Color & Style ──────────────────────────────────────────
BLK='\033[0;30m';  RED='\033[0;31m';  GRN='\033[0;32m';  YLW='\033[0;33m'
BLU='\033[0;34m';  MGT='\033[0;35m';  CYN='\033[0;36m';  WHT='\033[0;37m'
BRED='\033[1;31m'; BGRN='\033[1;32m'; BYLW='\033[1;33m'; BBLU='\033[1;34m'
BMGT='\033[1;35m'; BCYN='\033[1;36m'; BWHT='\033[1;37m'
BG_BLK='\033[40m'; BG_RED='\033[41m'; BG_GRN='\033[42m'; BG_YLW='\033[43m'
BG_BLU='\033[44m'; BG_MGT='\033[45m'; BG_CYN='\033[46m'; BG_WHT='\033[47m'
BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

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

# ── Input bergaya ─────────────────────────────────────────────────
styled_input() {
    printf "  ${BCYN}❯${NC} ${BYLW}%-32s${NC}${BCYN}:${NC} " "$1"
    read -r "$2"
}

# ── Header utama ──────────────────────────────────────────────────
print_header() {
    clear
    echo ""
    echo -e "${BBLU}  ╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BBLU}  ║${NC}${BG_BLU}${BWHT}${BOLD}                                                          ${NC}${BBLU}║${NC}"
    echo -e "${BBLU}  ║${NC}${BG_BLU}${BYLW}${BOLD}    ⚙  SERVICE MANAGER  ─  Ubuntu systemd Tools  ⚙        ${NC}${BBLU}║${NC}"
    echo -e "${BBLU}  ║${NC}${BG_BLU}${BCYN}${BOLD}              Kelola systemd service dengan mudah         ${NC}${BBLU}║${NC}"
    echo -e "${BBLU}  ║${NC}${BG_BLU}${BWHT}${BOLD}                                                          ${NC}${BBLU}║${NC}"
    echo -e "${BBLU}  ╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    local hname; hname=$(hostname)
    local ttime; ttime=$(date '+%H:%M:%S')
    local tdate; tdate=$(date '+%d %b %Y')
    echo -e "  ${BG_BLK}${BCYN} 🖥  ${hname} ${NC}  ${BG_BLK}${BYLW} 👤 root ${NC}  ${BG_BLK}${BWHT} 🕐 ${ttime}  ${tdate} ${NC}"
    echo ""
}

# ── Header sub-menu ───────────────────────────────────────────────
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

# ── Pause ─────────────────────────────────────────────────────────
pause_return() {
    echo ""
    sep_thin
    echo -e "  ${DIM}${CYN}↩  Tekan ${BCYN}[Enter]${CYN} untuk kembali ke menu utama...${NC}"
    read -r
}

# ── Cek root ──────────────────────────────────────────────────────
check_root() {
    if [[ $EUID -ne 0 ]]; then
        clear; echo ""
        echo -e "${BG_RED}${BWHT}${BOLD}                                              ${NC}"
        echo -e "${BG_RED}${BWHT}${BOLD}   ✗  Script harus dijalankan sebagai ROOT!   ${NC}"
        echo -e "${BG_RED}${BWHT}${BOLD}                                              ${NC}"
        echo -e "\n  ${BYLW}Gunakan:${NC} ${BWHT}sudo ./service_manager.sh${NC}\n"
        exit 1
    fi
}

# ── Cek file service ada ──────────────────────────────────────────
require_service_file() {
    local name="$1"
    if [[ ! -f "/etc/systemd/system/${name}.service" ]]; then
        msg_err "File '/etc/systemd/system/${name}.service' tidak ditemukan."
        pause_return; return 1
    fi
    return 0
}

# ════════════════════════════════════════════════════════════════
#  MENU 1 ─ Buat Service Baru
# ════════════════════════════════════════════════════════════════
menu_buat_service() {
    print_submenu_header "1" "Buat Service Baru" "${BGRN}" "➕"
    echo -e "  ${BYLW}Isi form berikut untuk membuat unit service systemd baru:${NC}"
    echo ""

    styled_input "Nama Service (tanpa .service)" SERVICE_NAME
    [[ -z "$SERVICE_NAME" ]] && { msg_err "Nama service tidak boleh kosong."; pause_return; return; }

    local SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
    if [[ -f "$SERVICE_FILE" ]]; then
        msg_warn "Service '${SERVICE_NAME}' sudah ada!"
        msg_info "Path: ${SERVICE_FILE}"
        pause_return; return
    fi

    styled_input "Description" DESCRIPTION
    styled_input "WorkingDirectory" WORKING_DIR
    styled_input "ExecStart" EXEC_START

    if [[ -z "$DESCRIPTION" || -z "$WORKING_DIR" || -z "$EXEC_START" ]]; then
        msg_err "Semua field wajib diisi."; pause_return; return
    fi

    echo ""
    sep_dash
    echo -e "  ${BCYN}Preview file yang akan dibuat:${NC}"
    sep_dash
    echo -e "  ${BG_BLU}${BWHT}${BOLD} [Unit] ${NC}"
    echo -e "  ${BCYN}Description${NC}=${BWHT}${DESCRIPTION}${NC}"
    echo -e "  ${DIM}After=network.target${NC}"
    echo ""
    echo -e "  ${BG_BLU}${BWHT}${BOLD} [Service] ${NC}"
    echo -e "  ${BCYN}Type${NC}=${BWHT}simple${NC}  ${BCYN}User${NC}=${BWHT}root${NC}"
    echo -e "  ${BCYN}WorkingDirectory${NC}=${BWHT}${WORKING_DIR}${NC}"
    echo -e "  ${BCYN}ExecStart${NC}=${BWHT}${EXEC_START}${NC}"
    echo -e "  ${DIM}Restart=on-failure  RestartSec=5${NC}"
    echo ""
    echo -e "  ${BG_BLU}${BWHT}${BOLD} [Install] ${NC}"
    echo -e "  ${DIM}WantedBy=multi-user.target${NC}"
    sep_dash
    echo ""
    printf "  ${BYLW}❯ Konfirmasi buat service? ${BWHT}[y/n]${NC} : "
    read -r KONFIRM
    [[ "$KONFIRM" != "y" && "$KONFIRM" != "Y" ]] && { msg_warn "Dibatalkan."; pause_return; return; }

    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=${DESCRIPTION}
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${WORKING_DIR}
ExecStart=${EXEC_START}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    loading "Membuat service"
    systemctl daemon-reload
    systemctl enable "${SERVICE_NAME}.service" &>/dev/null

    msg_ok "Service '${SERVICE_NAME}' berhasil dibuat & di-enable!"
    echo ""
    msg_info "Path   : ${SERVICE_FILE}"
    msg_info "Jalankan: systemctl start ${SERVICE_NAME}"
    pause_return
}

# ════════════════════════════════════════════════════════════════
#  MENU 2 ─ Service Running
# ════════════════════════════════════════════════════════════════
menu_service_running() {
    print_submenu_header "2" "Service yang Sedang RUNNING" "${BGRN}" "▶"
    echo -e "  ${BG_GRN}${BLK}${BOLD}  ● ACTIVE / RUNNING  ${NC}  ${DIM}Service yang sedang berjalan:${NC}"
    echo ""

    local count=0
    while IFS= read -r line; do
        [[ "$line" =~ ^UNIT|^$|loaded\ units|listed ]] && continue
        if echo "$line" | grep -q "running"; then
            local svc_name; svc_name=$(echo "$line" | awk '{print $1}')
            printf "  ${BGRN}●${NC} ${BWHT}%-48s${NC} ${BG_GRN}${BLK} RUNNING ${NC}\n" "$svc_name"
            (( count++ ))
        fi
    done < <(systemctl list-units --type=service --state=running --no-pager --plain 2>/dev/null)

    echo ""
    sep_dash
    echo -e "  ${BGRN}${BOLD}Total service running: ${BYLW}${count}${NC}"
    sep_thick
    pause_return
}

# ════════════════════════════════════════════════════════════════
#  MENU 3 ─ Service Tidak Running
# ════════════════════════════════════════════════════════════════
menu_service_not_running() {
    print_submenu_header "3" "Service yang TIDAK Running" "${BRED}" "✗"

    echo -e "  ${BG_RED}${BWHT}${BOLD}  ✗ FAILED SERVICES  ${NC}"
    echo ""
    local fail_count=0
    while IFS= read -r line; do
        [[ "$line" =~ ^UNIT|^$|loaded\ units|listed ]] && continue
        if echo "$line" | grep -q "failed"; then
            local svc_name; svc_name=$(echo "$line" | awk '{print $1}')
            printf "  ${BRED}✗${NC} ${BRED}%-48s${NC} ${BG_RED}${BWHT} FAILED ${NC}\n" "$svc_name"
            (( fail_count++ ))
        fi
    done < <(systemctl list-units --type=service --state=failed --no-pager --plain 2>/dev/null)
    [[ $fail_count -eq 0 ]] && echo -e "  ${DIM}  Tidak ada service yang failed. ✓${NC}"

    echo ""; sep_dash; echo ""
    echo -e "  ${BG_BLK}${WHT}${BOLD}  ○ INACTIVE SERVICES  ${NC}"
    echo ""
    local inact_count=0
    while IFS= read -r line; do
        [[ "$line" =~ ^UNIT|^$|loaded\ units|listed ]] && continue
        if echo "$line" | grep -q "inactive"; then
            local svc_name; svc_name=$(echo "$line" | awk '{print $1}')
            printf "  ${DIM}○  %-48s IDLE${NC}\n" "$svc_name"
            (( inact_count++ ))
            [[ $inact_count -ge 25 ]] && { echo -e "  ${DIM}  ... dan lebih banyak lagi${NC}"; break; }
        fi
    done < <(systemctl list-units --type=service --state=inactive --no-pager --plain 2>/dev/null)
    [[ $inact_count -eq 0 ]] && echo -e "  ${DIM}  Tidak ada service inactive.${NC}"

    echo ""; sep_dash
    echo -e "  ${BRED}Failed: ${fail_count}${NC}   ${DIM}Inactive: ${inact_count}${NC}"
    sep_thick
    pause_return
}

# ════════════════════════════════════════════════════════════════
#  MENU 4 ─ Semua Service
# ════════════════════════════════════════════════════════════════
menu_semua_service() {
    print_submenu_header "4" "Semua Service (Aktif & Non-Aktif)" "${BCYN}" "📋"
    echo -e "  ${DIM}Legenda:${NC}  ${BGRN}● running${NC}  ${BRED}✗ failed${NC}  ${DIM}○ inactive${NC}  ${BYLW}⚡ activating${NC}"
    echo ""

    local r=0 f=0 i=0 o=0
    while IFS= read -r line; do
        [[ "$line" =~ ^UNIT|^$|loaded\ units|listed|^Legend ]] && continue
        local svc_name; svc_name=$(echo "$line" | awk '{print $1}')
        [[ -z "$svc_name" ]] && continue
        if echo "$line" | grep -q "running"; then
            printf "  ${BGRN}●${NC} ${BWHT}%-52s${NC} ${BG_GRN}${BLK} RUN ${NC}\n" "$svc_name"; (( r++ ))
        elif echo "$line" | grep -q "failed"; then
            printf "  ${BRED}✗${NC} ${BRED}%-52s${NC} ${BG_RED}${BWHT} ERR ${NC}\n" "$svc_name"; (( f++ ))
        elif echo "$line" | grep -q "activating"; then
            printf "  ${BYLW}⚡${NC} ${BYLW}%-52s${NC} ${BG_YLW}${BLK} ACT ${NC}\n" "$svc_name"; (( o++ ))
        elif echo "$line" | grep -q "inactive"; then
            printf "  ${DIM}○  %-52s IDLE${NC}\n" "$svc_name"; (( i++ ))
        fi
    done < <(systemctl list-units --type=service --all --no-pager --plain 2>/dev/null)

    echo ""; sep_dash
    echo -e "  ${BGRN}Running: ${r}${NC}  ${BRED}Failed: ${f}${NC}  ${DIM}Inactive: ${i}${NC}  ${BYLW}Activating: ${o}${NC}"
    sep_thick
    pause_return
}

# ════════════════════════════════════════════════════════════════
#  MENU 5 ─ Cek Status Service
# ════════════════════════════════════════════════════════════════
menu_status_service() {
    print_submenu_header "5" "Cek Status Service" "${BMGT}" "🔍"

    styled_input "Nama Service (tanpa .service)" SVC_NAME
    [[ -z "$SVC_NAME" ]] && { msg_err "Nama tidak boleh kosong."; pause_return; return; }

    local STATUS; STATUS=$(systemctl is-active "${SVC_NAME}.service" 2>/dev/null)
    local ENABLED; ENABLED=$(systemctl is-enabled "${SVC_NAME}.service" 2>/dev/null)

    echo ""; sep_dash
    printf "  %-24s" "Service:"
    echo -e "${BWHT}${BOLD} ${SVC_NAME}.service${NC}"
    printf "  %-24s" "Active Status:"
    if   [[ "$STATUS"  == "active"   ]]; then badge_running
    elif [[ "$STATUS"  == "failed"   ]]; then badge_failed
    elif [[ "$STATUS"  == "inactive" ]]; then badge_inactive
    else echo -e " ${DIM}${STATUS}${NC}"; fi

    printf "  %-24s" "Boot Status:"
    if   [[ "$ENABLED" == "enabled"  ]]; then badge_enabled
    elif [[ "$ENABLED" == "disabled" ]]; then badge_disabled
    else echo -e " ${DIM}${ENABLED}${NC}"; fi

    sep_dash; echo ""
    echo -e "  ${BCYN}${BOLD}[ systemctl status output ]${NC}"
    sep_thin
    systemctl status "${SVC_NAME}.service" --no-pager -l 2>&1 \
      | while IFS= read -r ln; do
            if echo "$ln" | grep -q "Active: active"; then
                echo -e "  ${BGRN}${ln}${NC}"
            elif echo "$ln" | grep -q "Active: failed\|Active: inactive"; then
                echo -e "  ${BRED}${ln}${NC}"
            elif echo "$ln" | grep -q "Loaded:"; then
                echo -e "  ${BCYN}${ln}${NC}"
            elif echo "$ln" | grep -q "Main PID\|Tasks\|Memory\|CPU"; then
                echo -e "  ${BYLW}${ln}${NC}"
            else
                echo -e "  ${DIM}${ln}${NC}"
            fi
        done
    sep_thick
    pause_return
}

# ════════════════════════════════════════════════════════════════
#  MENU 6 ─ Enable / Disable Service
# ════════════════════════════════════════════════════════════════
menu_enable_disable() {
    print_submenu_header "6" "Enable / Disable Service" "${BYLW}" "⚡"

    styled_input "Nama Service (tanpa .service)" SVC_NAME
    [[ -z "$SVC_NAME" ]] && { msg_err "Nama tidak boleh kosong."; pause_return; return; }
    require_service_file "$SVC_NAME" || return

    local CURRENT; CURRENT=$(systemctl is-enabled "${SVC_NAME}.service" 2>/dev/null)
    echo ""
    printf "  %-24s" "Status boot saat ini:"
    if [[ "$CURRENT" == "enabled" ]]; then badge_enabled; else badge_disabled; fi

    echo ""
    echo -e "  ${BG_BLK}${BWHT}  Pilih aksi untuk:${NC} ${BYLW}${BOLD} ${SVC_NAME} ${NC}"
    echo ""
    echo -e "  ${BG_GRN}${BLK}${BOLD}  [1]  ENABLE   ${NC}  ${DIM}Aktifkan service saat boot${NC}"
    echo -e "  ${BG_RED}${BWHT}${BOLD}  [2]  DISABLE  ${NC}  ${DIM}Nonaktifkan service saat boot${NC}"
    echo ""
    printf "  ${BCYN}❯ Pilihan [1/2]${NC} : "
    read -r AKSI; echo ""

    case $AKSI in
        1) loading "Enabling service"
           systemctl enable "${SVC_NAME}.service" &>/dev/null \
             && msg_ok "Service '${SVC_NAME}' berhasil di-ENABLE." \
             || msg_err "Gagal enable service '${SVC_NAME}'." ;;
        2) loading "Disabling service"
           systemctl disable "${SVC_NAME}.service" &>/dev/null \
             && msg_ok "Service '${SVC_NAME}' berhasil di-DISABLE." \
             || msg_err "Gagal disable service '${SVC_NAME}'." ;;
        *) msg_err "Pilihan tidak valid." ;;
    esac
    pause_return
}

# ════════════════════════════════════════════════════════════════
#  MENU 7 ─ Hapus File Service
# ════════════════════════════════════════════════════════════════
menu_hapus_service() {
    print_submenu_header "7" "Hapus File Service" "${BRED}" "🗑"

    styled_input "Nama Service yang akan dihapus (tanpa .service)" SVC_NAME
    [[ -z "$SVC_NAME" ]] && { msg_err "Nama tidak boleh kosong."; pause_return; return; }

    local SERVICE_FILE="/etc/systemd/system/${SVC_NAME}.service"
    require_service_file "$SVC_NAME" || return

    echo ""
    echo -e "  ${BG_RED}${BWHT}${BOLD}  ⚠ PERINGATAN — AKSI INI TIDAK BISA DIBATALKAN!  ${NC}"
    echo ""
    echo -e "  ${DIM}File yang akan dihapus:${NC}"
    echo -e "  ${BRED}  ${SERVICE_FILE}${NC}"
    echo ""
    echo -e "  ${BYLW}  1.${NC} stop & disable ${SVC_NAME}"
    echo -e "  ${BYLW}  2.${NC} rm -f ${SERVICE_FILE}"
    echo -e "  ${BYLW}  3.${NC} daemon-reload"
    echo ""
    printf "  ${BRED}❯ Ketik ${BWHT}'hapus'${BRED} untuk konfirmasi${NC} : "
    read -r KONFIRMASI

    if [[ "$KONFIRMASI" != "hapus" ]]; then
        msg_warn "Penghapusan dibatalkan."; pause_return; return
    fi

    loading "Menghapus service"
    systemctl stop    "${SVC_NAME}.service" &>/dev/null
    systemctl disable "${SVC_NAME}.service" &>/dev/null
    rm -f "$SERVICE_FILE"
    systemctl daemon-reload
    systemctl reset-failed &>/dev/null

    msg_ok "Service '${SVC_NAME}' berhasil dihapus!"
    pause_return
}

# ════════════════════════════════════════════════════════════════
#  MENU 8 ─ Stop / Start / Restart Service
# ════════════════════════════════════════════════════════════════
menu_stop_start() {
    print_submenu_header "8" "Stop / Start / Restart Service" "${BBLU}" "⏯"

    styled_input "Nama Service (tanpa .service)" SVC_NAME
    [[ -z "$SVC_NAME" ]] && { msg_err "Nama tidak boleh kosong."; pause_return; return; }
    require_service_file "$SVC_NAME" || return

    local CURRENT_STATUS; CURRENT_STATUS=$(systemctl is-active "${SVC_NAME}.service" 2>/dev/null)

    echo ""; sep_dash
    printf "  %-24s" "Service:"
    echo -e "${BWHT}${BOLD} ${SVC_NAME}${NC}"
    printf "  %-24s" "Status saat ini:"
    if   [[ "$CURRENT_STATUS" == "active"   ]]; then badge_running
    elif [[ "$CURRENT_STATUS" == "failed"   ]]; then badge_failed
    elif [[ "$CURRENT_STATUS" == "inactive" ]]; then badge_inactive
    else echo -e " ${DIM}${CURRENT_STATUS}${NC}"; fi
    sep_dash; echo ""

    echo -e "  ${BG_GRN}${BLK}${BOLD}  [1]  ▶  START    ${NC}  ${DIM}Jalankan service${NC}"
    echo -e "  ${BG_RED}${BWHT}${BOLD}  [2]  ■  STOP     ${NC}  ${DIM}Hentikan service${NC}"
    echo -e "  ${BG_YLW}${BLK}${BOLD}  [3]  ↺  RESTART  ${NC}  ${DIM}Restart service${NC}"
    echo ""
    printf "  ${BCYN}❯ Pilihan [1/2/3]${NC} : "
    read -r AKSI; echo ""

    case $AKSI in
        1) loading "Starting service"
           systemctl start   "${SVC_NAME}.service" \
             && msg_ok "Service '${SVC_NAME}' berhasil di-START."   || msg_err "Gagal START." ;;
        2) loading "Stopping service"
           systemctl stop    "${SVC_NAME}.service" \
             && msg_ok "Service '${SVC_NAME}' berhasil di-STOP."    || msg_err "Gagal STOP." ;;
        3) loading "Restarting service"
           systemctl daemon-reload && systemctl restart "${SVC_NAME}.service" \
             && msg_ok "Service '${SVC_NAME}' berhasil di-RESTART." || msg_err "Gagal RESTART." ;;
        *) msg_err "Pilihan tidak valid."; pause_return; return ;;
    esac

    echo ""; echo -e "  ${BCYN}${BOLD}[ Status Terbaru ]${NC}"; sep_thin
    systemctl status "${SVC_NAME}.service" --no-pager -l 2>&1 | head -20 \
      | while IFS= read -r ln; do
            if echo "$ln" | grep -q "Active: active"; then echo -e "  ${BGRN}${ln}${NC}"
            elif echo "$ln" | grep -q "Active: fail\|Active: inact"; then echo -e "  ${BRED}${ln}${NC}"
            else echo -e "  ${DIM}${ln}${NC}"; fi
        done
    sep_thick
    pause_return
}

# ════════════════════════════════════════════════════════════════
#  MENU 9 ─ Tampilkan (cat) & Edit (nano) File Service
# ════════════════════════════════════════════════════════════════
menu_cat_edit_service() {
    print_submenu_header "9" "Tampilkan / Edit File Service" "${BCYN}" "📝"

    styled_input "Nama Service (tanpa .service)" SVC_NAME
    [[ -z "$SVC_NAME" ]] && { msg_err "Nama tidak boleh kosong."; pause_return; return; }

    local SERVICE_FILE="/etc/systemd/system/${SVC_NAME}.service"
    require_service_file "$SVC_NAME" || return

    echo ""
    echo -e "  ${BG_CYN}${BLK}${BOLD}  [1]  🔎  TAMPILKAN ISI FILE (cat)  ${NC}"
    echo -e "  ${BG_YLW}${BLK}${BOLD}  [2]  ✏   EDIT FILE MANUAL (nano)   ${NC}"
    echo ""
    printf "  ${BCYN}❯ Pilihan [1/2]${NC} : "
    read -r AKSI; echo ""

    case $AKSI in
        1)
            sep_thick
            echo -e "  ${BG_CYN}${BLK}${BOLD}  📄 ISI FILE: ${SERVICE_FILE}  ${NC}"
            sep_thick; echo ""
            local lnum=0
            while IFS= read -r ln; do
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
            loading "Menjalankan daemon-reload"
            systemctl daemon-reload
            msg_ok "File disimpan. daemon-reload telah dijalankan."
            echo ""
            printf "  ${BYLW}❯ Restart '${SVC_NAME}' sekarang? ${BWHT}[y/n]${NC} : "
            read -r RESTART_NOW
            if [[ "$RESTART_NOW" == "y" || "$RESTART_NOW" == "Y" ]]; then
                loading "Restarting service"
                systemctl restart "${SVC_NAME}.service" \
                  && msg_ok "Service '${SVC_NAME}' berhasil di-restart." \
                  || msg_err "Gagal restart service '${SVC_NAME}'."
            fi
            ;;
        *) msg_err "Pilihan tidak valid." ;;
    esac
    pause_return
}

# ════════════════════════════════════════════════════════════════
#  MAIN MENU
# ════════════════════════════════════════════════════════════════
main_menu() {
    while true; do
        print_header

        local run_count fail_count
        run_count=$(systemctl list-units --type=service --state=running --no-pager --plain 2>/dev/null | grep -c "running" || echo 0)
        fail_count=$(systemctl list-units --type=service --state=failed  --no-pager --plain 2>/dev/null | grep -c "failed"  || echo 0)

        echo -e "  ${BG_GRN}${BLK}${BOLD}  ● Running : ${run_count}  ${NC}   ${BG_RED}${BWHT}${BOLD}  ✗ Failed : ${fail_count}  ${NC}"
        echo ""
        sep_thick
        echo -e "  ${BWHT}${BOLD}  PILIH MENU  ${NC}"
        echo ""
        echo -e "  ${BG_GRN}${BWHT}${BOLD}  1 ${NC} ${BGRN} ➕  Buat Service Baru${NC}"
        echo -e "  ${BG_CYN}${BWHT}${BOLD}  2 ${NC} ${BCYN} ▶   Lihat Service Running${NC}"
        echo -e "  ${BG_RED}${BWHT}${BOLD}  3 ${NC} ${BRED} ✗   Lihat Service Tidak Running${NC}"
        echo -e "  ${BG_BLU}${BWHT}${BOLD}  4 ${NC} ${BBLU} 📋  Lihat Semua Service${NC}"
        echo -e "  ${BG_MGT}${BWHT}${BOLD}  5 ${NC} ${BMGT} 🔍  Cek Status Service${NC}"
        echo -e "  ${BG_YLW}${BWHT}${BOLD}  6 ${NC} ${BYLW} ⚡  Enable / Disable Service${NC}"
        echo -e "  ${BG_RED}${BWHT}${BOLD}  7 ${NC} ${BRED} 🗑   Hapus File Service${NC}"
        echo -e "  ${BG_BLU}${BWHT}${BOLD}  8 ${NC} ${BBLU} ⏯   Stop / Start / Restart Service${NC}"
        echo -e "  ${BG_CYN}${BWHT}${BOLD}  9 ${NC} ${BCYN} 📝  Tampilkan (cat) / Edit (nano)${NC}"
        echo -e "  ${BG_BLK}${BWHT}${BOLD}  0 ${NC} ${DIM} 🚪  Keluar${NC}"
        echo ""
        sep_thick
        printf "  ${BCYN}${BOLD}❯ Masukkan pilihan ${BWHT}[1-9]${BCYN} : ${NC}"
        read -r PILIHAN; echo ""

        case $PILIHAN in
            1)  menu_buat_service ;;
            2)  menu_service_running ;;
            3)  menu_service_not_running ;;
            4)  menu_semua_service ;;
            5)  menu_status_service ;;
            6)  menu_enable_disable ;;
            7)  menu_hapus_service ;;
            8)  menu_stop_start ;;
            9)  menu_cat_edit_service ;;
            0)
                echo ""
                echo -e "  ${BG_BLU}${BWHT}${BOLD}                                      ${NC}"
                echo -e "  ${BG_BLU}${BWHT}${BOLD}   👋  Terima kasih! Sampai jumpa.    ${NC}"
                echo -e "  ${BG_BLU}${BWHT}${BOLD}                                      ${NC}"
                echo ""; exit 0 ;;
            *)
                msg_err "Pilihan tidak valid! Masukkan angka 1–9."
                sleep 1 ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════════
#  ENTRY POINT
# ════════════════════════════════════════════════════════════════
check_root
main_menu