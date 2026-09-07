#!/usr/local/bin/.venv/bin/python
#!/usr/bin/env python3

import os
import re
import shutil
import subprocess
import sys

KEYWORDS = [
    "Domain Name",
    "Registry Domain ID",
    "Registrar WHOIS Server",
    "Registrar URL",
    "Updated Date",
    "Creation Date",
    "Registry Expiry Date",
    "Registrar:",
    "Registrar IANA ID",
    "Registrar Abuse Contact Email",
    "Registrar Abuse Contact Phone",
    "Domain Status",
    "Name Server",
]

RESET = "\033[0m"
BOLD = "\033[1m"
CYAN = "\033[96m"
YELLOW = "\033[93m"
GREEN = "\033[92m"
RED = "\033[91m"
BLUE = "\033[94m"
MAGENTA = "\033[95m"


def colorize(text, color):
    if sys.stdout.isatty():
        return f"{color}{text}{RESET}"
    return text


def print_banner(domain):
    width = 70
    title = "🔎 WHOIS LOOKUP"
    print()
    print(colorize("╔" + "═" * width + "╗", CYAN))
    print(colorize(f"║ {title:<{width - 2}}║", BOLD + CYAN))
    print(colorize(f"║ 🌐 Domain: {domain:<{width - 14}}  ║", YELLOW))
    print(colorize("╚" + "═" * width + "╝", CYAN))


def get_whois(domain):
    if shutil.which("whois") is None:
        return None

    result = subprocess.run(
        ["whois", domain], capture_output=True, text=True, check=False)
    if result.returncode != 0 and not result.stdout:
        return []
    return result.stdout.splitlines()


def filter_whois(lines):
    filtered = []

    for line in lines:
        for key in KEYWORDS:
            if line.strip().startswith(key):
                filtered.append(line.strip())

    return filtered


def format_whois_line(line):
    if ":" in line:
        key, value = line.split(":", 1)
        return f"{colorize('  ├─', CYAN)} {colorize('●', MAGENTA)} {colorize(key.strip(), BOLD + BLUE)}{colorize(':', CYAN)} {colorize(value.strip(), GREEN)}"
    return f"{colorize('  ├─', CYAN)} {colorize('●', MAGENTA)} {colorize(line.strip(), GREEN)}"


def clean_status_value(value):
    """Bersihkan nilai status: buang URL referensi (mis. https://icann.org/epp#clientHold)."""
    value = re.sub(r"https?://\S+", "", value)
    return " ".join(value.split())


def classify_status(value):
    """
    Terjemahkan status EPP mentah (WHOIS) menjadi label + penjelasan yang jelas.
    Mengembalikan tuple (label, warna, keterangan).
    """
    v = clean_status_value(value).lower()

    # ---- SUSPENDED -------------------------------------------------
    if "serverhold" in v:
        return (
            "⛔ SUSPENDED (Server Hold)",
            RED,
            "Ditangguhkan LANGSUNG oleh registry pusat (mis. Verisign untuk .com). "
            "Biasanya karena alasan hukum atau pelanggaran berat.",
        )
    if "clienthold" in v:
        return (
            "⛔ SUSPENDED (Client Hold)",
            RED,
            "Ditangguhkan oleh registrar (penjual domain). "
            "Biasanya karena pembayaran bermasalah, penyalahgunaan, "
            "atau permintaan pemilik.",
        )

    # ---- MASA KRITIS / MENUJU HAPUS --------------------------------
    if "redemptionperiod" in v:
        return (
            "🆘 MASA TEBUS (Redemption Period)",
            RED,
            "Domain sudah dihapus & masuk masa tebus (±30 hari). "
            "Segera tebus ke registrar sebelum dilepas ke publik!",
        )
    if "pendingdelete" in v:
        return (
            "🗑️ PENDING DELETE (Menunggu Hapus)",
            RED,
            "Domain tidak bisa diperpanjang lagi dan akan segera dihapus/dirilis.",
        )
    if "pendingrestore" in v:
        return (
            "🔧 PENDING RESTORE (Proses Pemulihan)",
            YELLOW,
            "Domain sedang dalam proses pemulihan (restore) oleh registrar.",
        )

    # ---- AKTIF / NORMAL --------------------------------------------
    if v in ("ok", "active"):
        return (
            "✅ AKTIF (Normal)",
            GREEN,
            "Domain aktif dan berjalan normal.",
        )
    if "clienttransferprohibited" in v:
        return (
            "✅ AKTIF (Normal)",
            GREEN,
            "Domain aktif; transfer dikunci oleh registrar (proteksi anti-hijack).",
        )
    if "servertransferprohibited" in v:
        return (
            "✅ AKTIF (Normal)",
            GREEN,
            "Domain aktif; transfer dikunci oleh registry pusat (anti-hijack).",
        )
    if any(
        s in v
        for s in (
            "clientupdateprohibited",
            "serverupdateprohibited",
            "clientdeleteprohibited",
            "serverdeleteprohibited",
            "clientrenewprohibited",
            "serverrenewprohibited",
        )
    ):
        return (
            "✅ AKTIF (Normal)",
            GREEN,
            "Domain aktif, namun ada proteksi update/delete/renew "
            "dari registrar atau registry.",
        )
    if any(
        s in v
        for s in ("autorenewperiod", "addperiod", "renewperiod", "transferperiod")
    ):
        return (
            "✅ AKTIF (Normal)",
            GREEN,
            "Domain aktif (sedang dalam masa perpanjangan/peralihan).",
        )
    if "pendingtransfer" in v:
        return (
            "🔄 PENDING TRANSFER",
            CYAN,
            "Proses transfer domain ke registrar lain sedang berjalan.",
        )

    # ---- LAINNYA ----------------------------------------------------
    if "inactive" in v:
        return (
            "⚠️ TIDAK AKTIF (Inactive)",
            YELLOW,
            "Domain terdaftar tapi belum aktif — mis. belum ada Name Server.",
        )
    if "expired" in v:
        return (
            "⚠️ KEDALUWARSA (Expired)",
            YELLOW,
            "Domain sudah melewati tanggal kedaluwarsa.",
        )
    return (
        "❓ STATUS TIDAK DIKENAL",
        CYAN,
        "Belum ada aturan untuk status ini — cek manual ke registrar/registry.",
    )


def format_status_line(line):
    """Cetak baris 'Domain Status' dengan label + penjelasan yang mudah dibaca."""
    _, value = line.split(":", 1)
    raw_status = clean_status_value(value)
    label, color, note = classify_status(value)

    return "\n".join(
        [
            f"{colorize('  ├─', CYAN)} {colorize('●', MAGENTA)} "
            f"{colorize('Domain Status:', BOLD + BLUE)} "
            f"{colorize(raw_status, BOLD)}",
            f"{colorize('  │   └─', CYAN)} {colorize(label, BOLD + color)}",
            f"{colorize('  │       ', CYAN)} "
            f"{colorize('💬', MAGENTA)} {colorize(note, YELLOW)}",
        ]
    )


def run_privileged(args, env=None):
    """
    Jalankan perintah apt dengan hak root.
    Bila bukan root, otomatis dibungkus sudo (coba sudo -n dulu, lalu sudo biasa).
    """
    if os.geteuid() == 0:
        return subprocess.run(args, capture_output=True, text=True,
                              check=False, env=env)

    for prefix in (["sudo", "-n"], ["sudo"]):
        result = subprocess.run(
            prefix + args, capture_output=True, text=True, check=False, env=env)
        if result.returncode == 0:
            return result
    return result


def ensure_whois():
    """
    Pastikan perintah 'whois' tersedia.
    Jika sudah → skip. Jika belum → apt update lalu apt install -y whois.
    """
    if shutil.which("whois"):
        print(colorize("✅ whois sudah terpasang — lanjut.", GREEN))
        return True

    print(colorize(
        "⚠️  whois belum terpasang. Menjalankan apt update & install whois...", YELLOW))
    env = dict(os.environ)
    env["DEBIAN_FRONTEND"] = "noninteractive"

    steps = [
        ("apt update", ["apt-get", "update"]),
        ("apt install -y whois", ["apt-get", "install", "-y", "whois"]),
    ]
    for nama, cmd in steps:
        print(colorize(f"⚙️  {nama} ...", CYAN))
        result = run_privileged(cmd, env=env)
        if result.returncode != 0:
            print(colorize(f"❌ Gagal menjalankan: {nama}", RED))
            pesan = result.stderr.strip() or result.stdout.strip()
            if pesan:
                print(colorize(pesan, RED))
            return False

    if shutil.which("whois"):
        print(colorize("✅ whois berhasil dipasang.", GREEN))
        return True

    print(colorize("❌ whois tetap tidak ditemukan setelah instalasi.", RED))
    return False


def main():
    if not ensure_whois():
        sys.exit(1)

    domain = input(colorize("🔎 Masukkan domain: ", YELLOW)).strip()
    if not domain:
        print(colorize("⚠️  Domain tidak boleh kosong.", RED))
        sys.exit(1)

    lines = get_whois(domain)
    print_banner(domain)

    if lines is None:
        print(colorize("⚠️  Perintah 'whois' tidak tersedia di sistem ini.", RED))
        sys.exit(1)

    data = filter_whois(lines)

    if not data:
        print(colorize("⚠️  Tidak ada data WHOIS yang ditemukan.", RED))
        return

    print(colorize("📋 Informasi WHOIS", BOLD + CYAN))
    for item in data:
        if item.startswith("Domain Status"):
            print(format_status_line(item))
        else:
            print(format_whois_line(item))


if __name__ == "__main__":
    main()
