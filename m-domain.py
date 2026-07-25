#!/usr/bin/env python3

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

    result = subprocess.run(["whois", domain], capture_output=True, text=True, check=False)
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


def main():
    if shutil.which("whois") is None:
        print(colorize("⚠️  whois belum terpasang. Silakan pasang dengan perintah: apt install whois", RED))
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
        print(format_whois_line(item))


if __name__ == "__main__":
    main()