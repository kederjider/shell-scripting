#!/usr/bin/env python3
# IMPORT MODULE

import json
import os
import sys
import sys
import time
import phonenumbers
import requests
import subprocess
from phonenumbers import carrier, geocoder, timezone
from sys import stderr

Bl = '\033[30m'  # VARIABLE WARNA
Re = '\033[1;31m'
Gr = '\033[1;32m'
Ye = '\033[1;33m'
Blu = '\033[1;34m'
Mage = '\033[1;35m'
Cy = '\033[1;36m'
Wh = '\033[1;37m'
RESET = '\033[0m'
BOLD = '\033[1m'


def colorize(text, color):
    return f"{color}{text}{RESET}"


def print_panel(title, subtitle=None, icon=""):
    width = 60
    print()
    print(colorize("┌" + "─" * width + "┐", Cy))
    print(colorize(f"│ {icon} {title:<{width - 4}}│", BOLD + Cy))
    if subtitle:
        print(colorize(f"│ {subtitle:<{width - 2}} │", Ye))
    print(colorize("└" + "─" * width + "┘", Cy))


def print_info_row(label, value, icon="●", label_color=Cy, value_color=Wh):
    print(f"{colorize(icon, Mage)} {colorize(label.ljust(16), label_color)} {colorize('•', Ye)} {colorize(str(value), value_color)}")


# utilities

# decorator for attaching run_banner to a function
def is_option(func):
    def wrapper(*args, **kwargs):
        run_banner()
        func(*args, **kwargs)


    return wrapper

# ================== AUTO INSTALL LIBRARY ==================
def install_package(package):
    try:
        __import__(package.replace("-", "_"))  # secure-smtplib → secure_smtplib
        #print(f"✅ {package} sudah terinstall")
        pass
        return
    except ImportError:
        print(f"📦 {package} belum terinstall, sedang menginstall...")

    try:
        # Tambahkan opsi untuk menghindari warning root
        cmd = [sys.executable, "-m", "pip", "install", package, "--root-user-action=ignore"]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✅ {package} berhasil diinstall")
        else:
            print(f"❌ Gagal menginstall {package}")
            print(result.stderr)
            sys.exit(1)
            
    except Exception as e:
        print(f"❌ Error saat menginstall: {e}")
        sys.exit(1)
    print(f"✅ {package} berhasil diinstall")

# FUNCTIONS FOR MENU
@is_option
def IP_Track():
    ip = input(f"{Wh}\n Masukan IP Target : {Gr}")
    print()
    req_api = requests.get(f"http://ipwho.is/{ip}")
    ip_data = json.loads(req_api.text)
    ipify_response = requests.get(
        "https://geo.ipify.org/api/v2/country,city,vpn",
        params={
            "apiKey": "at_jQwfo2synUQrH1NHD2iikngUiIZcR",
            "ipAddress": ip,
        },
        timeout=10,
    )
    ipify_data = ipify_response.json()
    time.sleep(1)

    print_panel("IP TRACKER", f"Target: {ip}", icon="🌐")
    print_info_row("IP Target", ip)
    print_info_row("Tipe IP", ip_data.get("type", "-"))
    print_info_row("Negara", ip_data.get("country", "-"))
    print_info_row("Kode Negara", ip_data.get("country_code", "-"))
    print_info_row("Kota", ip_data.get("city", "-"))
    print_info_row("Benua", ip_data.get("continent", "-"))
    print_info_row("Wilayah", ip_data.get("region", "-"))

    ipify_location = ipify_data.get("location", {})
    ipify_as = ipify_data.get("as", {})
    ipify_proxy = ipify_data.get("proxy", {})
    print_info_row("Geo IPify", ipify_data.get("ip", "-"))
    print_info_row("Kota IPify", ipify_location.get("city", "-"))
    print_info_row("Negara IPify", ipify_location.get("country", "-"))
    print_info_row("ISP IPify", ipify_data.get("isp", "-"))
    print_info_row("ASN IPify", ipify_as.get("asn", "-"))
    print_info_row("Proxy", "Ya" if ipify_proxy.get("proxy", False) else "Tidak")
    print_info_row("VPN", "Ya" if ipify_proxy.get("vpn", False) else "Tidak")
    print_info_row("Tor", "Ya" if ipify_proxy.get("tor", False) else "Tidak")

    lat_raw = ip_data.get('latitude')
    lon_raw = ip_data.get('longitude')
    try:
        lat = float(lat_raw)
        lon = float(lon_raw)
        map_url = f"https://www.google.com/maps/@{lat},{lon},8z"
    except Exception:
        map_url = "-"
    print_info_row("Lokasi", map_url)

    flag_data = ip_data.get("flag", {})
    conn = ip_data.get("connection", {})
    tz = ip_data.get("timezone", {})
    print_info_row("EU", ip_data.get("is_eu", "-"))
    print_info_row("Postal", ip_data.get("postal", "-"))
    print_info_row("Calling Code", ip_data.get("calling_code", "-"))
    print_info_row("Capital", ip_data.get("capital", "-"))
    print_info_row("Flag", flag_data.get("emoji", "-"))
    print_info_row("ASN", conn.get("asn", "-"))
    print_info_row("ORG", conn.get("org", "-"))
    print_info_row("ISP", conn.get("isp", "-"))
    print_info_row("Domain", conn.get("domain", "-"))
    print_info_row("Timezone", tz.get("id", "-"))
    print_info_row("UTC", tz.get("utc", "-"))
    print_info_row("Current Time", tz.get("current_time", "-"))


@is_option
def phoneGW():
    print(f"\n {Ye}💡 Contoh format nomor internasional:{RESET}")
    print(f"    {Wh}Indonesia     : {Gr}+6281234567890")
    print(f"    {Wh}Malaysia      : {Gr}+60123456789")
    print(f"    {Wh}Singapura     : {Gr}+6591234567")
    print(f"    {Wh}Thailand      : {Gr}+66812345678")
    print(f"    {Wh}Filipina      : {Gr}+639171234567")
    print(f"    {Wh}Vietnam       : {Gr}+84912345678")
    print(f"    {Wh}India         : {Gr}+919876543210")
    print(f"    {Wh}Jepang        : {Gr}+819012345678")
    print(f"    {Wh}Korea Selatan : {Gr}+821012345678")
    print(f"    {Wh}China         : {Gr}+8613812345678")
    print(f"    {Wh}Amerika       : {Gr}+14152345678")
    print(f"    {Wh}UK            : {Gr}+447911123456")
    User_phone = input(f"\n {Wh}Masukan Nomor Target Anda {Wh}: {Gr}")
    default_region = "ID"

    parsed_number = phonenumbers.parse(User_phone, default_region)
    region_code = phonenumbers.region_code_for_number(parsed_number)
    jenis_provider = carrier.name_for_number(parsed_number, "en")
    location = geocoder.description_for_number(parsed_number, "id")
    is_valid_number = phonenumbers.is_valid_number(parsed_number)
    is_possible_number = phonenumbers.is_possible_number(parsed_number)
    formatted_number = phonenumbers.format_number(parsed_number, phonenumbers.PhoneNumberFormat.INTERNATIONAL)
    formatted_number_for_mobile = phonenumbers.format_number_for_mobile_dialing(parsed_number, default_region,
                                                                                with_formatting=True)
    number_type = phonenumbers.number_type(parsed_number)
    timezone1 = timezone.time_zones_for_number(parsed_number)
    timezoneF = ', '.join(timezone1)

    print_panel("PHONE TRACKER", f"Nomor: {User_phone}", icon="📞")
    print_info_row("Negara", location)
    print_info_row("Kode Negara", region_code)
    print_info_row("Timezone", timezoneF)
    print_info_row("Kartu Phone", jenis_provider)
    print_info_row("Valid Number", is_valid_number)
    print_info_row("Possible Number", is_possible_number)
    print_info_row("International", formatted_number)
    print_info_row("Mobile Format", formatted_number_for_mobile)
    print_info_row("Type", "Mobile" if number_type == phonenumbers.PhoneNumberType.MOBILE else "Fixed-line" if number_type == phonenumbers.PhoneNumberType.FIXED_LINE else "Other")

@is_option
def TrackLu():
    try:
        username = input(f"\n {Wh}Enter Username : {Gr}")
        results = {}
        social_media = [
            {"url": "https://www.facebook.com/{}", "name": "Facebook"},
            {"url": "https://www.twitter.com/{}", "name": "Twitter"},
            {"url": "https://www.instagram.com/{}", "name": "Instagram"},
            {"url": "https://www.linkedin.com/in/{}", "name": "LinkedIn"},
            {"url": "https://www.github.com/{}", "name": "GitHub"},
            {"url": "https://www.pinterest.com/{}", "name": "Pinterest"},
            {"url": "https://www.tumblr.com/{}", "name": "Tumblr"},
            {"url": "https://www.youtube.com/{}", "name": "Youtube"},
            {"url": "https://soundcloud.com/{}", "name": "SoundCloud"},
            {"url": "https://www.snapchat.com/add/{}", "name": "Snapchat"},
            {"url": "https://www.tiktok.com/@{}", "name": "TikTok"},
            {"url": "https://www.behance.net/{}", "name": "Behance"},
            {"url": "https://www.medium.com/@{}", "name": "Medium"},
            {"url": "https://www.quora.com/profile/{}", "name": "Quora"},
            {"url": "https://www.flickr.com/people/{}", "name": "Flickr"},
            {"url": "https://www.periscope.tv/{}", "name": "Periscope"},
            {"url": "https://www.twitch.tv/{}", "name": "Twitch"},
            {"url": "https://www.dribbble.com/{}", "name": "Dribbble"},
            {"url": "https://www.stumbleupon.com/stumbler/{}", "name": "StumbleUpon"},
            {"url": "https://www.ello.co/{}", "name": "Ello"},
            {"url": "https://www.producthunt.com/@{}", "name": "Product Hunt"},
            {"url": "https://www.snapchat.com/add/{}", "name": "Snapchat"},
            {"url": "https://www.telegram.me/{}", "name": "Telegram"},
            {"url": "https://www.weheartit.com/{}", "name": "We Heart It"}
        ]
        for site in social_media:
            url = site['url'].format(username)
            try:
                response = requests.get(url, timeout=8)
                if response.status_code == 200:
                    results[site['name']] = url
                else:
                    results[site['name']] = f"{Ye}Username not found{RESET}"
            except requests.exceptions.RequestException:
                results[site['name']] = f"{Ye}Connection failed{RESET}"
    except Exception as e:
        print(f"{Re}Error : {e}")
        return

    print_panel("USERNAME TRACKER", f"Target: {username}", icon="👤")
    for site, url in results.items():
        status = "✓" if "not found" not in str(url).lower() else "✗"
        color = Gr if status == "✓" else Re
        print(f"{colorize(status, color)} {colorize(site, Cy)} {colorize('•', Ye)} {colorize(url, Wh)}")


@is_option
def showIP():
    respone = requests.get('https://api.ipify.org/', timeout=10)
    respone_ipv6 = requests.get('https://api64.ipify.org', timeout=10)
    Show_IP = respone.text.strip()
    Show_IPv6 = respone_ipv6.text.strip()

    print_panel("PUBLIC IP", f"Alamat Anda: {Show_IP}", icon="🧭")
    print_info_row("IP4 Anda", Show_IP)
    print_info_row("IP6 Anda", Show_IPv6)


# OPTIONS
options = [
    {
        'num': 1,
        'text': 'Melacak Dengan IP',
        'func': IP_Track
    },
    {
        'num': 2,
        'text': 'Memunculkan IP anda',
        'func': showIP

    },
    {
        'num': 3,
        'text': 'Track Pakai Nomor',
        'func': phoneGW
    },
    {
        'num': 4,
        'text': 'Username Target',
        'func': TrackLu
    },
    {
        'num': 0,
        'text': 'exit',
        'func': exit
    }
]


def clear():
    # for windows
    if os.name == 'nt':
        _ = os.system('cls')
    # for mac and linux
    else:
        _ = os.system('clear')


def call_option(opt):
    if not is_in_options(opt):
        raise ValueError('Option not found')
    for option in options:
        if option['num'] == opt:
            if 'func' in option:
                option['func']()
            else:
                print('No function detected')


def execute_option(opt):
    try:
        call_option(opt)
        input(f'\n{Wh}[ {Gr}+ {Wh}] {Gr}Press enter to continue')
        main()
    except ValueError as e:
        print(e)
        time.sleep(2)
        execute_option(opt)
    except KeyboardInterrupt:
        print(f'\n{Wh}[ {Re}! {Wh}] {Re}Exit')
        time.sleep(2)
        exit()
    except EOFError:
        print(f'\n{Wh}[ {Ye}! {Wh}] {Ye}Input selesai, keluar...')
        time.sleep(1)
        exit()


def option_text():
    lines = [
        f"{Cy}┌─────┬──────────────────────────────┐",
        f"{Cy}│ {BOLD}No{RESET}{Cy}  │ {BOLD}Menu{RESET}{Cy}                         │",
        f"{Cy}├─────┼──────────────────────────────┤",
    ]
    for opt in options:
        lines.append(f"{Cy}│ {Wh}{opt['num']:<2}{Cy}  │ {Wh}{opt['text']:<28}{Cy} │")
    lines.append(f"{Cy}└─────┴──────────────────────────────┘")
    return "\n".join(lines)


def is_in_options(num):
    for opt in options:
        if opt['num'] == num:
            return True
    return False


def option():
    clear()
    print(colorize("╔══════════════════════════════════════╗", Mage))
    print(colorize("║  🌐 TRACKING TOOLKIT                 ║", BOLD + Mage))
    print(colorize("║  ⚡ IP • Phone • Username            ║", Ye))
    print(colorize("╚══════════════════════════════════════╝", Mage))
    print()
    print(option_text())



def run_banner():
    clear()
    time.sleep(0.5)
    print(colorize("╭──────────────────────────────────╮", Cy))
    print(colorize("│  🔎 TrackingTool                 │", BOLD + Gr))
    print(colorize("│  ⚡ Powered by jaringan_vpn      │", Ye))
    print(colorize("╰──────────────────────────────────╯", Cy))
    time.sleep(0.3)


def main():
    clear()
    option()
    time.sleep(1)
    try:
        opt = int(input(f"{Wh}\n [ + ] {Gr}Select Option : {Wh}"))
        execute_option(opt)
    except ValueError:
        print(f'\n{Wh}[ {Re}! {Wh}] {Re}Please input number')
        time.sleep(2)
        main()


if __name__ == '__main__':
    try:
        install_package("requests")
        install_package("phonenumbers")
        main()
    except KeyboardInterrupt:
        print(f'\n{Wh}[ {Re}! {Wh}] {Re}Exit')
        time.sleep(2)
        exit()
