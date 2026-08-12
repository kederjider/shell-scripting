#!/usr/bin/env python3
# IMPORT MODULE

import re
import os
import random
import string
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from urllib.parse import urlparse

import requests
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

RESET = "\033[0m"
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
CYAN = "\033[96m"
BOLD = "\033[1m"
MAG='\033[1;35m'


def banner():
    print(f"\n{BOLD}{CYAN}========================================{RESET}")
    print(f"{BOLD}{CYAN}     ✦ RANDOM PAYLOAD DEMO ✦           {RESET}")
    print(f"{BOLD}{CYAN}========================================{RESET}\n")

def clean_terminal_input(value):
    return re.sub(r'\x1b\[[0-9;?]*[ -/]*[@-~]', '', value)

def generate_random_password(length=12):
    characters = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(random.choice(characters) for _ in range(length))

def random_text(length: int = 6) -> str:
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))

def print_box(label: str, text: str, color: str = BLUE):
    print(f"{color}{BOLD}[{label}]{RESET} {text}")


def send_telegram_notification(message: str, token: str, chat_ids_str: str):
    # Memisahkan chat ID jika ada lebih dari satu (dipisahkan dengan koma)
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
                print_box("TELEGRAM", f"Notifikasi terkirim ke Telegram (Chat ID: {chat_id}).", GREEN)
            else:
                print_box("TELEGRAM", f"Gagal mengirim notifikasi ke {chat_id}: {response.status_code}", RED)
        except requests.exceptions.RequestException as e:
            print_box("TELEGRAM", f"Error notifikasi ke {chat_id}: {e}", RED)


def send_request(index: int, url: str, origin: str, cookie: str):
    # URL tujuan, origin, dan cookie sudah diterima sebagai parameter
    referer = origin + "/"
    
    email_local = f"{random_text(10)}"
    emailnya = random.choice(["SELAT4D", "RatuMacau", "LBSATSET", "ABANGKU", "RAJA717", "3DBET", "pptotonet"])
    domain = random.choice(["gmail.com", "yahoo.com", "outlook.com", "mail.com"])
    points = random.choice(["World Collector", "Amateur Collector", "Junior Collector", "Seasoned Collector", "Expert Collector", "Renowned Collector", "Master Collector", "Legendary Collector", "Exalted Collector", "Ultimate Collector", "Mega Collector", "Supreme Collector", "Mythic Collector", "Immortal Collector", "Eternal Collector", "Transcendent Collector", "Omniscient Collector", "Infinite Collector", "Celestial Collector", "Divine Collector", "World-Class Collector", "Elite Collector", "Champion Collector", "Grandmaster Collector", "Supreme Champion", "Ultimate Champion", "Legendary Champion", "Mythic Champion", "Immortal Champion", "Eternal Champion", "Transcendent Champion", "Omniscient Champion", "Infinite Champion", "Celestial Champion", "Divine Champion", "World-Class Champion", "Elite Champion", "Champion of Champions", "Grandmaster of Champions", "Supreme Champion of Champions", "Ultimate Champion of Champions", "Legendary Champion of Champions", "Mythic Champion of Champions", "Immortal Champion of Champions", "Eternal Champion of Champions", "Transcendent Champion of Champions", "Omniscient Champion of Champions", "Infinite Champion of Champions", "Celestial Champion of Champions", "Divine Champion of Champions"])
    login = random.choice(["Google Play", "Moonton"])
    password = f"{random_text(12)}!"
    
    # Generate password random
    random_password = generate_random_password(14)
    # Payload sesuai data yang kamu berikan
    payload = {
        "email": f"{emailnya}@{domain}",
        "password": random_password,       # diganti random
        "email2": "",
        "password2": random_password,
        "pass": random_password,
        "pass2": random_password,
        "login": login,
        "playid": str(random.randint(000000000, 999999999)),
        "codetel": "",
        "server": str(random.randint(0000, 9999)),
        "phone": f"08{str(random.randint(000000000, 9999999999))}",
        "level": str(random.randint(0, 200)),
        "points": points
    }

    # Headers (sudah dibersihkan, pseudo-header HTTP/2 tidak dimasukkan)
    headers = {
        "accept": "*/*",
        "accept-encoding": "gzip, deflate, br, zstd",
        "accept-language": "id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7",
        "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        "cookie": cookie,
        "origin": origin,
        "priority": "u=1, i",
        "referer": referer,
        "sec-ch-ua": '"Not;A=Brand";v="8", "Chromium";v="150", "Google Chrome";v="150"',
        "sec-ch-ua-mobile": "?1",
        "sec-ch-ua-platform": '"Android"',
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin",
        "user-agent": "Mozilla/5.0 (Linux; Android 16; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36",
        "x-requested-with": "XMLHttpRequest"
    }

    #print(f"Password yang digunakan: {random_password}\n")

    try:
        response = requests.post(url, data=payload, headers=headers, timeout=15)
        
        print_box("THREAD", f"{index}", CYAN)
        print_box("EMAIL", payload["email"], GREEN)
        print_box("PASSWORD", payload["password"], YELLOW)
        print_box("PHONE", payload["phone"], MAG)
        print_box("STATUS", f"{response.status_code}", GREEN if response.status_code == 200 else RED)
        print_box("RESPONSE", f"{response.text[:1000]}", CYAN)
        #print("Status Code:", response.status_code)
        #print("\nResponse:")
        #print(response.text[:1000])
        if response.status_code == 200:
            print("\n✅ Request berhasil dikirim!")
        else:
            print(f"\n❌ Request gagal dengan status: {response.status_code}")

    except requests.exceptions.RequestException as e:
        print("❌ Error:", str(e)) 


def tugas(args):
    index, url, origin, cookie = args
    send_request(index, url, origin, cookie)
    time.sleep(0.5)
    return f"{GREEN}Thread {index} selesai.{RESET}"


TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")


def main():

    banner()
    start_time = time.time()

    # ── Mode CLI (parameter) vs Mode Interaktif ─────────────────────
    if len(sys.argv) >= 3:
        # Mode CLI: python spam_post.py <url> <cookie> [thread_count]
        target_url = sys.argv[1].strip()
        cookie = sys.argv[2].strip()
        thread_count = int(sys.argv[3].strip()) if len(sys.argv) >= 4 else 8
        print_box("MODE", "CLI (Parameter)", GREEN)
        print_box("URL", target_url, CYAN)
        print_box("COOKIE", cookie[:30] + "..." if len(cookie) > 30 else cookie, CYAN)
        print_box("THREAD", str(thread_count), CYAN)
    else:
        # ── Input sekali di awal (interaktif) ───────────────────────
        target_url = clean_terminal_input(input(f"{BOLD}{CYAN}Masukkan URL tujuan (contoh: https://mlbbevent-skin.2-e.vu/datafinal.php): {RESET}").strip())
        cookie     = clean_terminal_input(input(f"{BOLD}{CYAN}Masukkan Cookie (contoh: PHPSESSID=xxx): {RESET}").strip())
        thread_count = int(clean_terminal_input(input(f"{BOLD}{CYAN}Masukkan jumlah thread (contoh: 8): {RESET}").strip()))
    # ─────────────────────────────────────────────────────────────────

    # Parsing origin dari target_url (menghapus path seperti /datafinal.php atau /index.html)
    parsed_url = urlparse(target_url)
    origin = f"{parsed_url.scheme}://{parsed_url.netloc}"

    bot_token = TELEGRAM_BOT_TOKEN
    chat_id = TELEGRAM_CHAT_ID

    task_args = [(i, target_url, origin, cookie) for i in range(1, 5001)]
    with ThreadPoolExecutor(max_workers=thread_count) as executor:
        results = list(executor.map(tugas, task_args))

    print(f"\n{BOLD}{CYAN}========================================{RESET}")
    print(f"{BOLD}{CYAN}      📌 RINGKASAN EKSEKUSI              {RESET}")
    print(f"{BOLD}{CYAN}========================================{RESET}\n")

    for result in results:
        print(result)

    elapsed = time.time() - start_time
    elapsed_minutes = elapsed / 60
    summary_message = f"Program selesai dalam {elapsed_minutes:.2f} menit dengan {thread_count} thread."
    print(f"\n{BOLD}{GREEN}{summary_message}{RESET}\n")

    if bot_token and chat_id:
        send_telegram_notification(summary_message, bot_token, chat_id)


if __name__ == "__main__":
    main()