#!/bin/bash

# Version: 2.0 
# Author: @XenonNet

clear

# ANSI Colors - Basic ASCII compatible
R='\033[0;31m'    # Red
G='\033[0;32m'    # Green
Y='\033[0;33m'    # Yellow
B='\033[0;34m'    # Blue
C='\033[0;36m'    # Cyan
W='\033[1;37m'    # White
D='\033[0;90m'    # Dark Gray
N='\033[0m'       # Reset

# Global Data Storage
declare -A SYS
declare -A NET
declare -A MIR
declare -a DNS_LIST
declare -a MIRROR_LIST

# Professional Progress Bar with ETA
progress_bar() {
    local msg="$1"
    local total_time="$2"
    local width=25
    local delay=$(echo "scale=3; $total_time/100" | bc -l 2>/dev/null || echo "0.05")
    
    printf "%-30s " "$msg"
    
    for ((i=0; i<=100; i++)); do
        local filled=$((i*width/100))
        local empty=$((width-filled))
        local eta=$(echo "scale=1; ($total_time - $i * $total_time / 100)" | bc -l 2>/dev/null || echo "0")
        
        printf "\r%-30s [" "$msg"
        printf "${G}%${filled}s${N}" | tr ' ' '#'
        printf "%${empty}s" | tr ' ' '-'
        printf "] %3d%% " "$i"
        
        if [ $i -lt 100 ]; then
            printf "ETA: %.1fs " "$eta"
        else
            printf "${G}COMPLETE${N} "
        fi
        
        sleep $delay
    done
    echo
}

# Compact Header
header() {
    echo -e "${B}+=========================================+${N}"
    echo -e "${B}|${N}                  ${W}Sys helper${N}                  ${B}|${N}"
    echo -e "${B}|${N}                  ${D}Version 2.0${N}                 ${B}|${N}"
    echo -e "${B}|${N}                  ${D}By @XenonNET${N}                 ${B}|${N}"
    echo -e "${B}+=========================================+${N}"
}

# Data Collection Functions
collect_dns() {
    DNS_LIST=()
    if [ -f /etc/resolv.conf ]; then
        while read -r line; do
            if [[ $line == nameserver* ]]; then
                DNS_LIST+=($(echo "$line" | awk '{print $2}'))
            fi
        done < <(grep "^nameserver" /etc/resolv.conf)
    fi
}

collect_system() {
    SYS[cpu]=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//' | cut -c1-30)
    SYS[cores]=$(nproc)
    SYS[usage]=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "0")
    SYS[ram_total]=$(free -h | grep "Mem:" | awk '{print $2}')
    SYS[ram_used]=$(free -h | grep "Mem:" | awk '{print $3}')
    SYS[ram_percent]=$(free | grep "Mem:" | awk '{printf "%.0f", ($3/$2)*100.0}')
    SYS[load]=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//' | cut -d',' -f1)
    SYS[uptime]=$(uptime -p 2>/dev/null | sed 's/up //' || echo "Unknown")
}

collect_network() {
    local data=$(curl -s --connect-timeout 5 http://ip-api.com/json 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$data" ]; then
        NET[ip]=$(echo "$data" | grep -o '"query":"[^"]*' | cut -d'"' -f4)
        NET[country]=$(echo "$data" | grep -o '"country":"[^"]*' | cut -d'"' -f4)
        NET[city]=$(echo "$data" | grep -o '"city":"[^"]*' | cut -d'"' -f4)
        NET[isp]=$(echo "$data" | grep -o '"isp":"[^"]*' | cut -d'"' -f4)
        NET[status]="ok"
    else
        NET[status]="fail"
    fi
}

collect_mirror() {
    local version=$(lsb_release -sr 2>/dev/null | cut -d '.' -f 1)
    if [[ "$version" -ge 24 ]] 2>/dev/null && [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
        MIR[current]=$(grep -m1 "URIs:" /etc/apt/sources.list.d/ubuntu.sources | awk '{print $2}')
    elif [ -f /etc/apt/sources.list ]; then
        MIR[current]=$(grep -m1 "^deb " /etc/apt/sources.list | awk '{print $2}')
    else
        MIR[current]="Not Found"
    fi
    MIR[version]=$(lsb_release -sr 2>/dev/null || echo 'Unknown')
}

# Compact Display Functions
show_info() {
    # Prepare DNS string
    local dns_str=""
    if [ ${#DNS_LIST[@]} -gt 0 ]; then
        dns_str="${DNS_LIST[0]}"
        [ ${#DNS_LIST[@]} -gt 1 ] && dns_str="$dns_str, ${DNS_LIST[1]}"
    else
        dns_str="Not configured"
    fi
    
    # Define labels and values
    local labels=(
        "CPU"
        "Performance"
        "Memory"
        "Uptime"
        "DNS"
        "IP Address"
        "Location"
        "Provider"
        "APT Mirror"
        "Ubuntu Version"
    )
    
    local values=(
        "${SYS[cpu]}"
        "Cores: ${G}${SYS[cores]}${N} | Usage: ${Y}${SYS[usage]}%${N} | Load: ${C}${SYS[load]}${N}"
        "${B}${SYS[ram_used]}${N} / ${C}${SYS[ram_total]}${N} (${Y}${SYS[ram_percent]}%${N})"
        "${SYS[uptime]}"
        "$dns_str"
        "${G}${NET[ip]} (DNS: $dns_str)${N}"
        "${NET[city]}, ${NET[country]}"
        "${NET[isp]}"
        "$(echo "${MIR[current]}" | sed 's|https\?://||')"
        "${C}${MIR[version]}${N}"
    )
    
    # Calculate maximum lengths
    local max_label_len=0
    local max_value_len=0
    
    for label in "${labels[@]}"; do
        local len=${#label}
        [ $len -gt $max_label_len ] && max_label_len=$len
    done
    
    for value in "${values[@]}"; do
        # Strip color codes for length calculation
        local clean_value=$(echo -e "$value" | sed 's/\x1B\[[0-9;]*[mK]//g')
        local len=${#clean_value}
        [ $len -gt $max_value_len ] && max_value_len=$len
    done
    
    # Add padding
    max_label_len=$((max_label_len + 1))
    max_value_len=$((max_value_len + 1))
    
    # Calculate total width
    local total_width=$((max_label_len + max_value_len + 3)) # 3 for borders and separator
    
    # Print header
    echo -e "\n${Y}SYSTEM OVERVIEW${N}"
    printf "+%s+\n" "$(printf '%*s' $total_width '' | tr ' ' '-')"
    
    # Print rows
    for ((i=0; i<${#labels[@]}; i++)); do
        local label="${labels[$i]}"
        local value="${values[$i]}"
        
        # Handle network status case
        if [ "$label" = "IP Address" ] && [ "${NET[status]}" = "fail" ]; then
            printf "| %-${max_label_len}s| %-${max_value_len}s |\n" "Network Status" "${R}Unavailable${N}"
            continue
        fi
        
        # Strip color codes for alignment, then print with colors
        local clean_value=$(echo -e "$value" | sed 's/\x1B\[[0-9;]*[mK]//g')
        printf "| %-${max_label_len}s| %-${max_value_len}s |\n" "$label" "$(echo -e "$value")"
    done
    
    # Print footer
    printf "+%s+\n" "$(printf '%*s' $total_width '' | tr ' ' '-')"
}

# Mirror Speed Test
test_speed() {
    local url=$1
    local result=$(wget --timeout=5 --tries=1 -O /dev/null $url 2>&1 | grep -o '[0-9.]* [KM]B/s' | tail -1)
    if [[ -z $result ]]; then
        echo "0"
    else
        if [[ $result == *K* ]]; then
            echo $(echo $result | sed 's/ KB\/s//')
        elif [[ $result == *M* ]]; then
            echo $(echo "scale=0; $(echo $result | sed 's/ MB\/s//') * 1024" | bc)
        fi
    fi
}

test_mirrors() {
    echo -e "\n${W}MIRROR SPEED TEST${N}"
    echo -e "+==============================================================+"
    
    local mirrors=(
        "https://ubuntu.pishgaman.net/ubuntu"
        "http://mirror.aminidc.com/ubuntu"
        "https://ubuntu.pars.host"
        "https://ir.ubuntu.sindad.cloud/ubuntu"
        "https://ubuntu.shatel.ir/ubuntu"
        "https://ubuntu.mobinhost.com/ubuntu"
        "https://mirror.iranserver.com/ubuntu"
        "https://mirror.arvancloud.ir/ubuntu"
        "http://ir.archive.ubuntu.com/ubuntu"
        "https://ubuntu.parsvds.com/ubuntu/"
    )
    
    MIRROR_LIST=()
    
    echo
    progress_bar "Testing mirrors" 10
    
    for mirror in "${mirrors[@]}"; do
        local speed=$(test_speed "$mirror")
        MIRROR_LIST+=("$speed|$mirror")
    done
    
    IFS=$'\n' MIRROR_LIST=($(printf '%s\n' "${MIRROR_LIST[@]}" | sort -t'|' -k1 -nr))
    
    local max_rank_len=3
    local max_speed_len=10
    local max_mirror_len=0
    
    for result in "${MIRROR_LIST[@]}"; do
        local mirror=$(echo "$result" | cut -d'|' -f2 | sed 's|https\?://||')
        local len=${#mirror}
        [ $len -gt $max_mirror_len ] && max_mirror_len=$len
    done
    max_mirror_len=$((max_mirror_len + 2))
    
    echo -e "\n${Y}RESULTS${N} (Ranked by Speed)"
    local total_width=$((max_rank_len + max_speed_len + max_mirror_len + 11))
    printf "+%s+\n" "$(printf '%*s' $total_width '' | tr ' ' '-')"
    printf "| %-${max_rank_len}s | %-${max_speed_len}s | %-${max_mirror_len}s |\n" "#" "Speed" "Mirror URL"
    printf "+%s+\n" "$(printf '%*s' $total_width '' | tr ' ' '-')"
    
    local rank=1
    local best_mirror=""
    local best_speed=0
    
    for result in "${MIRROR_LIST[@]}"; do
        local speed=$(echo "$result" | cut -d'|' -f1)
        local mirror=$(echo "$result" | cut -d'|' -f2)
        local short=$(echo "$mirror" | sed 's|https\?://||')
        
        if [ "$rank" -eq 1 ] && [ "$speed" != "0" ]; then
            best_mirror="$mirror"
            best_speed="$speed"
        fi
        
        if [ "$speed" == "0" ]; then
            printf "| ${D}%-${max_rank_len}d${N} | ${R}%-${max_speed_len}s${N} | %-${max_mirror_len}s |\n" "$rank" "Failed" "$short"
        else
            local mbps=$(echo "scale=1; $speed / 128" | bc)
            printf "| ${W}%-${max_rank_len}d${N} | ${G}%-${max_speed_len}s${N} | %-${max_mirror_len}s |\n" "$rank" "$mbps Mb/s" "$short"
        fi
        rank=$((rank + 1))
    done
    
    printf "+%s+\n" "$(printf '%*s' $total_width '' | tr ' ' '-')"
    
    if [ -n "$best_mirror" ] && [ "$best_speed" != "0" ]; then
        local best_mbps=$(echo "scale=1; $best_speed / 128" | bc)
        echo -e "\n${G}+ Best Mirror:${N} ${best_mirror}"
        echo -e "${G}+ Speed:${N} ${best_mbps} Mb/s"
        echo -ne "\n${Y}Apply this mirror? [y/N]:${N} "
        read -r answer
        
        if [[ $answer =~ ^[Yy]$ ]]; then
            echo
            progress_bar "Configuring mirror" 3
            
            local version=$(lsb_release -sr 2>/dev/null | cut -d '.' -f 1)
            if [[ "$version" -ge 24 ]] 2>/dev/null; then
                sudo sed -i "s|URIs: https\?://[^ ]*|URIs: $best_mirror|g" /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null
            else
                sudo sed -i "s|https\?://[^ ]*|$best_mirror|g" /etc/apt/sources.list 2>/dev/null
            fi
            
            progress_bar "Updating package index" 5
            sudo apt-get update >/dev/null 2>&1
            echo -e "\n${G}+ Mirror configuration updated${N}"
        fi
    else
        echo -e "\n${R}[X] No working mirrors found${N}"
    fi
}

# 3X-UI Installation
install_3x_ui() {
    echo -e "\n${W}3X-UI INSTALLATION${N}"
    echo -e "+==============================================================+"
    echo -e "| Package: 3X-UI Panel                                         |"
    echo -e "| Version: 2.6.0                                               |"
    echo -e "| Type:    Automated Installation                              |"
    echo -e "+==============================================================+"
    
    echo -ne "\n${Y}Proceed? [y/N]:${N} "
    read -r confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        local temp="/tmp/3x-ui-install"
        local url="https://uploadkon.ir/uploads/973126_25package-tar.gz"
        
        echo
        progress_bar "Preparing" 2
        mkdir -p "$temp" && cd "$temp"
        
        progress_bar "Downloading" 8
        if wget -q "$url" -O package.tar.gz; then
            echo -e "${G}[+] Download complete${N}"
        else
            echo -e "${R}[X] Download failed${N}"
            return 1
        fi
        
        progress_bar "Extracting" 3
        tar -xzf package.tar.gz >/dev/null 2>&1

        nested=$(find . -type f -name "*.tar*" | head -n 1)
        if [ -n "$nested" ]; then
            tar -xf "$nested" >/dev/null 2>&1
        fi

        files_to_move=$(find . -type f \( -name "x-ui-linux-*.tar.gz" -o -name "install.sh" -o -name "*.sh" \))
        for f in $files_to_move; do
            cp -f "$f" /root/
        done

        if [ -f /root/install.sh ]; then
            chmod +x /root/install.sh
            echo -e "\n${C}Launching installer...${N}"
            echo "+-------------------------------------------+"
            bash /root/install.sh
            echo "+-------------------------------------------+"
            echo -e "${G}[+] Installation complete${N}"
        else
            echo -e "${R}[X] Installer not found in /root${N}"
        fi


        
        cd - >/dev/null && rm -rf "$temp"
    fi
}

# Compact Menu
menu() {
    echo -e "\n${W}MAIN MENU${N}"
    echo -e "| ${G}1${N}. Best Mirror      |"
    echo -e "| ${G}2${N}. Install 3X-UI    |"
    echo -e "| ${G}3${N}. Refresh Info     |"
    echo -e "| ${G}4${N}. Exit             |"
}

# Main Application
main() {
    local status
    if [[ $EUID -eq 0 ]]; then
        status="${R}ROOT${N}"
    else
        status="${G}USER${N}"
    fi
    
    header
    echo
    progress_bar "Initializing" 3
    
    collect_dns
    collect_system
    collect_network
    collect_mirror
    
    show_info
    
    while true; do
        menu
        echo -ne "\n[$status] Select (1-4): "
        read -r choice
        
        case $choice in
            1)
                test_mirrors
                echo -e "\n${D}Press Enter to continue...${N}"
                read -r
                clear && header && show_info
                ;;
            2)
                install_3x_ui
                echo -e "\n${D}Press Enter to continue...${N}"
                read -r
                clear && header && show_info
                ;;
            3)
                clear && header
                echo
                progress_bar "Refreshing" 2
                collect_dns
                collect_system
                collect_network 
                collect_mirror
                show_info
                ;;
            4)
                echo -e "\n${G}Thank you for using Enterprise System Analyzer${N}"
                echo -e "${D}Version 2.0 Pro - @Mrlte${N}\n"
                exit 0
                ;;
            *)
                echo -e "${R}Invalid option${N}"
                ;;
        esac
    done
}

# Dependency Check
check_deps() {
    local missing=""
    command -v curl >/dev/null 2>&1 || missing="$missing curl"
    command -v wget >/dev/null 2>&1 || missing="$missing wget"
    command -v bc >/dev/null 2>&1 || missing="$missing bc"
    
    if [ -n "$missing" ]; then
        echo -e "${R}Missing:$missing${N}"
        echo -e "Install: ${Y}apt-get install$missing${N}"
        exit 1
    fi
}

# Initialize
check_deps
main

