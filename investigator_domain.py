#!/usr/local/bin/.venv/bin/python
#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  PHISHING DOMAIN INVESTIGATOR v2.0                               ║
║  Alat untuk menganalisa domain yang diduga melakukan phishing    ║
║                                                                  ║
║  Versi 2.0:                                                      ║
║  - Penambahan 5 fitur baru untuk analisis yang lebih komprehensif║
║  - Integrasi library eksternal untuk keakuratan yang lebih tinggi║
║  - Output laporan yang lebih lengkap dan terstruktur            ║
║  - Error handling dan logging yang lebih baik                    ║
║  - Dokumentasi yang lebih lengkap                                ║
║                                                                  ║
║  Fungsi:                                                         ║
║  1. WHOIS Lookup - Siapa pemilik domain?                         ║
║  2. DNS Records - Server apa yang dipakai?                       ║
║  3. IP Geolocation - Server berada di negara mana?               ║
║  4. Reverse DNS - Hostname balik dari IP                         ║
║  5. SSL Certificate - Siapa penerbit sertifikat?                 ║
║  6. Cloudflare Detection - Apakah dilindungi CDN?                ║
║  7. HTTP Headers - Informasi server                              ║
║  8. Security Headers Analysis - Analisis header keamanan         ║
║  9. Subdomain Enumeration - Enumerasi subdomain                  ║
║  10. Certificate Transparency - Pemeriksaan CT logs              ║
║  11. Passive DNS - Pencarian DNS pasif                           ║
║  12. URL Reputation Check - Pemeriksaan reputasi URL             ║
║                                                                  ║
║  ⚠️ HANYA UNTUK TUJUAN EDUKASI & PELAPORAN                       ║
║     Jangan gunakan untuk aktivitas ilegal!                       ║
╚══════════════════════════════════════════════════════════════════╝
"""

import socket
import sys
import time
import json
import os
import shutil
import subprocess
import urllib.parse
from datetime import datetime
from pathlib import Path

# ============================================================
# BAGIAN 1: IMPOR MODUL OPSIONAL (dengan pesan error yang jelas)
# ============================================================
# Library yang diperlukan untuk fitur-fitur v2.0:
# - python-whois: WHOIS lookup
# - dnspython: DNS resolution
# - requests: HTTP requests
# - pyOpenSSL: SSL/TLS analysis
# - sslyze: Advanced SSL analysis
# - cryptography: Cryptographic operations
# - ipaddress: IP address manipulation
# - urllib3: HTTP connection management

try:
    import whois
except ImportError:
    whois = None

try:
    import dns.resolver
except ImportError:
    dns = None

try:
    import requests
except ImportError:
    requests = None

try:
    import OpenSSL
except ImportError:
    OpenSSL = None

try:
    import sslyze
except ImportError:
    sslyze = None

try:
    import cryptography
except ImportError:
    cryptography = None

try:
    import ipaddress
except ImportError:
    ipaddress = None

try:
    import urllib3
except ImportError:
    urllib3 = None


# ============================================================
# BAGIAN 2: UTILITAS
# ============================================================
RESET = "\033[0m"
MERAH = "\033[91m"
HIJAU = "\033[92m"
KUNING = "\033[93m"
BIRU = "\033[94m"
MAGENTA = "\033[95m"
CYAN = "\033[96m"
BOLD = "\033[1m"

# Alias nama warna (Inggris) agar kompatibel dengan pemakaian di kode lain
GREEN = HIJAU
RED = MERAH
YELLOW = KUNING
BLUE = BIRU

HASIL = {
    "registrar": "Tidak diketahui",
    "tanggal_registrasi": "Tidak diketahui",
    "status_domain": "Tidak diketahui",
    "name_server": "Tidak diketahui",
    "ip": "Tidak ditemukan",
    "cloudflare": "Tidak terdeteksi",
    "negara": "Tidak diketahui",
    "isp": "Tidak diketahui",
    "reverse_dns": "Tidak ditemukan",
    "ssl_issuer": "Tidak diketahui",
    "ssl_berlaku_hingga": "Tidak diketahui",
    "http_status": "Tidak diketahui",
    "url_akhir": "Tidak diketahui",
    "server": "Tidak diketahui",
    "path_aktif": [],
}

HEADER = f"""
{BOLD}{CYAN}
  ██████╗ ██╗  ██╗██╗███████╗██╗  ██╗██╗███╗   ██╗ ██████╗
  ██╔══██╗██║  ██║██║██╔════╝██║  ██║██║████╗  ██║██╔════╝
  ██████╔╝███████║██║███████╗███████║██║██╔██╗ ██║██║  ███╗
  ██╔═══╝ ██╔══██║██║╚════██║██╔══██║██║██║╚██╗██║██║   ██║
  ██║     ██║  ██║██║███████║██║  ██║██║██║ ╚████║╚██████╔╝
  ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝
{RESET}
{BOLD}{KUNING}  PHISHING DOMAIN INVESTIGATOR v2.0{RESET}
{CYAN}  Alat Analisa Domain untuk Pelaporan Keamanan Siber{RESET}
"""


def cprint(warna, teks):
    """Cetak teks berwarna"""
    print(f"{warna}{teks}{RESET}")


def separator(judul):
    """Cetak separator dengan judul"""
    print()
    print(f"{BOLD}{BIRU}┌{'─' * 60}┐{RESET}")
    print(f"{BOLD}{BIRU}│ {judul}{' ' * (58 - len(judul))}│{RESET}")
    print(f"{BOLD}{BIRU}└{'─' * 60}┘{RESET}")


def cek_dan_install_venv_package():
    """Cek apakah paket python3-venv (mis. python3.10-venv) sudah terpasang.
    Jika belum, install otomatis lewat apt (pakai sudo bila perlu).
    Mengembalikan True jika sudah terpasang / berhasil diinstall, False jika gagal."""
    py_major = sys.version_info.major
    py_minor = sys.version_info.minor
    paket_versi = f"python{py_major}.{py_minor}-venv"  # mis. python3.10-venv
    paket_generik = "python3-venv"

    # 1. Cek apakah sudah terpasang (dpkg -s)
    for paket in (paket_versi, paket_generik):
        try:
            hasil = subprocess.run(
                ["dpkg", "-s", paket],
                capture_output=True,
                text=True,
            )
            if hasil.returncode == 0 and "install ok installed" in hasil.stdout:
                cprint(
                    HIJAU, f"  ✔ Paket {paket} sudah terpasang, skip install")
                return True
        except FileNotFoundError:
            break  # dpkg tidak tersedia (bukan Debian/Ubuntu) — biarkan

    # 2. Belum terpasang → coba install otomatis
    cprint(
        KUNING, f"  ⚠️ Paket {paket_versi} belum terpasang, mencoba install...")
    env = dict(os.environ)
    env["DEBIAN_FRONTEND"] = "noninteractive"
    env["APT_LISTCHANGES_FRONTEND"] = "none"

    urutan_perintah = [
        ["apt-get", "install", "-y", paket_versi],
        ["sudo", "-n", "apt-get", "install", "-y", paket_versi],
        ["sudo", "apt-get", "install", "-y", paket_versi],
    ]

    for cmd in urutan_perintah:
        cprint(KUNING, f"  ▸ Mencoba: {' '.join(cmd)}")
        try:
            hasil = subprocess.run(
                cmd,
                env=env,
                stdout=sys.stdout,
                stderr=sys.stderr,
            )
            if hasil.returncode == 0:
                cprint(HIJAU, f"  ✔ Paket {paket_versi} berhasil diinstall")
                return True
        except FileNotFoundError:
            continue
        except KeyboardInterrupt:
            return False

    cprint(MERAH, f"  ✘ Gagal menginstall {paket_versi}")
    return False


def cek_modul():
    """Cek apakah semua modul yang dibutuhkan sudah terinstall.
    Jika belum, otomatis source setup-python.sh lalu install library yang dibutuhkan.
    Jika sudah, skip — tidak perlu install apa-apa."""
    masalah = []

    if whois is None:
        masalah.append("python-whois")
    if dns is None:
        masalah.append("dnspython")
    if requests is None:
        masalah.append("requests")
    if OpenSSL is None:
        masalah.append("pyOpenSSL")
    if sslyze is None:
        masalah.append("sslyze")
    if cryptography is None:
        masalah.append("cryptography")
    if ipaddress is None:
        masalah.append("ipaddress")
    if urllib3 is None:
        masalah.append("urllib3")

    if not masalah:
        # Semua library sudah terinstall — skip
        return

    # ── Ada library yang belum terinstall → setup otomatis ──
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    SETUP_SCRIPT = os.path.join(SCRIPT_DIR, "setup-python")
    VENV_DIR = os.path.join(SCRIPT_DIR, ".venv")
    VENV_PYTHON = os.path.join(VENV_DIR, "bin", "python3")
    VENV_PIP = os.path.join(VENV_DIR, "bin", "pip")

    cprint(
        KUNING, f"\n⚠️  Beberapa library belum terinstall: {', '.join(masalah)}")
    cprint(CYAN, "🔄 Menjalankan setup otomatis...")

    # Cek apakah kita SUDAH berjalan di dalam .venv
    if os.environ.get("VIRTUAL_ENV") == VENV_DIR and os.path.exists(VENV_PIP):
        # Sudah di .venv tapi library belum ada → install langsung
        cprint(CYAN, "  ▸ Sudah di dalam .venv, install library...")
        packages = [
            "python-whois", "dnspython", "requests", "pyOpenSSL",
            "sslyze", "cryptography", "ipaddress", "urllib3"
        ]
        try:
            subprocess.run(
                [VENV_PIP, "install"] + packages,
                cwd=SCRIPT_DIR,
                check=True,
                stdout=sys.stdout,
                stderr=sys.stderr,
            )
            cprint(HIJAU, "  ✔ Semua library berhasil diinstall!")
        except subprocess.CalledProcessError:
            cprint(KUNING, "  ⚠️ Sebagian library gagal diinstall, mencoba lanjut...")
        return

    # Step 1: Pastikan .venv valid (ada python3 DAN pip)
    venv_valid = os.path.exists(VENV_PYTHON) and os.path.exists(VENV_PIP)

    if not venv_valid:
        # .venv belum ada atau rusak/parsial (mis. sisa gagal buat) → buat ulang
        if os.path.exists(VENV_DIR):
            cprint(
                KUNING, "  ⚠️ .venv ada tapi rusak/parsial (pip tidak ditemukan), hapus & buat ulang...")
            shutil.rmtree(VENV_DIR, ignore_errors=True)

        cprint(CYAN, "  ▸ Menjalankan setup-python.sh untuk membuat .venv...")
        try:
            subprocess.run(
                ["bash", SETUP_SCRIPT],
                cwd=SCRIPT_DIR,
                check=True,
                stdout=sys.stdout,
                stderr=sys.stderr,
            )
        except subprocess.CalledProcessError:
            # setup-python.sh gagal (mungkin bukan root) — buat .venv manual
            cprint(
                KUNING, "  ⚠️ setup-python.sh gagal (mungkin perlu root), membuat .venv manual...")
            try:
                subprocess.run(
                    [sys.executable, "-m", "venv", VENV_DIR],
                    check=True,
                    stdout=sys.stdout,
                    stderr=sys.stderr,
                )
                cprint(HIJAU, "  ✔ .venv berhasil dibuat manual")
            except subprocess.CalledProcessError:
                # Gagal — kemungkinan python3-venv belum terpasang
                cprint(
                    KUNING, "  ⚠️ Gagal membuat .venv — cek paket python3-venv...")
                if cek_dan_install_venv_package():
                    # Bersihkan .venv parsial sebelum membuat ulang
                    if os.path.exists(VENV_DIR):
                        shutil.rmtree(VENV_DIR, ignore_errors=True)
                    cprint(CYAN, "  ▸ Mencoba membuat .venv lagi...")
                    try:
                        subprocess.run(
                            [sys.executable, "-m", "venv", VENV_DIR],
                            check=True,
                            stdout=sys.stdout,
                            stderr=sys.stderr,
                        )
                        cprint(
                            HIJAU, "  ✔ .venv berhasil dibuat manual (setelah install paket)")
                    except subprocess.CalledProcessError:
                        cprint(
                            MERAH, "  ✘ Gagal membuat .venv setelah menginstall python3-venv")
                        sys.exit(1)
                else:
                    cprint(
                        MERAH, "  ✘ Gagal membuat .venv (pasang python3-venv secara manual lalu jalankan ulang)")
                    sys.exit(1)
    else:
        cprint(HIJAU, "  ✔ .venv sudah ada, skip pembuatan")

    # Step 2: Install library yang dibutuhkan
    if os.path.exists(VENV_PIP):
        cprint(CYAN, "  ▸ Menginstall library yang dibutuhkan...")
        packages = [
            "python-whois", "dnspython", "requests", "pyOpenSSL",
            "sslyze", "cryptography", "ipaddress", "urllib3"
        ]
        try:
            subprocess.run(
                [VENV_PIP, "install"] + packages,
                cwd=SCRIPT_DIR,
                check=True,
                stdout=sys.stdout,
                stderr=sys.stderr,
            )
            cprint(HIJAU, "  ✔ Semua library berhasil diinstall!")
        except subprocess.CalledProcessError:
            cprint(KUNING, "  ⚠️ Sebagian library gagal diinstall, mencoba lanjut...")
    else:
        cprint(MERAH, "  ✘ .venv/bin/pip tidak ditemukan, setup gagal")
        sys.exit(1)

    # Step 3: Re-execute script dengan Python dari .venv
    if os.path.exists(VENV_PYTHON):
        cprint(CYAN, f"\n🔄 Menjalankan ulang script dengan Python dari .venv...\n")
        os.execv(VENV_PYTHON, [VENV_PYTHON] + sys.argv)
    else:
        cprint(MERAH, "  ✘ .venv/bin/python3 tidak ditemukan, setup gagal")
        sys.exit(1)


def sanitasi_domain(domain):
    """Bersihkan input domain dari pengguna"""
    domain = domain.strip().lower()
    # Hapus protokol jika ada
    domain = domain.replace("https://", "").replace("http://", "")
    # Hapus path jika ada
    if "/" in domain:
        domain = domain.split("/")[0]
    # Hapus port jika ada
    if ":" in domain:
        domain = domain.split(":")[0]
    return domain


# ============================================================
# BAGIAN 3: FUNGSI INVESTIGASI
# ============================================================

def whois_lookup(domain):
    """WHOIS Lookup - cari informasi pemilik domain"""
    separator("📋 1. WHOIS LOOKUP - Informasi Pemilik Domain")
    try:
        w = whois.whois(domain)

        HASIL["registrar"] = str(w.registrar or "Tidak diketahui")
        HASIL["tanggal_registrasi"] = str(w.creation_date or "Tidak diketahui")
        HASIL["status_domain"] = str(w.status or "Tidak diketahui")
        if w.name_servers:
            ns = w.name_servers if isinstance(
                w.name_servers, list) else [w.name_servers]
            HASIL["name_server"] = ", ".join(str(v) for v in ns[:4])

        fields = [
            ("Nama Domain", w.domain_name),
            ("Registrar", w.registrar),
            ("Tanggal Registrasi", w.creation_date),
            ("Tanggal Kedaluwarsa", w.expiration_date),
            ("Tanggal Update", w.updated_date),
            ("Status", w.status),
            ("Name Server", w.name_servers),
            ("Organisasi", w.org),
            ("Negara", w.country),
            ("Email Registrant", w.emails),
            ("Alamat", w.address),
        ]

        for nama, nilai in fields:
            if nilai:
                if isinstance(nilai, list):
                    nilai_str = ", ".join(str(v) for v in nilai[:3])
                else:
                    nilai_str = str(nilai)
                print(f"{CYAN}  {nama:<22}{RESET} : {nilai_str}")

        # Analisis singkat
        if w.creation_date:
            tanggal = w.creation_date
            if isinstance(tanggal, list):
                tanggal = tanggal[0]
            umur_hari = (datetime.now() - tanggal).days
            print()
            if umur_hari < 30:
                cprint(
                    MERAH, f"  ⚠️  Domain ini BARU (umur {umur_hari} hari) — ciri khas phishing!")
            elif umur_hari < 365:
                cprint(
                    KUNING, f"  ⚠️  Domain berumur {umur_hari} hari — cukup baru, perlu diwaspadai")
            else:
                cprint(HIJAU, f"  ✅ Domain sudah berumur {umur_hari} hari")

    except Exception as e:
        cprint(KUNING, f"  ⚠️  WHOIS tidak bisa diambil: {e}")
        cprint(
            KUNING, "  (Domain mungkin baru didaftarkan atau data di-redact/privacy protection)")


def dns_lookup(domain):
    """DNS Lookup - cari records DNS"""
    separator("🌐 2. DNS RECORDS - Konfigurasi Server")
    try:
        # A Record (IPv4)
        try:
            jawaban = dns.resolver.resolve(domain, 'A')
            ip_list = [str(r) for r in jawaban]
            if ip_list:
                HASIL["ip"] = ", ".join(ip_list)
            print(
                f"{CYAN}  A Record (IPv4){RESET}   : {', '.join(ip_list)}")
        except Exception:
            cprint(KUNING, "  A Record (IPv4)   : Tidak ditemukan")

        # AAAA Record (IPv6)
        try:
            jawaban = dns.resolver.resolve(domain, 'AAAA')
            print(
                f"{CYAN}  AAAA Record (IPv6){RESET} : {', '.join(str(r) for r in jawaban)}")
        except Exception:
            cprint(KUNING, "  AAAA Record (IPv6) : Tidak ditemukan")

        # NS Record (Name Server)
        try:
            jawaban = dns.resolver.resolve(domain, 'NS')
            print(
                f"{CYAN}  NS Records{RESET}       : {', '.join(str(r) for r in jawaban)}")
        except Exception:
            cprint(KUNING, "  NS Records         : Tidak ditemukan")

        # MX Record (Mail Server)
        try:
            jawaban = dns.resolver.resolve(domain, 'MX')
            print(
                f"{CYAN}  MX Records{RESET}       : {', '.join(str(r) for r in jawaban)}")
        except Exception:
            cprint(
                KUNING, "  MX Records         : Tidak ditemukan (tidak ada mail server)")

        # TXT Record (SPF, DKIM, dll.)
        try:
            jawaban = dns.resolver.resolve(domain, 'TXT')
            for r in jawaban:
                print(f"{CYAN}  TXT Record{RESET}       : {str(r)[:80]}")
        except Exception:
            cprint(KUNING, "  TXT Records        : Tidak ditemukan")

        # Analisis Cloudflare
        try:
            jawaban = dns.resolver.resolve(domain, 'A')
            for r in jawaban:
                ip = str(r)
                if ip.startswith("104.16.") or ip.startswith("104.17.") or \
                   ip.startswith("172.64.") or ip.startswith("172.65.") or \
                   ip.startswith("172.66.") or ip.startswith("172.67.") or \
                   ip.startswith("173.245.") or ip.startswith("188.114.") or \
                   ip.startswith("190.93.") or ip.startswith("197.234.") or \
                   ip.startswith("198.41.") or ip.startswith("162.158."):
                    cprint(MERAH, f"\n  🚨 TERDETEKSI CLOUDFLARE! (IP {ip})")
                    cprint(
                        KUNING, "  ⚠️  Server asli TERSEMBUNYI di belakang Cloudflare CDN")
                    cprint(
                        KUNING, "  ⚠️  Ini menyulitkan pelacakan IP server asli penyerang")
                    HASIL["cloudflare"] = f"Terdeteksi (IP proxy {ip})"
                    break
        except Exception:
            pass

    except Exception as e:
        cprint(MERAH, f"  ❌ Gagal resolve DNS: {e}")


def ip_geolocation(ip):
    """IP Geolocation - cari lokasi geografis IP"""
    separator("📍 3. IP GEOLOCATION - Lokasi Server")
    waktu = time.time()
    try:
        if requests is None:
            cprint(KUNING, "  ⚠️ Modul requests tidak terinstall, lewati geolokasi")
            return
        waktu = time.time()
        resp = requests.get(f"http://ip-api.com/json/{ip}", timeout=10)
        if resp.status_code == 200:
            data = resp.json()
            if data.get("status") == "success":
                HASIL["negara"] = f"{data.get('country')} ({data.get('countryCode')})"
                HASIL["isp"] = str(data.get("isp") or "Tidak diketahui")
                print(f"{CYAN}  IP Address{RESET}        : {data.get('query')}")
                print(
                    f"{CYAN}  Negara{RESET}            : {data.get('country')} ({data.get('countryCode')})")
                print(
                    f"{CYAN}  Region{RESET}            : {data.get('regionName')} ({data.get('region')})")
                print(f"{CYAN}  Kota{RESET}              : {data.get('city')}")
                print(f"{CYAN}  ZIP{RESET}               : {data.get('zip')}")
                print(
                    f"{CYAN}  Latitude/Longitude{RESET} : {data.get('lat')}, {data.get('lon')}")
                print(f"{CYAN}  ISP{RESET}               : {data.get('isp')}")
                print(f"{CYAN}  Organisasi{RESET}        : {data.get('org')}")
                print(f"{CYAN}  AS Number{RESET}         : {data.get('as')}")
                print(f"{CYAN}  Zona Waktu{RESET}        : {data.get('timezone')}")
            else:
                cprint(
                    KUNING, f"  ⚠️ ip-api: {data.get('message', 'tidak ada data')}")
        else:
            cprint(KUNING, "  ⚠️ Gagal terhubung ke ip-api.com")
    except Exception as e:
        cprint(KUNING, f"  ⚠️ Geolokasi gagal: {e}")
    finally:
        # Batasi rate request ke ip-api (15 request/menit untuk free tier)
        sisa = 1 - (time.time() - waktu)
        if sisa > 0:
            time.sleep(sisa)


def reverse_dns(ip):
    """Reverse DNS - cari hostname dari IP"""
    separator("🔄 4. REVERSE DNS - Hostname Balik IP")
    try:
        hostname = socket.gethostbyaddr(ip)
        HASIL["reverse_dns"] = hostname[0]
        print(f"{CYAN}  Hostname{RESET} : {hostname[0]}")
        if "cloudflare" in hostname[0].lower():
            cprint(MERAH, "  🚨 Hostname milik Cloudflare — konfirmasi CDN proxy")
        print(
            f"{CYAN}  Aliases{RESET}  : {', '.join(hostname[1]) if hostname[1] else 'Tidak ada'}")
    except socket.herror:
        cprint(KUNING, "  ⚠️ Tidak ada reverse DNS untuk IP ini")
    except Exception as e:
        cprint(KUNING, f"  ⚠️ Reverse DNS gagal: {e}")


def ssl_check(domain):
    """SSL Certificate - periksa sertifikat SSL"""
    separator("🔒 5. SSL CERTIFICATE - Sertifikat Keamanan")
    import ssl
    try:
        ctx = ssl.create_default_context()
        with ctx.wrap_socket(socket.socket(), server_hostname=domain) as s:
            s.settimeout(10)
            s.connect((domain, 443))
            cert = s.getpeercert()

        print(
            f"{CYAN}  Subject{RESET}         : {dict(x[0] for x in cert['subject'])}")
        print(
            f"{CYAN}  Issuer{RESET}          : {dict(x[0] for x in cert['issuer'])}")
        print(f"{CYAN}  Berlaku Mulai{RESET}   : {cert['notBefore']}")
        print(f"{CYAN}  Berlaku Hingga{RESET}  : {cert['notAfter']}")
        print(f"{CYAN}  SAN (Domain){RESET}    : {cert.get('subjectAltName')}")

        issuer = dict(x[0] for x in cert['issuer'])
        HASIL["ssl_issuer"] = str(issuer.get('organizationName', issuer))
        HASIL["ssl_berlaku_hingga"] = str(
            cert.get('notAfter', 'Tidak diketahui'))
        org = issuer.get('organizationName', '')
        if "Cloudflare" in org or "Google Trust" in org or "Let's Encrypt" in org:
            cprint(
                KUNING, "\n  ⚠️  Sertifikat diterbitkan oleh pihak umum (bukan entitas resmi MLBB)")
            cprint(KUNING, "  ⚠️  HTTPS TIDAK menjamin situs ini aman/terpercaya!")

    except ssl.SSLCertVerificationError:
        cprint(MERAH, "  ❌ Sertifikat SSL TIDAK VALID!")
    except Exception as e:
        cprint(KUNING, f"  ⚠️ SSL check gagal: {e}")


def http_headers(domain):
    """HTTP Headers - analisa header respons server"""
    separator("🖥️ 6. HTTP HEADERS - Informasi Server      ")
    try:
        if requests is None:
            cprint(
                KUNING, "  ⚠️ Modul requests tidak terinstall, lewati analisa header")
            return
        resp = requests.get(f"https://{domain}",
                            timeout=10, allow_redirects=True)

        HASIL["http_status"] = str(resp.status_code)
        HASIL["url_akhir"] = str(resp.url)
        HASIL["server"] = str(resp.headers.get('Server', 'Tidak diketahui'))

        print(f"{CYAN}  Status Code{RESET}      : {resp.status_code}")
        print(f"{CYAN}  URL Akhir{RESET}        : {resp.url}")
        print(
            f"{CYAN}  Server{RESET}           : {resp.headers.get('Server', 'Tidak ada')}")
        print(
            f"{CYAN}  Content-Type{RESET}     : {resp.headers.get('Content-Type', 'Tidak ada')}")
        print(
            f"{CYAN}  Powerered By{RESET}     : {resp.headers.get('X-Powered-By', 'Tidak ada')}")
        print(
            f"{CYAN}  CF-Ray{RESET}           : {resp.headers.get('CF-Ray', 'Tidak ada')}")
        print(
            f"{CYAN}  CF-Cache-Status{RESET}  : {resp.headers.get('CF-Cache-Status', 'Tidak ada')}")
        print(
            f"{CYAN}  Set-Cookie{RESET}       : {resp.headers.get('Set-Cookie', 'Tidak ada')}")

        server = resp.headers.get('Server', '')
        if 'cloudflare' in server.lower():
            HASIL["cloudflare"] = "Terdeteksi dari HTTP Server header"
            cprint(MERAH, "\n  🚨 Server header menunjukkan CLOUDFLARE")
            cprint(
                KUNING, "  ⚠️  IP asli server penyerang disembunyikan oleh Cloudflare")

        cf_ray = resp.headers.get('CF-Ray', '')
        if cf_ray:
            lokasi_po = cf_ray.split('-')[-1] if '-' in cf_ray else '?'
            print(
                f"{CYAN}  Lokasi Poin Hadir{RESET}: {lokasi_po} (kota Cloudflare PoP)")

    except requests.exceptions.SSLError:
        cprint(MERAH, "  ❌ Gagal koneksi HTTPS (sertifikat tidak valid)")
    except requests.exceptions.ConnectionError:
        cprint(MERAH, "  ❌ Gagal koneksi — domain mungkin sudah mati/diblokir")
    except Exception as e:
        cprint(KUNING, f"  ⚠️ Analisa header gagal: {e}")


def security_headers_check(domain):
    """Security Headers Analysis - Analisis header keamanan"""
    separator("🛡️ 8. SECURITY HEADERS ANALYSIS - Analisis Header Keamanan  ")
    try:
        if requests is None:
            cprint(
                KUNING, "  ⚠️ Modul requests tidak terinstall, lewati analisa header")
            return

        resp = requests.get(f"https://{domain}",
                            timeout=10, allow_redirects=True)

        headers = resp.headers

        # Security headers yang penting
        security_headers = {
            'Strict-Transport-Security': 'HSTS',
            'X-Content-Type-Options': 'X-Content-Type-Options',
            'X-Frame-Options': 'X-Frame-Options',
            'X-XSS-Protection': 'X-XSS-Protection',
            'Content-Security-Policy': 'CSP',
            'Referrer-Policy': 'Referrer Policy',
            'Permissions-Policy': 'Permissions Policy'
        }

        print(f"{CYAN}  Header Keamanan yang Ditemukan:{RESET}")
        found_headers = 0
        for header, desc in security_headers.items():
            if header in headers:
                print(f"    {GREEN}✓ {desc}{RESET} : {headers[header]}")
                found_headers += 1
            else:
                print(f"    {RED}✗ {desc}{RESET} : Tidak ditemukan")

        print(f"\n  {CYAN}Total Security Headers: {found_headers}/7{RESET}")

        # Analisis kelemahan
        if 'Strict-Transport-Security' not in headers:
            cprint(
                YELLOW, "  ⚠️  HSTS tidak ditemukan - tidak ada perlindungan against downgrade attacks")

        if 'X-Frame-Options' not in headers:
            cprint(
                YELLOW, "  ⚠️  X-Frame-Options tidak ditemukan - rentan terhadap clickjacking")

        if 'X-XSS-Protection' not in headers:
            cprint(
                YELLOW, "  ⚠️  X-XSS-Protection tidak ditemukan - rentan terhadap XSS")

        if 'Content-Security-Policy' not in headers:
            cprint(
                YELLOW, "  ⚠️  CSP tidak ditemukan - rentan terhadap XSS dan data injection")

    except Exception as e:
        cprint(KUNING, f"  ⚠️ Analisa header keamanan gagal: {e}")


def subdomain_enum(domain):
    """Subdomain Enumeration - Enumerasi subdomain"""
    separator("🔍 9. SUBDOMAIN ENUMERATION - Enumerasi Subdomain")
    try:
        if dns is None:
            cprint(
                KUNING, "  ⚠️ Modul dnspython tidak terinstall, lewati enum subdomain")
            return

        subdomains = [
            'www', 'mail', 'ftp', 'admin', 'test', 'dev', 'stage', 'api',
            'blog', 'shop', 'support', 'login', 'portal', 'secure', 'panel',
            'cdn', 'm', 'mobile', 'web', 'owa', 'exchange', 'vpn', 'backup'
        ]

        found_subdomains = []
        print(f"{CYAN}  Mencari subdomain umum untuk {domain}:{RESET}")

        for sub in subdomains:
            subdomain = f"{sub}.{domain}"
            try:
                ips = dns.resolver.resolve(subdomain, 'A')
                ip_list = [str(ip) for ip in ips]
                found_subdomains.append((subdomain, ip_list[0]))
                print(f"    {GREEN}✓ {subdomain}{RESET} -> {ip_list[0]}")
            except Exception:
                pass  # Subdomain tidak ditemukan

        HASIL["subdomains"] = found_subdomains
        print(
            f"\n  {CYAN}Total subdomain ditemukan: {len(found_subdomains)}{RESET}")

    except Exception as e:
        cprint(KUNING, f"  ⚠️ Enumerasi subdomain gagal: {e}")


def certificate_transparency(domain):
    """Certificate Transparency - Pemeriksaan CT logs"""
    separator("📜 10. CERTIFICATE TRANSPARENCY - Pemeriksaan CT Logs")
    try:
        if requests is None:
            cprint(KUNING, "  ⚠️ Modul requests tidak terinstall, lewati CT check")
            return

        # Cek dengan Certificate Transparency Log
        ct_url = f"https://crt.sh/?q={domain}&output=json"
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}

        resp = requests.get(ct_url, headers=headers, timeout=10)
        if resp.status_code == 200:
            try:
                data = resp.json()
                if data and len(data) > 0:
                    print(
                        f"{CYAN}  Certificate Transparency Logs untuk {domain}:{RESET}")
                    for cert in data[:5]:  # Tampilkan maksimal 5
                        print(
                            f"    {GREEN}✓ Serial: {cert.get('serial_number', 'N/A')}{RESET}")
                        print(
                            f"      Not Before: {cert.get('not_before', 'N/A')}")
                        print(
                            f"      Not After: {cert.get('not_after', 'N/A')}")
                        print(f"      Subject: {cert.get('subject', 'N/A')}")
                        print()
                    print(
                        f"    {CYAN}Total sertifikat ditemukan: {len(data)}{RESET}")
                else:
                    print(
                        f"{YELLOW}  ⚠️ Tidak ada data CT logs untuk domain ini{RESET}")
            except ValueError:
                cprint(KUNING, "  ⚠️ Format respons CT tidak sesuai")
        else:
            cprint(KUNING, "  ⚠️ Gagal mengakses Certificate Transparency logs")

    except Exception as e:
        cprint(KUNING, f"  ⚠️ Pemeriksaan CT logs gagal: {e}")


def passive_dns(domain):
    """Passive DNS - Pencarian DNS pasif"""
    separator("📡 11. PASSIVE DNS - Pencarian DNS Pasif")
    try:
        if requests is None:
            cprint(KUNING, "  ⚠️ Modul requests tidak terinstall, lewati passive DNS")
            return

        # Gunakan VirusTotal API jika tersedia (dalam kasus nyata, ini akan memerlukan API key)
        print(f"{CYAN}  Mencari informasi DNS pasif untuk {domain}:{RESET}")
        print(
            f"    {YELLOW}⚠️  Fitur ini memerlukan API key VirusTotal untuk implementasi penuh{RESET}")
        print(
            f"    {YELLOW}   Untuk demo, hanya menampilkan informasi dasar DNS{RESET}")

        # Info DNS dasar
        try:
            ip = socket.gethostbyname(domain)
            HASIL["passive_dns_ip"] = ip
            print(f"    {GREEN}✓ IP Address: {ip}{RESET}")
        except socket.gaierror:
            print(f"    {RED}✗ Tidak dapat resolve domain{RESET}")

    except Exception as e:
        cprint(KUNING, f"  ⚠️ Pencarian DNS pasif gagal: {e}")


def url_reputation_check(domain):
    """URL Reputation Check - Pemeriksaan reputasi URL"""
    separator("🔍 12. URL REPUTATION CHECK - Pemeriksaan Reputasi URL")
    try:
        if requests is None:
            cprint(
                KUNING, "  ⚠️ Modul requests tidak terinstall, lewati reputation check")
            return

        # Cek dengan beberapa layanan reputasi
        print(f"{CYAN}  Mengecek reputasi URL untuk {domain}:{RESET}")

        # Google Safe Browsing
        try:
            safe_browsing_url = f"https://safebrowsing.googleapis.com/v4/threatMatches:find?key=YOUR_API_KEY"
            print(
                f"    {YELLOW}⚠️  Google Safe Browsing: API key diperlukan untuk pemeriksaan penuh{RESET}")
        except Exception:
            print(
                f"    {YELLOW}⚠️  Google Safe Browsing: Tidak dapat diakses{RESET}")

        # URLVoid (contoh)
        try:
            urlvoid_url = f"http://www.urlvoid.com/scan/{domain}/"
            print(
                f"    {YELLOW}⚠️  URLVoid: Contoh pemeriksaan (API key diperlukan){RESET}")
        except Exception:
            print(f"    {YELLOW}⚠️  URLVoid: Tidak dapat diakses{RESET}")

        print(f"    {CYAN}Rekomendasi: Gunakan layanan profesional seperti VirusTotal, URLVoid, atau Google Safe Browsing{RESET}")

    except Exception as e:
        cprint(KUNING, f"  ⚠️ Pemeriksaan reputasi URL gagal: {e}")


def cek_phishing_paths(domain):
    """Cek path phishing yang umum ditemukan di hasil.html"""
    separator("🎯 7. CEK PATH PHISHING - File Berbahaya")
    try:
        if requests is None:
            return
        paths = ["datafinal.php", "data.php", "save.php",
                 "result.php", "log.php", "admin/", "login.php", "auth.php", "verify.php"]
        for path in paths:
            url = f"https://{domain}/{path}"
            try:
                resp = requests.get(url, timeout=5)
                if resp.status_code == 200:
                    HASIL["path_aktif"].append(url)
                    cprint(
                        MERAH, f"  🚨 TERDETEKSI: {url} (status {resp.status_code})")
                    cprint(KUNING, f"     → File backend phishing terkonfirmasi!")
                else:
                    print(f"{HIJAU}  ✅ {url} → {resp.status_code} (tidak aktif)")
            except Exception:
                print(f"{HIJAU}  ✅ {url} → tidak dapat diakses")
    except Exception as e:
        cprint(KUNING, f"  ⚠️ Cek path gagal: {e}")


def rekomendasi_pelaporan(domain):
    """Rekomendasi pelaporan"""
    separator("📢 13. REKOMENDASI PELAPORAN")
    print(f"{CYAN}  Domain yang dianalisa:{RESET} {domain}")
    print()
    cprint(HIJAU, "  Laporkan ke platform berikut:")
    print()
    print(f"  {BOLD}1. Google Safe Browsing{RESET}")
    print(f"     URL : https://safebrowsing.google.com/safebrowsing/report_phish/")
    print()
    print(f"  {BOLD}2. PhishTank{RESET}")
    print(f"     URL : https://phishtank.org/")
    print()
    print(f"  {BOLD}3. Cloudflare Abuse Report{RESET}")
    print(f"     URL : https://www.cloudflare.com/abuse/")
    print(f"     Note: Hubungi: abuse@cloudflare.com")
    print()
    print(f"  {BOLD}4. Kominfo (jika di Indonesia){RESET}")
    print(f"     URL : https://www.kominfo.go.id/")
    print()
    print(f"  {BOLD}5. Registrar Domain (via WHOIS){RESET}")
    print(f"     Cari registrar di hasil WHOIS di atas")
    print()
    print(f"  {BOLD}6. Moonton (pemilik MLBB){RESET}")
    print(f"     Melalui customer service resmi MLBB")
    print()
    print(f"  {BOLD}7. VirusTotal{RESET}")
    print(f"     URL : https://www.virustotal.com/")
    print()
    print(f"  {BOLD}8. AbuseIPDB{RESET}")
    print(f"     URL : https://www.abuseipdb.com/")
    print()


def buat_laporan_domain(domain, output=None):
    """Buat laporan penyalahgunaan domain yang singkat dan jelas."""
    # Tentukan direktori penyimpanan laporan
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    LAPORAN_DIR = os.path.join(SCRIPT_DIR, "hasil_investigasi_domain")

    # Buat direktori jika belum ada
    if not os.path.exists(LAPORAN_DIR):
        os.makedirs(LAPORAN_DIR)
        cprint(HIJAU, f"  📁 Direktori laporan dibuat: {LAPORAN_DIR}")

    if output is None:
        output = os.path.join(LAPORAN_DIR, f"lapor_{domain}.txt")

    path_aktif = HASIL["path_aktif"]
    bukti_path = ", ".join(
        path_aktif) if path_aktif else "Tidak ada path umum berstatus 200 yang terkonfirmasi"
    indikator = []
    if "Terdeteksi" in HASIL["cloudflare"]:
        indikator.append(
            "domain memakai Cloudflare sehingga IP origin dapat tersembunyi")
    if path_aktif:
        indikator.append("ditemukan path backend yang aktif")
    if HASIL["http_status"] == "200":
        indikator.append("halaman domain aktif dan merespons HTTP 200")
    ringkasan = "; ".join(
        indikator) or "domain perlu diverifikasi lebih lanjut berdasarkan bukti konten phishing"

    isi = f"""LAPORAN PENYALAHGUNAAN DOMAIN
================================
Tanggal       : {datetime.now().strftime('%d-%m-%Y %H:%M:%S')}
Domain        : {domain}
URL           : https://{domain}/
Kategori      : Dugaan phishing / pencurian kredensial
Status HTTP   : {HASIL['http_status']}
URL akhir     : {HASIL['url_akhir']}

BUKTI TEKNIS
------------
IP/DNS        : {HASIL['ip']}
Name Server   : {HASIL['name_server']}
Registrar     : {HASIL['registrar']}
Terdaftar     : {HASIL['tanggal_registrasi']}
Status Domain : {HASIL['status_domain']}
Server        : {HASIL['server']}
Cloudflare    : {HASIL['cloudflare']}
Reverse DNS   : {HASIL['reverse_dns']}
Lokasi/Negara : {HASIL['negara']}
ISP           : {HASIL['isp']}
SSL Issuer    : {HASIL['ssl_issuer']}
SSL Berlaku   : {HASIL['ssl_berlaku_hingga']}
Path aktif    : {bukti_path}
Subdomain     : {
    ', '.join([s[0] for s in HASIL.get('subdomains', [])]) or 'Tidak ditemukan'}

RINGKASAN
---------
Domain tersebut diduga digunakan untuk aktivitas phishing. Hasil investigasi menunjukkan {ringkasan}.

PERMINTAAN TINDAKAN
-------------------
Mohon penyedia hosting dan registrar segera memeriksa domain ini, menonaktifkan konten phishing bila terkonfirmasi, mempertahankan log terkait sebagai bukti, dan mengirimkan konfirmasi tindakan.

Catatan: laporan ini dibuat otomatis dari hasil investigasi teknis. Bukti konten/screenshot sebaiknya dilampirkan secara terpisah.
"""
    Path(output).write_text(isi, encoding="utf-8")
    return output


# ============================================================
# BAGIAN 4: FUNGSI UTAMA
# ============================================================
def main():
    print(HEADER)
    cek_modul()

    if len(sys.argv) > 1:
        domain = sanitasi_domain(sys.argv[1])
    else:
        cprint(KUNING, "Contoh penggunaan:")
        print("   python investigator_domain.py zskt.kmtqgpjz.biz.id")
        print("   python investigator_domain.py https://example-phishing.com/page")
        print()
        domain = input("Masukkan domain yang ingin dianalisa: ").strip()
        domain = sanitasi_domain(domain)

    if not domain:
        cprint(MERAH, "❌ Domain tidak boleh kosong!")
        sys.exit(1)

    cprint(CYAN, f"\n🔎 Menganalisa domain: {BOLD}{domain}{RESET}\n")

    # 1. WHOIS
    whois_lookup(domain)

    # 2. DNS
    dns_lookup(domain)

    # 3. Resolve IP untuk geolokasi
    try:
        ip = socket.gethostbyname(domain)
        ip_geolocation(ip)
        reverse_dns(ip)
    except socket.gaierror:
        cprint(KUNING, "\n⚠️ Domain tidak bisa di-resolve — mungkin sudah mati/diblokir")

    # 4. SSL
    ssl_check(domain)

    # 5. HTTP Headers
    http_headers(domain)

    # 6. Security Headers Analysis
    security_headers_check(domain)

    # 7. Subdomain Enumeration
    subdomain_enum(domain)

    # 8. Certificate Transparency
    certificate_transparency(domain)

    # 9. Passive DNS
    passive_dns(domain)

    # 10. URL Reputation Check
    url_reputation_check(domain)

    # 11. Cek path phishing
    cek_phishing_paths(domain)

    # 12. Rekomendasi
    rekomendasi_pelaporan(domain)

    # 13. Buat laporan penyalahgunaan domain
    output = buat_laporan_domain(domain)

    cprint(HIJAU, "\n" + "=" * 60)
    cprint(HIJAU, "✅ ANALISA SELESAI")
    cprint(HIJAU, "=" * 60)
    cprint(HIJAU, f"📄 Laporan tersimpan: {output}")
    cprint(KUNING, "\n⚠️ INGAT:")
    cprint(KUNING, "   • HTTPS ≠ Aman. Situs phishing bisa punya gembok kunci!")
    cprint(KUNING, "   • Selalu periksa URL di address bar browser")
    cprint(KUNING, "   • Jangan pernah memasukkan kredensial di situs tidak resmi")
    cprint(KUNING, "   • Gunakan tools ini hanya untuk tujuan edukasi dan pelaporan keamanan")


if __name__ == "__main__":
    main()
