#!/usr/bin/env python3
"""Cari hostname/domain publik yang berkaitan dengan sebuah alamat IPv4."""

from __future__ import annotations

import ipaddress
import socket
import sys
from pathlib import Path

import requests


TIMEOUT = 15
REVERSE_IP_API = "https://api.hackertarget.com/reverseiplookup/"
OUTPUT_DIR = Path("hasil_ip_to_host")


def save_results(ip: str, lines: list[str]) -> Path:
	"""Simpan baris hasil ke file teks; buat direktori bila belum ada."""
	OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
	output_file = OUTPUT_DIR / f"{ip}.txt"
	output_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
	return output_file


def validate_ipv4(value: str) -> ipaddress.IPv4Address:
	"""Validasi input dan kembalikan objek IPv4Address."""
	address = ipaddress.ip_address(value.strip())
	if not isinstance(address, ipaddress.IPv4Address):
		raise ValueError("Alamat yang dimasukkan bukan IPv4.")
	return address


def reverse_dns(ip: str) -> set[str]:
	"""Ambil hostname PTR dan alias melalui resolver sistem."""
	try:
		hostname, aliases, _ = socket.gethostbyaddr(ip)
	except (socket.herror, socket.gaierror, TimeoutError):
		return set()

	return {name.rstrip(".").lower() for name in [hostname, *aliases] if name}


def reverse_ip_lookup(ip: str) -> set[str]:
	"""Ambil domain terkait dari layanan reverse-IP publik."""
	response = requests.get(REVERSE_IP_API, params={"q": ip}, timeout=TIMEOUT)
	response.raise_for_status()

	body = response.text.strip()
	lowered = body.lower()
	if not body or lowered.startswith(("error", "api count exceeded", "no records")):
		return set()

	return {
		line.strip().rstrip(".").lower()
		for line in body.splitlines()
		if line.strip() and " " not in line.strip()
	}


def resolves_to_ip(hostname: str, target_ip: str) -> bool:
	"""Periksa apakah hostname saat ini masih resolve ke target IPv4."""
	try:
		addresses = {
			item[4][0]
			for item in socket.getaddrinfo(hostname, None, socket.AF_INET)
		}
	except socket.gaierror:
		return False
	return target_ip in addresses


def main() -> int:
	print("=" * 58)
	print("             IPv4 TO HOSTNAME LOOKUP")
	print("=" * 58)

	try:
		address = validate_ipv4(input("Masukkan alamat IPv4: "))
	except ValueError as exc:
		print(f"[ERROR] {exc}")
		return 1

	ip = str(address)
	print(f"\n[INFO] Mencari hostname yang terkait dengan {ip} ...")

	ptr_hosts = reverse_dns(ip)
	try:
		api_hosts = reverse_ip_lookup(ip) if address.is_global else set()
	except requests.RequestException as exc:
		print(f"[PERINGATAN] Reverse-IP lookup gagal: {exc}")
		api_hosts = set()

	hosts = sorted(ptr_hosts | api_hosts)
	lines: list[str] = []

	if not hosts:
		lines.append("[HASIL] Tidak ada hostname publik yang ditemukan.")
		if not address.is_global:
			lines.append("[INFO] Reverse-IP publik dilewati karena IP bukan alamat global.")
	else:
		lines.append(f"Ditemukan {len(hosts)} hostname/domain:")
		lines.append("-" * 58)
		for number, host in enumerate(hosts, start=1):
			source = "PTR" if host in ptr_hosts else "reverse-IP"
			status = "terverifikasi" if resolves_to_ip(host, ip) else "historis/tidak langsung"
			lines.append(f"{number:>3}. {host:<38} [{source}; {status}]")
		lines.append("")
		lines.append("Catatan: hasil reverse-IP dapat tidak lengkap atau bersifat historis.")
		lines.append("Satu IP CDN/shared hosting juga dapat digunakan banyak domain.")

	print("\n".join(lines))

	output_file = save_results(ip, lines)
	print(f"\n[INFO] Hasil disimpan di: {output_file}")
	return 0


if __name__ == "__main__":
	try:
		raise SystemExit(main())
	except KeyboardInterrupt:
		print("\nDibatalkan oleh pengguna.")
		sys.exit(130)
