#!/usr/local/bin/.venv/bin/python
#!/usr/bin/env python3
"""
IDADX Domain Abuse Checker
===========================
Script ini mengecek status sebuah domain (bersih/kotor) melalui situs
resmi IDADX (https://idadx.id) yang dikelola oleh PANDI.

CATATAN PENTING:
Situs idadx.id dibangun dengan Next.js dan hasil scan-nya dirender
lewat JavaScript di sisi client (client-side rendering), bukan
langsung ada di HTML mentah. Karena itu library `requests` biasa
TIDAK BISA membaca hasilnya secara langsung — HTML yang didapat cuma
kerangka kosong. Untuk mengatasi ini, script ini memakai Playwright
(headless browser) supaya halaman benar-benar dirender dulu sebelum
datanya diambil.

INSTALL DEPENDENSI:
    pip install playwright rich
    playwright install chromium

CARA PAKAI:
    python idadx_scan.py
    (lalu masukkan nama domain saat diminta, misal: gapesta.my.id)
"""

import importlib.util
import os
from pathlib import Path
import re
import subprocess
import sys


REQUIRED_PACKAGES = {
    "playwright": "playwright",
    "rich": "rich",
}


def ensure_dependencies() -> None:
    """Buat/aktifkan .venv dan pasang dependensi yang belum tersedia."""
    script_dir = Path(__file__).resolve().parent
    setup_script = script_dir / "setup-python.sh"
    venv_python = script_dir / ".venv" / "bin" / "python"
    current_python = Path(sys.executable).resolve()
    running_in_project_venv = (
        venv_python.is_file() and current_python == venv_python.resolve()
    )
    missing = [
        package
        for module, package in REQUIRED_PACKAGES.items()
        if importlib.util.find_spec(module) is None
    ]

    # Selalu gunakan .venv proyek agar paket tidak tercampur dengan Python sistem.
    if not running_in_project_venv:
        if not setup_script.is_file():
            print(f"❌ File setup tidak ditemukan: {setup_script}")
            sys.exit(1)

        print("🔧 Menyiapkan dan mengaktifkan environment .venv...")
        try:
            subprocess.run(
                ["bash", "-c", 'source "$1"', "bash", str(setup_script)],
                cwd=script_dir,
                check=True,
            )
        except (OSError, subprocess.CalledProcessError) as exc:
            print(f"❌ Gagal menjalankan setup-python.sh: {exc}")
            sys.exit(1)

        if not venv_python.is_file():
            print(f"❌ Interpreter .venv tidak ditemukan: {venv_python}")
            sys.exit(1)

        os.execv(str(venv_python), [str(venv_python), *sys.argv])

    if not missing:
        return

    print("📦 Menginstall library yang belum tersedia: " + ", ".join(missing))
    try:
        subprocess.run(
            [str(venv_python), "-m", "pip", "install", *missing],
            cwd=script_dir,
            check=True,
        )
        if "playwright" in missing:
            subprocess.run(
                [str(venv_python), "-m", "playwright", "install", "chromium"],
                cwd=script_dir,
                check=True,
            )
    except (OSError, subprocess.CalledProcessError) as exc:
        print(f"❌ Gagal menginstall dependensi: {exc}")
        sys.exit(1)


ensure_dependencies()

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("❌ Playwright belum dapat dimuat setelah instalasi otomatis.")
    sys.exit(1)

try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.table import Table
    from rich.text import Text
    from rich import box
except ImportError:
    print("❌ Library 'rich' belum dapat dimuat setelah instalasi otomatis.")
    sys.exit(1)

console = Console()

BASE_URL = "https://idadx.id/scan?domain={}"


def is_valid_domain(domain: str) -> bool:
    """Validasi sederhana format domain."""
    pattern = r"^(?!-)[A-Za-z0-9-]{1,63}(?<!-)(\.[A-Za-z0-9-]{1,63}(?<!-))+$"
    return bool(re.match(pattern, domain))


def fetch_scan_result(domain: str) -> dict:
    """
    Membuka halaman scan IDADX menggunakan headless browser
    lalu mengekstrak informasi status, tipe, jumlah URL, brand match,
    serta daftar URL yang tercatat.
    """
    url = BASE_URL.format(domain)
    result = {
        "domain": domain,
        "status": None,
        "type": None,
        "total_urls": None,
        "brand_matches": None,
        "urls": [],
    }

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(user_agent=(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/124.0 Safari/537.36"
        ))
        page.goto(url, wait_until="networkidle", timeout=30000)

        # beri sedikit waktu tambahan untuk memastikan React selesai render
        page.wait_for_timeout(1500)

        # Status utama (Detected as Abuse / Clean / dsb)
        try:
            status_el = page.locator("text=Detected as Abuse").first
            if status_el.count() > 0:
                result["status"] = "Detected as Abuse"
            else:
                clean_el = page.locator("text=No URLs found").first
                if clean_el.count() > 0:
                    result["status"] = "Clean / Tidak Terdeteksi"
        except Exception:
            pass

        # Ambil kartu info: STATUS, TYPE, TOTAL URLS, BRAND MATCHES
        try:
            cards = page.locator("div").filter(has_text="TOTAL URLS")
        except Exception:
            cards = None

        # Ambil teks kasar body untuk parsing manual (lebih robust
        # daripada mengandalkan struktur DOM yang bisa berubah-ubah)
        body_text = page.inner_text("body")

        def extract_after(label):
            m = re.search(re.escape(label) + r"\s*\n?\s*([^\n]+)", body_text)
            return m.group(1).strip() if m else None

        result["status"] = extract_after("STATUS") or result["status"]
        result["type"] = extract_after("TYPE")
        result["total_urls"] = extract_after("TOTAL URLS")
        result["brand_matches"] = extract_after("BRAND MATCHES")

        # Ambil daftar URL beserta status resolusinya
        try:
            rows = page.locator("table tr")
            count = rows.count()
            for i in range(count):
                row_text = rows.nth(i).inner_text().strip()
                if not row_text or "URL" == row_text or "STATUS" in row_text.upper() and "http" not in row_text:
                    continue
                parts = [p.strip() for p in row_text.split("\n") if p.strip()]
                if len(parts) >= 2 and ("http://" in parts[0] or "https://" in parts[0]):
                    result["urls"].append(
                        {"url": parts[0], "status": parts[-1]})
        except Exception:
            pass

        browser.close()

    return result


def render_result(result: dict):
    domain = result["domain"]
    status = (result["status"] or "").lower()

    is_abuse = "abuse" in status or "reported" in status

    if is_abuse:
        header_style = "bold white on red"
        icon = "🚨"
        verdict_text = "TERDETEKSI SEBAGAI DOMAIN ABUSE ❌"
        verdict_style = "bold red"
    elif result["status"]:
        header_style = "bold white on green"
        icon = "✅"
        verdict_text = "DOMAIN TERLIHAT BERSIH ✨"
        verdict_style = "bold green"
    else:
        header_style = "bold white on yellow"
        icon = "❓"
        verdict_text = "STATUS TIDAK DAPAT DIPASTIKAN"
        verdict_style = "bold yellow"

    console.print()
    console.print(Panel(
        Text(f"{icon}  HASIL SCAN DOMAIN: {domain}", justify="center"),
        style=header_style,
        box=box.DOUBLE,
    ))

    console.print(Panel(Text(verdict_text, justify="center",
                  style=verdict_style), box=box.ROUNDED))

    info_table = Table(show_header=False, box=box.SIMPLE_HEAVY, padding=(0, 2))
    info_table.add_row("📌 Status", result["status"] or "-")
    info_table.add_row("🏷️  Tipe", result["type"] or "-")
    info_table.add_row("🔗 Total URL Terlapor", result["total_urls"] or "0")
    info_table.add_row("🏢 Brand Cocok", result["brand_matches"] or "0")
    console.print(info_table)

    if result["urls"]:
        console.print()
        url_table = Table(title="🔍 Daftar URL Terlapor",
                          box=box.ROUNDED, show_lines=False)
        url_table.add_column("No", justify="right", style="dim")
        url_table.add_column("URL", style="cyan")
        url_table.add_column("Status", style="magenta")
        for idx, item in enumerate(result["urls"], start=1):
            status_icon = "⛔" if "not resolved" in item["status"].lower(
            ) else "✔️"
            url_table.add_row(
                str(idx), item["url"], f"{status_icon} {item['status']}")
        console.print(url_table)
    else:
        console.print("\n[dim]— Tidak ada URL spesifik yang tercatat —[/dim]")

    console.print()
    console.print(Panel(
        "Sumber data: [bold]idadx.id[/bold] (IDADX — PANDI)\n"
        f"Link laporan lengkap: [underline]{BASE_URL.format(domain)}[/underline]",
        box=box.MINIMAL,
        style="dim",
    ))


def main():
    console.print(Panel(
        Text("🛡️  IDADX DOMAIN ABUSE CHECKER  🛡️",
             justify="center", style="bold cyan"),
        subtitle="powered by idadx.id (PANDI)",
        box=box.DOUBLE_EDGE,
    ))

    domain = console.input(
        "\n🌐 Masukkan nama domain yang ingin di-scan (contoh: gapesta.my.id): ").strip()

    if not domain:
        console.print("[bold red]❌ Domain tidak boleh kosong![/bold red]")
        sys.exit(1)

    if not is_valid_domain(domain):
        console.print(
            f"[bold red]❌ Format domain '{domain}' tidak valid.[/bold red]")
        sys.exit(1)

    with console.status(f"[bold cyan]🔎 Sedang memindai {domain} ...[/bold cyan]", spinner="dots"):
        try:
            result = fetch_scan_result(domain)
        except Exception as e:
            console.print(
                f"[bold red]❌ Terjadi kesalahan saat mengambil data: {e}[/bold red]")
            sys.exit(1)

    render_result(result)


if __name__ == "__main__":
    main()
