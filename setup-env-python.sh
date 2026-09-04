#!/usr/bin/env bash

# =============================================================================
# Python Environment Setup Script
# Deskripsi: Mengecek & install Python/pip, buat venv, install libraries
# =============================================================================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Fungsi logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "\n${BOLD}${CYAN}================================================${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}================================================${NC}\n"
}

# =============================================================================
# STEP 1: Cek apakah Python terinstall
# =============================================================================
check_python() {
    log_header "STEP 1: Mengecek Python"

    local python_version=""
    local python_cmd=""

    # Cek python3 terlebih dahulu (standar Ubuntu)
    if command -v python3 &> /dev/null; then
        python_version=$(python3 --version 2>&1)
        python_cmd="python3"
        log_success "Python ditemukan: $python_version"
        return 0
    fi

    # Cek python (jika ada symlink)
    if command -v python &> /dev/null; then
        python_version=$(python --version 2>&1)
        python_cmd="python"
        log_success "Python ditemukan: $python_version"
        return 0
    fi

    log_error "Python TIDAK terdeteksi di sistem!"
    return 1
}

# =============================================================================
# STEP 2: Cek apakah pip terinstall
# =============================================================================
check_pip() {
    log_header "STEP 2: Mengecek Pip"

    if command -v pip3 &> /dev/null; then
        local pip_version=$(pip3 --version 2>&1)
        log_success "Pip ditemukan: $pip_version"
        return 0
    fi

    if command -v pip &> /dev/null; then
        local pip_version=$(pip --version 2>&1)
        log_success "Pip ditemukan: $pip_version"
        return 0
    fi

    log_error "Pip TIDAK terdeteksi di sistem!"
    return 1
}

# =============================================================================
# STEP 3: Install Python dan komponen wajib jika belum ada
# =============================================================================
install_python() {
    log_header "STEP 3: Menginstall Python dan Komponen Wajib"

    log_warn "Python atau pip belum terpasang. Mulai instalasi..."

    # Update package list
    log_info "Updating package lists..."
    sudo apt-get update -y

    # Install python3, pip, dan komponen penting
    log_info "Installing python3, python3-pip, dan komponen wajib..."
    sudo apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        build-essential \
        libffi-dev \
        libssl-dev \
        zlib1g-dev \
        uuid-dev \
        igraph-dev \
        pkg-config \
        gcc \
        g++ \
        make

    # Verifikasi instalasi
    echo ""
    if check_python && check_pip; then
        log_success "Python dan pip berhasil diinstall!"
    else
        log_error "Gagal menginstall Python atau pip. Silakan install manual."
        exit 1
    fi
}

# =============================================================================
# STEP 4: Pastikan python3-venv tersedia
# =============================================================================
check_venv_module() {
    log_header "STEP 4: Mengecek Modul venv"

    if python3 -c "import venv" 2>/dev/null; then
        log_success "Modul venv tersedia"
        return 0
    fi

    log_warn "Modul venv tidak ditemukan. Menginstall python3-venv..."
    sudo apt-get install -y python3-venv

    if python3 -c "import venv" 2>/dev/null; then
        log_success "Modul venv berhasil diinstall"
        return 0
    else
        log_error "Gagal menginstall modul venv"
        exit 1
    fi
}

# =============================================================================
# MENU UTAMA - Interaktif Menu System
# =============================================================================

show_menu() {
    echo ""
    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║   PYTHON ENVIRONMENT MANAGER                      ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e " ${BOLD}PILIHAN:${NC}"
    echo -e "   ${GREEN}1${NC} - Setup Environment Python (check/install python, pip, venv, libs)"
    echo -e "   ${GREEN}2${NC} - Install libraries dari requirements.txt"
    echo -e "   ${GREEN}3${NC} - Freeze library yang terinstall ke requirements.txt"
    echo -e "   ${GREEN}4${NC} - Aktifkan environment .venv"
    echo -e "   ${GREEN}5${NC} - Nonaktifkan/deaktiv environment .venv"
    echo -e "   ${GREEN}6${NC} - PIP Manager (list & show package info)"
    echo -e "   ${RED}X${NC} - Keluar"
    echo ""
}

# Fungsi untuk cek apakah .venv ada
check_venv_exists() {
    if [ -d ".venv" ] && [ -f ".venv/bin/activate" ]; then
        return 0
    else
        return 1
    fi
}

# Fungsi untuk cek apakah environment aktif
check_venv_active() {
    if [ -n "$VIRTUAL_ENV" ]; then
        return 0
    else
        return 1
    fi
}

# --- MENU 1: Setup Environment Python ---
menu_setup_env() {
    log_header "MENU 1: Setup Environment Python"

    # Cek Python
    if check_python; then
        log_success "Python sudah terpasang di sistem"
    else
        install_python
    fi

    # Cek Pip
    if check_pip; then
        log_success "Pip sudah terpasang di sistem"
    else
        install_python
    fi

    # Cek venv module
    check_venv_module

    # Input Path untuk Environment
    echo ""
    read -p "Masukkan path untuk membuat environment [.]: " env_path

    # Default ke current directory jika kosong
    if [ -z "$env_path" ]; then
        env_path="."
    fi

    # Resolve path absolut
    if [[ "$env_path" != /* ]]; then
        env_path="$(pwd)/$env_path"
    fi

    # Pastikan path ada
    if [ ! -d "$env_path" ]; then
        log_warn "Path '$env_path' tidak ada. Membuat direktori..."
        mkdir -p "$env_path"
    fi

    venv_name=".venv"
    venv_path="$env_path/$venv_name"

    log_info "Environment akan dibuat di: $venv_path"
    read -p "Konfirmasi? (y/n): " confirm

    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        log_warn "Setup dibatalkan oleh user"
        return 1
    fi

    # Buat virtual environment
    log_info "Membuat virtual environment..."
    python3 -m venv "$venv_path"

    if [ $? -eq 0 ]; then
        log_success "Virtual environment berhasil dibuat di: $venv_path"
    else
        log_error "Gagal membuat virtual environment"
        return 1
    fi

    # Install Libraries dari requirements.txt
    echo ""
    log_header "Install Libraries"

    # Cari requirements.txt
    req_file=""
    if [ -f "$env_path/requirements.txt" ]; then
        req_file="$env_path/requirements.txt"
    elif [ -f "./requirements.txt" ]; then
        req_file="./requirements.txt"
    fi

    if [ -n "$req_file" ]; then
        read -p "Apakah ingin install library dari requirements.txt? ($req_file) [Y/n]: " install_req
    else
        echo ""
        log_warn "requirements.txt tidak ditemukan"
        read -p "Apakah ingin install library dari requirements.txt? (masukkan path file atau 'n' untuk skip) [n]: " install_req
    fi

    if [ "$install_req" = "y" ] || [ "$install_req" = "Y" ]; then
        # Gunakan requirements.txt dari path yang sama dengan venv atau current dir
        if [ -f "$env_path/requirements.txt" ]; then
            req_file="$env_path/requirements.txt"
        elif [ -f "./requirements.txt" ]; then
            req_file="./requirements.txt"
        fi

        if [ -f "$req_file" ]; then
            log_info "Menginstall libraries dari: $req_file"
            log_info "Ini mungkin memakan waktu beberapa menit..."
            
            # Upgrade pip dulu
            "$venv_path/bin/pip" install --upgrade pip
            
            # Install requirements
            "$venv_path/bin/pip" install -r "$req_file"

            if [ $? -eq 0 ]; then
                log_success "Semua libraries berhasil diinstall!"
            else
                log_error "Beberapa library gagal diinstall. Cek error di atas."
            fi
        else
            log_warn "File requirements.txt tidak ditemukan"
        fi
    else
        log_info "Skip install libraries"
    fi

    log_success "Environment setup selesai!"
    echo ""
    echo -e "  ${BOLD}Path:${NC} $venv_path"
    echo -e "  ${BOLD}Activate:${NC} source $venv_path/bin/activate"
    echo ""
}

# --- MENU 2: Install Requirements ---
menu_install_requirements() {
    log_header "MENU 2: Install Libraries dari requirements.txt"

    # Cek apakah .venv ada
    if ! check_venv_exists; then
        log_error "Environment .venv tidak ditemukan! Jalankan Menu 1 dulu."
        return 1
    fi

    # Cari requirements.txt
    req_file=""
    if [ -f "requirements.txt" ]; then
        req_file="requirements.txt"
    else
        log_error "requirements.txt tidak ditemukan di direktori ini!"
        return 1
    fi

    log_info "Menggunakan file: $req_file"
    log_info "Menginstall libraries..."
    
    # Upgrade pip dulu
    .venv/bin/pip install --upgrade pip
    
    # Install requirements
    .venv/bin/pip install -r "$req_file"

    if [ $? -eq 0 ]; then
        log_success "Semua libraries berhasil diinstall!"
    else
        log_error "Beberapa library gagal diinstall. Cek error di atas."
    fi
    echo ""
}

# --- MENU 3: Freeze Libraries ---
menu_freeze_libraries() {
    log_header "MENU 3: Freeze Libraries ke requirements.txt"

    # Cek apakah .venv ada
    if ! check_venv_exists; then
        log_error "Environment .venv tidak ditemukan! Jalankan Menu 1 dulu."
        return 1
    fi

    # Cek apakah environment aktif
    if check_venv_active; then
        log_info "Environment sedang aktif"
        freeze_cmd="pip freeze"
    else
        log_info "Environment tidak aktif, menggunakan command langsung"
        freeze_cmd=".venv/bin/pip freeze"
    fi

    # Output file
    read -p "Nama file output [requirements.txt]: " output_file
    
    if [ -z "$output_file" ]; then
        output_file="requirements.txt"
    fi

    log_info "Mengeksport libraries ke: $output_file"
    
    # Freeze libraries
    $freeze_cmd > "$output_file"

    if [ $? -eq 0 ]; then
        local count=$(wc -l < "$output_file")
        log_success "Berhasil freeze $count libraries ke $output_file!"
        echo ""
        log_info "Isi file:"
        cat "$output_file"
    else
        log_error "Gagal freeze libraries"
    fi
    echo ""
}

# --- MENU 4: Activate Environment ---
menu_activate_venv() {
    log_header "MENU 4: Aktifkan Environment .venv"

    # Cek apakah .venv ada
    if ! check_venv_exists; then
        log_error "Environment .venv tidak ditemukan! Jalankan Menu 1 dulu."
        return 1
    fi

    # Cek apakah sudah aktif
    if check_venv_active; then
        log_warn "Environment sudah aktif!"
        echo -e "  Path: ${CYAN}$VIRTUAL_ENV${NC}"
        return 0
    fi

    log_info "Command untuk activate:"
    echo ""
    echo -e "  ${GREEN}source .venv/bin/activate${NC}"
    echo ""
    log_warn "Note: Activation hanya berlaku untuk shell/session terminal saat ini."
    echo ""
    log_info "Setelah activate, kamu akan melihat prefix (.venv) di terminal:"
    echo -e "  ${CYAN}(.venv) user@machine:~/path$${NC}"
    echo ""
    
    # Tanya apakah ingin membuka shell baru dengan activate
    read -p "Buka shell baru dengan environment aktif? (y/n): " open_shell
    
    if [ "$open_shell" = "y" ] || [ "$open_shell" = "Y" ]; then
        log_info "Membuka shell baru dengan environment aktif..."
        bash --rcfile <(echo ". .venv/bin/activate && echo 'Environment .venv aktif!'")
    fi
    
    echo ""
}

# --- MENU 5: Deactivate Environment ---
menu_deactivate_venv() {
    log_header "MENU 5: Nonaktifkan Environment .venv"

    # Cek apakah environment aktif
    if ! check_venv_active; then
        log_warn "Environment tidak aktif saat ini"
        echo ""
        log_info "Tidak ada environment yang perlu dinonaktifkan."
        return 0
    fi

    log_info "Environment saat ini aktif:"
    echo -e "  Path: ${CYAN}$VIRTUAL_ENV${NC}"
    echo ""
    
    read -p "Nonaktifkan environment? (y/n): " confirm_deactivate
    
    if [ "$confirm_deactivate" = "y" ] || [ "$confirm_deactivate" = "Y" ]; then
        log_info "Menonaktifkan environment..."
        deactivate
        
        if [ $? -eq 0 ]; then
            log_success "Environment berhasil dinonaktifkan!"
        else
            log_warn "Gagal menonaktifkan. Coba jalankan 'deactivate' manual."
        fi
    else
        log_info "Batal menonaktifkan environment"
    fi
    echo ""
}

manager_pip() {
    log_header "PYTHON ENVIRONMENT MANAGER - PIP MANAGER"
    echo ""
    pip list
    echo ""
    read -p "$(echo -e "  ${BOLD}Masukan nama package untuk melihat informasi lebih lanjut:${NC}") " package_name
    pip show "$package_name"
    echo ""
}

# =============================================================================
# MAIN LOOP - Interactive Menu
# =============================================================================

while true; do
    show_menu
    read -p "Pilih menu (1-6/X): " choice
    
    case $choice in
        1)
            menu_setup_env
            ;;
        2)
            menu_install_requirements
            ;;
        3)
            menu_freeze_libraries
            ;;
        4)
            menu_activate_venv
            ;;
        5)
            menu_deactivate_venv
            ;;
        6) 
            manager_pip
            ;;
        [xX])
            echo ""
            log_success "Terima kasih telah menggunakan Python Environment Manager!"
            echo -e "${CYAN}Selamat bekerja!${NC}"
            echo ""
            exit 0
            ;;
        *)
            log_error "Pilihan tidak valid! Masukkan 1-6 atau X untuk keluar."
            ;;
    esac
    
    # Pause sebelum kembali ke menu
    read -p "Tekan Enter untuk kembali ke menu..."
done

