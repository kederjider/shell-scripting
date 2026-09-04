#!/usr/local/bin/.venv/bin/python

import requests
from urllib.parse import urlparse

url = input("Masukkan URL atau domain yang ingin dianalisis: ").strip()

# Jika skema tidak ditulis, gunakan HTTPS secara otomatis.
if "://" not in url:
    url = f"https://{url}"

# Validasi sederhana
parsed = urlparse(url)
if parsed.scheme not in ("http", "https") or not parsed.netloc:
    raise ValueError("URL tidak valid.")

print(f"URL lengkap  : {url}")

headers = {
    "User-Agent": "Mozilla/5.0 (compatible; PhishingAnalyzer/1.0)"
}

try:
    response = requests.get(
        url,
        headers=headers,
        timeout=15,
        allow_redirects=False,  # jangan otomatis mengikuti redirect
        verify=True
    )

    print(f"Status       : {response.status_code}")
    print(f"Content-Type : {response.headers.get('Content-Type')}")
    print(f"Server       : {response.headers.get('Server')}")
    print(f"Location     : {response.headers.get('Location')}")

    content_type = response.headers.get("Content-Type", "").lower()

    if "text/html" in content_type:
        html = response.text

        with open("hasil.html", "w", encoding="utf-8") as f:
            f.write(html)

        print(f"Panjang HTML : {len(html):,} karakter")
        print("HTML disimpan sebagai: hasil.html")
    else:
        print("Respons bukan HTML, sehingga tidak disimpan sebagai halaman HTML.")

except requests.exceptions.SSLError:
    print("SSL/TLS certificate bermasalah.")
except requests.exceptions.Timeout:
    print("Request timeout.")
except requests.exceptions.RequestException as e:
    print(f"Request gagal: {e}")
