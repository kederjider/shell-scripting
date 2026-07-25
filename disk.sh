#!/bin/bash

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Function untuk membuat progress bar
make_progress_bar() {
    local percent=$1
    local width=15
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    printf "["
    for ((i=0; i<filled; i++)); do
        if [ "$percent" -ge 80 ]; then
            printf "${RED}█${NC}"
        elif [ "$percent" -ge 60 ]; then
            printf "${YELLOW}█${NC}"
        else
            printf "${GREEN}█${NC}"
        fi
    done
    for ((i=0; i<empty; i++)); do
        printf "░"
    done
    printf "]"
}

# Header
echo ""
echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║                                    💾 DISK USAGE MONITOR v2.0 💾                                              ║${NC}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Column headers
printf "${BOLD}${CYAN}%-22s${NC} "
printf "${BOLD}${CYAN}%-30s${NC} "
printf "${BOLD}${CYAN}%-12s${NC} "
printf "${BOLD}${CYAN}%-12s${NC} "
printf "${BOLD}${CYAN}%-12s${NC} "
printf "${BOLD}${CYAN}%-35s${NC} "
printf "${BOLD}${CYAN}%-8s${NC}\n"
echo "Filesystem" "Mount Point" "Size" "Used" "Avail" "Usage" "Percent"

echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Get disk data
df -h | tail -n +2 | while read line; do
    filesystem=$(echo $line | awk '{print $1}')
    size=$(echo $line | awk '{print $2}')
    used=$(echo $line | awk '{print $3}')
    avail=$(echo $line | awk '{print $4}')
    usepercent=$(echo $line | awk '{print $5}' | sed 's/%//')
    mounted=$(echo $line | awk '{print $6}')
    
    # Determine icon based on filesystem and mount point
    if [[ $filesystem == *"loop"* ]]; then
        icon="🔄"
    elif [[ $filesystem == *"tmpfs"* ]]; then
        icon="⚡"
    elif [[ $filesystem == *"devfs"* ]]; then
        icon="⚙️ "
    elif [[ $mounted == "/" ]]; then
        icon="🖥️ "
    elif [[ $mounted == "/home" ]]; then
        icon="🏠"
    elif [[ $mounted == "/boot" ]]; then
        icon="🔧"
    elif [[ $mounted == "/var" ]]; then
        icon="📊"
    else
        icon="📁"
    fi
    
    # Print filesystem info
    printf "$icon %-20s " "$filesystem"
    printf "${BOLD}${BLUE}%-28s${NC} " "$mounted"
    printf "${BOLD}%-12s${NC} " "$size"
    printf "${BOLD}%-12s${NC} " "$used"
    printf "${GREEN}%-12s${NC} " "$avail"
    
    # Create progress bar
    bar=$(make_progress_bar "$usepercent")
    printf "%s " "$bar"
    
    # Print percentage with color
    if [ "$usepercent" -ge 80 ]; then
        printf "${RED}${BOLD}%3d%%${NC}\n" "$usepercent"
    elif [ "$usepercent" -ge 60 ]; then
        printf "${YELLOW}${BOLD}%3d%%${NC}\n" "$usepercent"
    else
        printf "${GREEN}${BOLD}%3d%%${NC}\n" "$usepercent"
    fi
done

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Summary
echo -e "${BOLD}${MAGENTA}📊 LEGEND & INFORMASI${NC}"
echo -e "${CYAN}────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "  ${BOLD}${GREEN}🟢 OK${NC}         : Penggunaan disk < 60%"
echo -e "  ${BOLD}${YELLOW}🟡 WARNING${NC}   : Penggunaan disk 60% - 80%"
echo -e "  ${BOLD}${RED}🔴 CRITICAL${NC}  : Penggunaan disk > 80%"
echo ""
echo -e "  ${BOLD}${CYAN}Icon Guide:${NC}"
echo -e "    🖥️  = Root / Sistem Utama"
echo -e "    🏠 = Home Directory"
echo -e "    ⚡ = Temporary/RAM Filesystem"
echo -e "    🔧 = Boot Partition"
echo -e "    📊 = Var Directory"
echo -e "    🔄 = Loop Device"
echo -e "    📁 = Other Partitions"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Last update timestamp
echo -e "${BOLD}${MAGENTA}📅 Last Updated:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""