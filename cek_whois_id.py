#!/usr/local/bin/.venv/bin/python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
========================================================================
 CEK WHOIS DOMAIN .ID (PANDI)
========================================================================
Script ini mengecek apakah sebuah domain .id / .co.id / .my.id / dll
sudah terdaftar (registered) atau masih tersedia, dengan menampilkan
detail seperti Registrar, Tanggal Dibuat, Status, Name Server, dll.

Cara kerja:
1. Query LANGSUNG ke server WHOIS resmi (whois.id) via protokol WHOIS
   (port 43) -> ini sumber data paling akurat & stabil, sama dengan
   yang dipakai oleh pandi.id.
2. Sebagai pelengkap, script juga mencoba scraping halaman
   https://pandi.id/whois/<domain> memakai requests + BeautifulSoup.
   CATATAN: halaman pandi.id di-render pakai JavaScript (Nuxt/Vue),
   jadi hasil scraping HTML mentah SERINGKALI KOSONG. Karena itu hasil
   utama tetap diambil dari query WHOIS langsung (poin 1).

Instalasi paket yang dibutuhkan:
    pip install requests beautifulsoup4 colorama

Cara pakai:
    python cek_whois_id.py
========================================================================
"""

import importlib.util
import os
from pathlib import Path
import re
import socket
import subprocess
import sys
from datetime import datetime


REQUIRED_PACKAGES = {
    "requests": "requests",
    "bs4": "beautifulsoup4",
    "colorama": "colorama",
}


def ensure_dependencies() -> None:
    """Siapkan .venv dan install dependensi yang belum tersedia."""
    missing = [
        package
        for module, package in REQUIRED_PACKAGES.items()
        if importlib.util.find_spec(module) is None
    ]
    if not missing:
        return

    script_dir = Path(__file__).resolve().parent
    setup_script = script_dir / "setup-python"
    venv_python = script_dir / ".venv" / "bin" / "python"

    if not setup_script.is_file():
        print(f"File setup tidak ditemukan: {setup_script}")
        sys.exit(1)

    print("Dependensi Python belum lengkap: " + ", ".join(missing))
    print("Menyiapkan dan mengaktifkan environment .venv...")

    try:
        subprocess.run(
            ["bash", "-c", 'source "$1"', "bash", str(setup_script)],
            cwd=script_dir,
            check=True,
        )
        subprocess.run(
            [str(venv_python), "-m", "pip", "install", *missing],
            cwd=script_dir,
            check=True,
        )
    except (OSError, subprocess.CalledProcessError) as exc:
        print(f"Gagal menyiapkan dependensi Python: {exc}")
        sys.exit(1)

    # Jalankan ulang script menggunakan interpreter dari .venv.
    if Path(sys.executable).resolve() != venv_python.resolve():
        os.execv(str(venv_python), [str(venv_python), *sys.argv])


ensure_dependencies()

try:
    import requests
    from bs4 import BeautifulSoup
    from colorama import init, Fore, Back, Style
except ImportError:
    print("Paket masih belum dapat dimuat setelah instalasi otomatis.")
    sys.exit(1)

# Inisialisasi colorama (biar warna jalan juga di Windows CMD)
init(autoreset=True)

WHOIS_SERVER = "whois.id"
WHOIS_PORT = 43
SOCKET_TIMEOUT = 10  # detik


# ----------------------------------------------------------------------
# BAGIAN 1: QUERY LANGSUNG KE SERVER WHOIS (SUMBER UTAMA & AKURAT)
# ----------------------------------------------------------------------
def query_whois_protocol(domain: str) -> str:
    """
    Mengirim query mentah ke server whois.id via socket (port 43),
    persis seperti cara kerja perintah `whois <domain>` di terminal.
    """
    try:
        with socket.create_connection((WHOIS_SERVER, WHOIS_PORT), timeout=SOCKET_TIMEOUT) as sock:
            query = f"{domain}\r\n".encode("utf-8")
            sock.sendall(query)

            response = b""
            while True:
                chunk = sock.recv(4096)
                if not chunk:
                    break
                response += chunk

            return response.decode("utf-8", errors="ignore")
    except socket.timeout:
        raise TimeoutError(
            f"Koneksi ke {WHOIS_SERVER} timeout setelah {SOCKET_TIMEOUT} detik.")
    except socket.gaierror:
        raise ConnectionError(
            f"Tidak bisa resolve host {WHOIS_SERVER}. Cek koneksi internet kamu.")
    except OSError as e:
        raise ConnectionError(f"Gagal konek ke server WHOIS: {e}")


def parse_whois_raw(raw_text: str) -> dict:
    """
    Parse teks mentah WHOIS jadi dictionary field-field penting.
    Field 'Name Server' dan 'Domain Status' bisa muncul lebih dari
    sekali, jadi ditampung dalam list.
    """
    data = {
        "Domain Name": None,
        "Registry Domain ID": None,
        "Registrar": None,
        "Registrar IANA ID": None,
        "Registrar URL": None,
        "Registrar Abuse Contact Email": None,
        "Registrar Abuse Contact Phone": None,
        "Creation Date": None,
        "Updated Date": None,
        "Registry Expiry Date": None,
        "DNSSEC": None,
        "Domain Status": [],
        "Name Server": [],
    }

    field_map = {
        "Domain Name": "Domain Name",
        "Registry Domain ID": "Registry Domain ID",
        "Registrar": "Registrar",
        "Registrar IANA ID": "Registrar IANA ID",
        "Registrar URL": "Registrar URL",
        "Registrar Abuse Contact Email": "Registrar Abuse Contact Email",
        "Registrar Abuse Contact Phone": "Registrar Abuse Contact Phone",
        "Creation Date": "Creation Date",
        "Updated Date": "Updated Date",
        "Registry Expiry Date": "Registry Expiry Date",
        "DNSSEC": "DNSSEC",
    }

    for line in raw_text.splitlines():
        line = line.strip()
        if not line or line.startswith("%") or line.startswith(">>>"):
            continue

        if ":" not in line:
            continue

        key, _, value = line.partition(":")
        key = key.strip()
        value = value.strip()

        if key == "Domain Status":
            data["Domain Status"].append(value)
        elif key == "Name Server":
            data["Name Server"].append(value)
        elif key in field_map and not data[field_map[key]]:
            data[field_map[key]] = value

    return data


def domain_is_registered(raw_text: str) -> bool:
    """Deteksi apakah domain terdaftar berdasarkan isi respons WHOIS."""
    not_found_markers = [
        "No match for",
        "NOT FOUND",
        "No Data Found",
        "Status: available",
        "Domain not found",
    ]
    lower_text = raw_text.lower()
    for marker in not_found_markers:
        if marker.lower() in lower_text:
            return False
    return "Domain Name:" in raw_text or "domain name:" in lower_text


# ----------------------------------------------------------------------
# BAGIAN 2: SCRAPING HALAMAN PANDI.ID (PELENGKAP / FALLBACK)
# ----------------------------------------------------------------------
def scrape_pandi_page(domain: str) -> dict:
    """
    Mencoba scraping https://pandi.id/whois/<domain>.
    Halaman ini React/Vue render, jadi kalau tabel tidak ketemu di HTML
    mentah, fungsi ini akan mengembalikan dict kosong (tidak error) —
    itu sudah normal dan diharapkan.
    """
    url = f"https://pandi.id/whois/{domain}"
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/124.0 Safari/537.36"
        )
    }

    result = {}
    try:
        resp = requests.get(url, headers=headers, timeout=SOCKET_TIMEOUT)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "html.parser")

        table = soup.find("table")
        if table:
            for row in table.find_all("tr"):
                cols = row.find_all(["th", "td"])
                if len(cols) == 2:
                    label = cols[0].get_text(strip=True)
                    value = cols[1].get_text(strip=True)
                    if label:
                        result[label] = value
    except requests.exceptions.RequestException:
        # Diam saja -> hasil scraping memang cuma pelengkap
        pass

    return result


# ----------------------------------------------------------------------
# BAGIAN 3: TAMPILAN TERMINAL (WARNA + EMOJI)
# ----------------------------------------------------------------------
def print_banner():
    print(Fore.CYAN + Style.BRIGHT + "=" * 62)
    print(Fore.CYAN + Style.BRIGHT +
          "   🔎  CEK WHOIS DOMAIN .ID — Powered by whois.id (PANDI)")
    print(Fore.CYAN + Style.BRIGHT + "=" * 62 + Style.RESET_ALL)


def print_line(label: str, value: str, emoji: str = "•"):
    print(
        f"{Fore.YELLOW}{emoji} {label:<28}{Style.RESET_ALL}: "
        f"{Fore.WHITE}{Style.BRIGHT}{value}{Style.RESET_ALL}"
    )


def tampilkan_hasil(domain: str, data: dict, raw_text: str):
    terdaftar = domain_is_registered(raw_text)

    print()
    if terdaftar:
        print(Back.GREEN + Fore.BLACK + Style.BRIGHT +
              f"  ✅  DOMAIN '{domain}' SUDAH TERDAFTAR / TERPAKAI  " +
              Style.RESET_ALL)
    else:
        print(Back.RED + Fore.WHITE + Style.BRIGHT +
              f"  ❌  DOMAIN '{domain}' BELUM TERDAFTAR / TERSEDIA  " +
              Style.RESET_ALL)
    print()

    if not terdaftar:
        print(Fore.GREEN + "🎉 Domain ini tampaknya masih tersedia untuk didaftarkan!")
        print(
            Fore.GREEN + "   Silakan cek & daftarkan lewat: https://pandi.id/search-domain")
        return

    print(Fore.MAGENTA + Style.BRIGHT +
          "📋 DETAIL INFORMASI DOMAIN" + Style.RESET_ALL)
    print(Fore.MAGENTA + "-" * 62)

    print_line("Nama Domain", data.get("Domain Name") or domain, "🌐")
    print_line("Registry Domain ID", data.get(
        "Registry Domain ID") or "-", "🆔")
    print_line("Sponsor Registrar", data.get("Registrar") or "-", "🏢")
    print_line("Registrar IANA ID", data.get("Registrar IANA ID") or "-", "🔢")
    print_line("Registrar URL", data.get("Registrar URL") or "-", "🔗")
    print_line("Abuse Contact Email", data.get(
        "Registrar Abuse Contact Email") or "-", "✉️ ")
    print_line("Abuse Contact Phone", data.get(
        "Registrar Abuse Contact Phone") or "-", "📞")
    print_line("Tanggal Dibuat", data.get("Creation Date") or "-", "📅")
    print_line("Terakhir Diperbarui", data.get("Updated Date") or "-", "🔄")
    print_line("Tanggal Kedaluwarsa", data.get(
        "Registry Expiry Date") or "-", "⏰")
    print_line("DNSSEC", data.get("DNSSEC") or "-", "🔒")

    if data.get("Domain Status"):
        print(f"{Fore.YELLOW}🚦 {'Status Domain':<28}{Style.RESET_ALL}:")
        for status in data["Domain Status"]:
            print(f"      {Fore.CYAN}↳ {status}{Style.RESET_ALL}")

    if data.get("Name Server"):
        print(f"{Fore.YELLOW}🖥️  {'Name Server':<27}{Style.RESET_ALL}:")
        for ns in data["Name Server"]:
            print(f"      {Fore.CYAN}↳ {ns}{Style.RESET_ALL}")

    print(Fore.MAGENTA + "-" * 62)
    print(Fore.LIGHTBLACK_EX +
          f"ℹ️  Sumber data: protokol WHOIS resmi ({WHOIS_SERVER}) — "
          f"real-time per {datetime.now().strftime('%d-%m-%Y %H:%M:%S')}")


def tampilkan_data_scraping_tambahan(scraped: dict):
    """Kalau kebetulan scraping HTML pandi.id berhasil dapat data, tampilkan juga."""
    if not scraped:
        return
    print()
    print(Fore.BLUE + Style.BRIGHT +
          "🧩 Info tambahan hasil scraping halaman pandi.id:")
    print(Fore.BLUE + "-" * 62)
    for k, v in scraped.items():
        print_line(k, v, "▫️")


# ----------------------------------------------------------------------
# BAGIAN 4: VALIDASI INPUT
# ----------------------------------------------------------------------
def validasi_domain(domain: str) -> bool:
    pola = r"^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9-]{1,63})+$"
    return re.match(pola, domain) is not None


# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------
def main():
    print_banner()
    print(Fore.WHITE + "\nMasukkan nama domain yang ingin dicek (contoh: gapesta.my.id)")
    domain = input(Fore.GREEN + "➡️  Domain: " +
                   Style.RESET_ALL).strip().lower()

    # Bersihkan input dari http://, https://, www., dan trailing slash
    domain = re.sub(r"^https?://", "", domain)
    domain = re.sub(r"^www\.", "", domain)
    domain = domain.rstrip("/")

    if not domain:
        print(Fore.RED + "⚠️  Domain tidak boleh kosong!")
        sys.exit(1)

    if not validasi_domain(domain):
        print(Fore.RED + f"⚠️  Format domain '{domain}' tidak valid!")
        sys.exit(1)

    print(Fore.CYAN +
          f"\n⏳ Mengecek domain '{domain}' ke server WHOIS ({WHOIS_SERVER})...")

    try:
        raw = query_whois_protocol(domain)
    except (TimeoutError, ConnectionError) as e:
        print(Fore.RED + f"❌ Gagal mengecek domain: {e}")
        sys.exit(1)

    data = parse_whois_raw(raw)
    tampilkan_hasil(domain, data, raw)

    # Coba scraping pandi.id sebagai pelengkap (boleh gagal diam-diam)
    scraped = scrape_pandi_page(domain)
    tampilkan_data_scraping_tambahan(scraped)

    print()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(Fore.RED + "\n\n🛑 Dibatalkan oleh pengguna.")
        sys.exit(0)
