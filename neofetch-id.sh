#!/bin/bash

set -e

echo "=== Neofetch Installer ==="

if command -v neofetch >/dev/null 2>&1; then
    echo "[+] Neofetch sudah terinstall."
else
    echo "[-] Neofetch belum terinstall."
    echo "[*] Menginstall neofetch..."

    if [ "$(id -u)" -ne 0 ]; then
        echo "[!] Script harus dijalankan sebagai root."
        echo "    Gunakan: sudo $0"
        exit 1
    fi

    apt update
    apt install -y neofetch

    echo "[+] Neofetch berhasil diinstall."
fi

echo
echo "[*] Menjalankan neofetch..."
echo
clear

neofetch
