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


def banner():
    print(f"\n{BOLD}{CYAN}========================================{RESET}")
    print(f"{BOLD}{CYAN}     ✦ RANDOM PAYLOAD DEMO ✦           {RESET}")
    print(f"{BOLD}{CYAN}========================================{RESET}\n")


def random_text(length: int = 6) -> str:
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=length))


def build_payload() -> dict:
    email_local = f"{random_text(8)}"
    domain = random.choice(["gmail.com", "yahoo.com", "outlook.com", "mail.com"])
    password = f"{random_text(12)}!"

    return {
        "email": f"{email_local}@{domain}",
        "password": password,
        "GooglePassword": "",
        "playid": str(random.randint(100000000, 999999999)),
        "phone": str(random.randint(10000000000, 99999999999)),
        "level": "100",
        "login": "Google"
    }
    


def print_box(label: str, text: str, color: str = BLUE):
    print(f"{color}{BOLD}[{label}]{RESET} {text}")


def send_request(index: int):
    url = "https://mlbbeventmpl.townnd.web.id/datafinal.php"
    payload = build_payload()

    print_box("THREAD", f"#{index}", CYAN)
    print_box("EMAIL", payload["email"], GREEN)
    print_box("PASSWORD", payload["password"], YELLOW)
    print_box("STATUS", "Mengirim request...", BLUE)

    headers = {
        "Host": "mlbbeventmpl.townnd.web.id",
        "Sec-Ch-Ua-Platform": "Windows",
        "Accept-Language": "en-US,en;q=0.9",
        "Sec-Ch-Ua": '"Not-A.Brand";v="24", "Chromium";v="146"',
        "Sec-Ch-Ua-Mobile": "?0",
        "X-Requested-With": "XMLHttpRequest",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36",
        "Accept": "*/*",
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
        "Origin": "https://mlbbeventmpl.townnd.web.id",
        "Sec-Fetch-Site": "same-origin",
        "Sec-Fetch-Mode": "cors",
        "Sec-Fetch-Dest": "empty",
        "Referer": "https://mlbbeventmpl.townnd.web.id/",
        "Priority": "u=1, i"
    },

    try:
        response = requests.post(url, data=payload, headers=headers, timeout=15)

        print_box("HTTP", f"{response.status_code}", GREEN if response.status_code == 200 else RED)
        snippet = response.text[:120].replace("\n", " ")
        print_box("RESPONSE", snippet if snippet else "(kosong)", CYAN)

        if response.status_code == 200:
            print_box("RESULT", "Request berhasil dikirim.", GREEN)
        else:
            print_box("RESULT", f"Request gagal: {response.status_code}", RED)

    except requests.exceptions.RequestException as e:
        print_box("ERROR", str(e), RED)

    print()


def tugas(index: int):
    send_request(index)
    time.sleep(0.5)
    return f"{GREEN}Thread {index} selesai.{RESET}"


THREAD_COUNT = 4
TASK_COUNT = 8


def main():
    banner()
    start_time = time.time()

    with ThreadPoolExecutor(max_workers=THREAD_COUNT) as executor:
        results = list(executor.map(tugas, range(1, 99999999)))

    print(f"\n{BOLD}{CYAN}========================================{RESET}")
    print(f"{BOLD}{CYAN}      📌 RINGKASAN EKSEKUSI              {RESET}")
    print(f"{BOLD}{CYAN}========================================{RESET}\n")

    for result in results:
        print(result)

    print(f"\n{BOLD}{GREEN}Selesai dalam {time.time() - start_time:.2f} detik.{RESET}\n")


if __name__ == "__main__":
    main()