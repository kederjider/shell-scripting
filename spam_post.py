#!/usr/bin/env python3
# IMPORT MODULE

import os
import random
import string
import time
from concurrent.futures import ThreadPoolExecutor

import requests

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


def generate_random_password(length=12):
    characters = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(random.choice(characters) for _ in range(length))

def random_text(length: int = 6) -> str:
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))

def print_box(label: str, text: str, color: str = BLUE):
    print(f"{color}{BOLD}[{label}]{RESET} {text}")


def send_telegram_notification(message: str, token: str, chat_id: str):
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": message,
        "parse_mode": "HTML",
    }
    try:
        response = requests.post(url, data=payload, timeout=10)
        if response.ok:
            print_box("TELEGRAM", "Notifikasi terkirim ke Telegram.", GREEN)
        else:
            print_box("TELEGRAM", f"Gagal mengirim notifikasi: {response.status_code}", RED)
    except requests.exceptions.RequestException as e:
        print_box("TELEGRAM", f"Error notifikasi: {e}", RED)


def send_request(index: int):
    # URL tujuan
    input_url = input(f"{BOLD}{CYAN}Masukkan URL tujuan (contoh: https://mlbbevent-skin.2-e.vu/datafinal.php): {RESET}")
    url = input_url.strip()  # Menghapus spasi di awal dan akhir
    #url = "https://mlbbevent-skin.2-e.vu/datafinal.php"
    
    origin = input(f"{BOLD}{CYAN}Masukkan Origin (contoh: https://mlbbevent-skin.2-e.vu): {RESET}")
    #origin = "https://mlbbevent-skin.2-e.vu"
    referer = origin + "/"
    cookie = input(f"{BOLD}{CYAN}Masukkan Cookie (contoh: PHPSESSID=3445cdcb059d8f664d3167a6a0919a6e): {RESET}")
    #cookie = "PHPSESSID=3445cdcb059d8f664d3167a6a0919a6e"
    
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


def tugas(index: int):
    send_request(index)
    time.sleep(0.5)
    return f"{GREEN}Thread {index} selesai.{RESET}"


THREAD_COUNT = int(input(f"{BOLD}{CYAN}Masukkan jumlah thread (contoh: 8): {RESET}"))

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")


def main():
    
    banner()
    start_time = time.time()

    bot_token = TELEGRAM_BOT_TOKEN
    chat_id = TELEGRAM_CHAT_ID

    if not bot_token or not chat_id:
        enable_telegram = input(f"{BOLD}{CYAN}Kirim notifikasi Telegram saat selesai? (y/n): {RESET}").strip().lower()
        if enable_telegram in ("y", "yes"):
            bot_token = input(f"{BOLD}{CYAN}Masukkan Telegram Bot Token: {RESET}").strip()
            chat_id = input(f"{BOLD}{CYAN}Masukkan Chat ID Telegram: {RESET}").strip()

    with ThreadPoolExecutor(max_workers=THREAD_COUNT) as executor:
        results = list(executor.map(tugas, range(1, 3000)))

    print(f"\n{BOLD}{CYAN}========================================{RESET}")
    print(f"{BOLD}{CYAN}      📌 RINGKASAN EKSEKUSI              {RESET}")
    print(f"{BOLD}{CYAN}========================================{RESET}\n")

    for result in results:
        print(result)

    elapsed = time.time() - start_time
    summary_message = f"Program selesai dalam {elapsed:.2f} detik dengan {THREAD_COUNT} thread."
    print(f"\n{BOLD}{GREEN}{summary_message}{RESET}\n")

    if bot_token and chat_id:
        send_telegram_notification(summary_message, bot_token, chat_id)


if __name__ == "__main__":
    main()