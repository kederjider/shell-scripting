#!/bin/bash
set -e

# ==============================
# CONFIG
# ==============================
GO_VERSION="1.23.6"
TOOLS_DIR="$HOME/tools"
SECLIST_DIR="$TOOLS_DIR/SecLists"

# ==============================
# COLOR
# ==============================
log() { echo -e "\e[32m[+] $1\e[0m"; }
warn() { echo -e "\e[33m[!] $1\e[0m"; }
err() { echo -e "\e[31m[-] $1\e[0m"; }

# ==============================
# CHECK ROOT
# ==============================
if [ "$EUID" -ne 0 ]; then
    warn "Some installs may require sudo password"
fi

# ==============================
# UPDATE SYSTEM
# ==============================
log "Updating system..."
sudo apt update -y

# ==============================
# INSTALL BASE
# ==============================
log "Installing base packages..."
sudo apt install -y curl wget git unzip build-essential jq libpcap-dev

# ==============================
# REMOVE OLD GO
# ==============================
log "Removing old Go..."
sudo apt remove golang-go -y || true
sudo rm -rf /usr/local/go

# ==============================
# INSTALL GO
# ==============================
log "Installing Go $GO_VERSION ..."
cd /tmp
wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH
hash -r

if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
    echo 'export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH' >> ~/.bashrc
fi

log "Go version: $(go version)"

# ==============================
# INSTALL RECON TOOLS
# ==============================
log "Installing recon tools..."

go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/owasp-amass/amass/v4/...@master

hash -r

# ==============================
# INSTALL SECLISTS
# ==============================
log "Installing SecLists..."
mkdir -p $TOOLS_DIR

if [ ! -d "$SECLIST_DIR" ]; then
    git clone https://github.com/danielmiessler/SecLists.git $SECLIST_DIR
else
    warn "SecLists already exists"
fi

# ==============================
# UPDATE NUCLEI
# ==============================
log "Updating nuclei templates..."
nuclei -update-templates || true

log "insatlling subdomain-finder..."
log "suksesfully installed..."