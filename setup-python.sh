#!/usr/bin/env bash

# ── Deteksi mode HARUS sebelum set -e ─────────────────────────
# set -e yang aktif saat di-source akan "menular" ke shell user
# dan bisa menutup terminal begitu ada satu perintah yang gagal.
SCRIPT_IS_SOURCED=0
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    SCRIPT_IS_SOURCED=1
fi

# Simpan status asli set -e agar bisa dipulihkan setelah selesai
ERREXIT_WAS_SET=0
case "$-" in *e*) ERREXIT_WAS_SET=1 ;; esac

# set -e HANYA saat dieksekusi langsung (bukan di-source)
if [ "$SCRIPT_IS_SOURCED" -eq 0 ]; then
    set -e
fi

# ══════════════════════════════════════════════════════════════
# WARNA & IKON
# ══════════════════════════════════════════════════════════════
RST='\033[0m'
BLD='\033[1m'
DIM='\033[2m'
RED='\033[91m'
GRN='\033[92m'
YLW='\033[93m'
BLU='\033[94m'
CYN='\033[96m'
MGT='\033[95m'

W=60  # lebar standar box

# Fungsi cetak
header() {
    local title="$1"
    local pad=$(( W - ${#title} - 4 ))
    local left=$(( pad / 2 ))
    local right=$(( pad - left ))
    echo
    echo -e "${BLD}${CYN}  ╔$(printf '═%.0s' $(seq 1 $W))╗${RST}"
    echo -e "${BLD}${CYN}  ║${RST}  $(printf '─%.0s' $(seq 1 $left))${BLD}${title}${RST}$(printf '─%.0s' $(seq 1 $right))  ${CYN}║${RST}"
    echo -e "${BLD}${CYN}  ╚$(printf '═%.0s' $(seq 1 $W))╝${RST}"
}

step()    { echo -e "  ${BLD}${CYN}▸${RST} ${BLD}$1${RST}"; }
info()    { echo -e "  ${DIM}│${RST}  $1"; }
ok()      { echo -e "  ${GRN}✔${RST} $1"; }
warn()    { echo -e "  ${YLW}⚠${RST} $1"; }
fail()    { echo -e "  ${RED}✘${RST} $1"; }
inst()    { echo -e "  ${MGT}↓${RST} ${DIM}Menginstall${RST} $1..."
            apt install -y "$1" >/dev/null 2>&1 && ok "$1 terinstall" || fail "$1 gagal"; }
sep()     { echo -e "  ${DIM}$(printf '─%.0s' $(seq 1 $W))${RST}"; }

# ══════════════════════════════════════════════════════════════
# BANNER
# ══════════════════════════════════════════════════════════════
echo
echo -e "${BLD}${CYN}  ╔══════════════════════════════════════════════════════════╗${RST}"
echo -e "${BLD}${CYN}  ║${RST}  ${BLD}🐍  PYTHON ENVIRONMENT SETUP${RST}$(printf ' %.0s' $(seq 1 28))${CYN}║${RST}"
echo -e "${BLD}${CYN}  ║${RST}  ${DIM}Ubuntu / Debian — Auto Setup .venv${RST}$(printf ' %.0s' $(seq 1 22))${CYN}║${RST}"
echo -e "${BLD}${CYN}  ╚══════════════════════════════════════════════════════════╝${RST}"
echo

# ══════════════════════════════════════════════════════════════
# Keluar dengan aman: exit bila dieksekusi, return bila di-source
# ══════════════════════════════════════════════════════════════
abort() {
    if [ "$SCRIPT_IS_SOURCED" -eq 1 ]; then
        return 1
    else
        exit 1
    fi
}

# ══════════════════════════════════════════════════════════════
# 1. CEK ROOT
# ══════════════════════════════════════════════════════════════
step "Cek hak akses root"
IS_ROOT=0
[ "$(id -u)" -eq 0 ] && IS_ROOT=1

if [ "$IS_ROOT" -eq 1 ]; then
    ok "Berjalan sebagai root"
elif [ "$SCRIPT_IS_SOURCED" -eq 1 ]; then
    warn "Tidak root — langkah apt (update/install) dilewati."
    info "Lanjut ke aktivasi .venv..."
else
    fail "Script harus dijalankan sebagai root."
    info "Jalankan: ${BLD}sudo bash ${BASH_SOURCE[0]}${RST}"
    exit 1
fi

# ══════════════════════════════════════════════════════════════
# 2. CEK OS
# ══════════════════════════════════════════════════════════════
step "Deteksi sistem operasi"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    ok "OS: ${BLD}${PRETTY_NAME}${RST}"
else
    fail "Tidak dapat mendeteksi sistem operasi."
    abort
fi

# ══════════════════════════════════════════════════════════════
# 3. UPDATE REPOSITORY (butuh root)
# ══════════════════════════════════════════════════════════════
if [ "$IS_ROOT" -eq 1 ]; then
    step "Update repository package"
    apt update -qq >/dev/null 2>&1 && ok "Repository diperbarui" || warn "Update repository gagal (lanjut)"
fi

# ══════════════════════════════════════════════════════════════
# 4. CEK & INSTALL PYTHON
# ══════════════════════════════════════════════════════════════
step "Cek Python"
if command -v python3 >/dev/null 2>&1; then
    PY_VER=$(python3 --version 2>&1)
    ok "Python: ${BLD}${PY_VER}${RST}"
elif [ "$IS_ROOT" -eq 1 ]; then
    warn "Python belum tersedia"
    inst python3
else
    warn "Python belum tersedia (skip install — tidak root)"
fi

# ══════════════════════════════════════════════════════════════
# 5. CEK & INSTALL PIP
# ══════════════════════════════════════════════════════════════
step "Cek pip"
if python3 -m pip --version >/dev/null 2>&1; then
    PIP_VER=$(python3 -m pip --version 2>&1 | head -1)
    ok "pip: ${BLD}${PIP_VER}${RST}"
elif [ "$IS_ROOT" -eq 1 ]; then
    warn "pip belum tersedia"
    inst python3-pip
else
    warn "pip belum tersedia (skip install — tidak root)"
fi

# ══════════════════════════════════════════════════════════════
# 6. CEK & INSTALL VENV
# ══════════════════════════════════════════════════════════════
step "Cek python3-venv"
if python3 -m venv --help >/dev/null 2>&1; then
    ok "python3-venv tersedia"
elif [ "$IS_ROOT" -eq 1 ]; then
    warn "python3-venv belum tersedia"
    inst python3-venv
else
    warn "python3-venv belum tersedia (skip install — tidak root)"
fi

# ══════════════════════════════════════════════════════════════
# 7. PACKAGE PENDUKUNG
# ══════════════════════════════════════════════════════════════
step "Package pendukung"
if [ "$IS_ROOT" -eq 1 ]; then
    PKGS=(python3-dev build-essential curl wget git ca-certificates)
    for pkg in "${PKGS[@]}"; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            info "${GRN}✔${RST} ${DIM}${pkg}${RST}"
        else
            info "${MGT}↓${RST} ${DIM}${pkg}...${RST}"
            apt install -y "$pkg" >/dev/null 2>&1
        fi
    done
else
    info "${DIM}Dilewati (tidak root)${RST}"
fi

# ══════════════════════════════════════════════════════════════
# 8. VIRTUAL ENVIRONMENT
# ══════════════════════════════════════════════════════════════
header "VIRTUAL ENVIRONMENT"

#VENV_DIR="$(pwd)/.venv"
VENV_DIR="/usr/local/bin/.venv"


step "Cek .venv"
if [ -d "$VENV_DIR" ]; then
    ok ".venv sudah ada: ${BLD}${VENV_DIR}${RST}"
else
    warn ".venv belum ada — membuat..."
    python3 -m venv "$VENV_DIR" && ok ".venv berhasil dibuat" || { fail "Gagal membuat .venv"; abort; }
fi

step "Aktivasi .venv"
source "$VENV_DIR/bin/activate"
ok "Virtual environment aktif: ${BLD}${VIRTUAL_ENV}${RST}"

step "Upgrade pip"
python -m pip install --upgrade pip -q 2>/dev/null && ok "pip ter-upgrade" || warn "Upgrade pip gagal"

req="/usr/local/bin/requirements.txt"

step "Install requirements"
if [ -f "$req" ]; then
    python -m pip install -r "$req" -q 2>/dev/null && ok "Requirements terinstall" || warn "Gagal install requirements"
else
    info "requirements.txt tidak ditemukan (dilewati)"
fi

# ══════════════════════════════════════════════════════════════
# 9. RINGKASAN ENVIRONMENT
# ══════════════════════════════════════════════════════════════
header "RINGKASAN"

sep
info "🐍 Python    : ${BLD}$(python --version 2>&1)${RST}"
info "📦 pip       : ${BLD}$(python -m pip --version 2>&1 | awk '{print $1, $2}')${RST}"
info "📂 Lokasi    : ${BLD}$(which python)${RST}"
info "📁 .venv     : ${BLD}${VIRTUAL_ENV}${RST}"
sep

# ══════════════════════════════════════════════════════════════
# SELESAI
# ══════════════════════════════════════════════════════════════
echo
echo -e "  ${GRN}${BLD}✔ Setup selesai!${RST}"
echo

if [ "$SCRIPT_IS_SOURCED" -eq 1 ]; then
    # Di-source → .venv aktif langsung di shell yang sedang berjalan
    source "$VENV_DIR/bin/activate"
    echo -e "  ${GRN}✔${RST} ${BLD}.venv AKTIF di shell ini sekarang!${RST}"
    echo
    echo -e "  ${DIM}Python sekarang  :${RST} ${BLD}$(which python)${RST}"
    echo -e "  ${DIM}Untuk keluar     :${RST} ${BLD}deactivate${RST}"
    echo
else
    echo -e "  ${YLW}⚠${RST} Script dijalankan dengan ${BLD}bash${RST}, jadi .venv ${YLW}tidak ikut aktif${RST} di shell Anda."
    echo
    echo -e "  ${DIM}Supaya langsung aktif, jalankan lain kali dengan:${RST}"
    echo -e "  ${BLD}    source setup-python.sh${RST}"
    echo
    echo -e "  ${DIM}Atau aktifkan sekarang:${RST}"
    echo -e "  ${BLD}    source .venv/bin/activate${RST}"
    echo
fi

# ── Pulihkan status asli set -e agar tidak menular ke shell ──
if [ "$SCRIPT_IS_SOURCED" -eq 1 ] && [ "$ERREXIT_WAS_SET" -eq 1 ]; then
    set -e
fi

# Selesai dengan sukses
[ "$SCRIPT_IS_SOURCED" -eq 1 ] && return 0
exit 0