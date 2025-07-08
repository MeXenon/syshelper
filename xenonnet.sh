#!/bin/bash

# Version: 2.5
# Author: @XenonNet

# ========================================
# DOWNLOAD LINKS CONFIGURATION
# ========================================
declare -A DOWNLOAD_URLS=(
    ["3x_ui_legacy"]="https://uploadkon.ir/uploads/973126_25package-tar.gz"
    ["3x_ui_latest"]="https://uploadkon.ir/uploads/655107_25x-ui-2-6-2-tar.gz"
    ["acme_sh"]="https://uploadkon.ir/uploads/731627_25acme-sh-master-tar.gz"
)

declare -A VERSIONS=(
    ["3x_ui_legacy"]="2.6.0"
    ["3x_ui_latest"]="2.6.2"
    ["acme_sh"]="Latest"
)

clear

# ANSI Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
C='\033[0;36m'
W='\033[1;37m'
D='\033[0;90m'
N='\033[0m'
P='\033[1;35m'  # Light Purple

# Global Data Storage
declare -A SYS
declare -A NET
declare -A MIR
declare -a DNS_LIST
declare -a MIRROR_LIST

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

header() {
    # Define light blue color
    LB="\033[1;36m"
    echo -e "${B}+===============================================+${N}"
    echo -e "${B}|${N}                ${W}Sys Helper${N}                     ${B}|${N}"
    echo -e "${B}|${N}                                               ${B}|${N}"
    echo -e "${B}|${N}               ${W}Version: ${N}                       ${B}|${N}"
    echo -e "${B}|${N}         ${P}██████╗    ███████╗${N}                   ${B}|${N}"
    echo -e "${B}|${N}         ${P}╚════██╗   ██╔════╝${N}                   ${B}|${N}"
    echo -e "${B}|${N}         ${P} █████╔╝   ███████╗${N}                   ${B}|${N}"
    echo -e "${B}|${N}         ${P}██╔═══╝    ╚════██║${N}                   ${B}|${N}"
    echo -e "${B}|${N}         ${P}███████╗██╗███████║${N}                   ${B}|${N}"
    echo -e "${B}|${N}         ${P}╚══════╝╚═╝╚══════╝${N}                   ${B}|${N}"
    echo -e "${B}|${N}                                               ${B}|${N}"
    echo -e "${B}|${N}             ${P}By @XenonNET${N}                      ${B}|${N}"
    echo -e "${B}|${N}            ${W}Join: t.me/${LB}XenonNET${N}                ${B}|${N}"
    echo -e "${B}+===============================================+${N}"
}


check_ipv6_status() {
    if sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null | grep -q "1"; then
        echo "disabled"
    else
        echo "enabled"
    fi
}

check_ping_status() {
    if iptables -C INPUT -p icmp --icmp-type echo-request -j DROP 2>/dev/null; then
        echo "blocked"
    else
        echo "allowed"
    fi
}

toggle_ipv6() {
    local current_status=$(check_ipv6_status)
    local action=""
    
    if [ "$current_status" == "enabled" ]; then
        action="disable"
    else
        action="enable"
    fi
    
    local box_width=53
    echo -e "\n╔$(printf '═%.0s' $(seq 1 $box_width))╗"
    printf "║$(printf ' %.0s' $(seq 1 $(((box_width-16)/2))))${W}IPv6 MANAGEMENT${N}$(printf ' %.0s' $(seq 1 $(((box_width-16)/2))))║\n"
    echo -e "╠$(printf '═%.0s' $(seq 1 $box_width))╣"
    
    if [ "$current_status" == "enabled" ]; then
        echo -e "║ Current Status: ${G}Enabled${N}                           ║"
    else
        echo -e "║ Current Status: ${R}Disabled${N}                          ║"
    fi
    
    if [ "$action" == "disable" ]; then
        echo -e "║ Action: ${R}Disable IPv6${N}                              ║"
    else
        echo -e "║ Action: ${G}Enable IPv6${N}                               ║"
    fi
    
    echo -e "╠$(printf '═%.0s' $(seq 1 $box_width))╣"
    echo -e "║ ${Y}1${N}. Temporary (until reboot)                        ║"
    echo -e "║ ${Y}2${N}. Permanent (survives reboot)                     ║"
    echo -e "║ ${Y}3${N}. Cancel                                          ║"
    echo -e "╚$(printf '═%.0s' $(seq 1 $box_width))╝"
    
    echo -ne "\n${Y}Select option [1-3]:${N} "
    read -r choice
    
    case $choice in
        1)
            if [ "$action" == "disable" ]; then
                echo
                progress_bar "Disabling IPv6 (Temp)" 2
                sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
                sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
                sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1 >/dev/null 2>&1
                echo -e "${G}[+] IPv6 temporarily disabled${N}"
            else
                echo
                progress_bar "Enabling IPv6 (Temp)" 2
                sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1
                sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1
                sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=0 >/dev/null 2>&1
                echo -e "${G}[+] IPv6 temporarily enabled${N}"
            fi
            ;;
        2)
            if [ "$action" == "disable" ]; then
                echo
                progress_bar "Disabling IPv6 (Perm)" 3
                if ! grep -q "net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf; then
                    echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf >/dev/null
                    echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf >/dev/null
                    echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf >/dev/null
                else
                    sudo sed -i 's/net.ipv6.conf.all.disable_ipv6 = 0/net.ipv6.conf.all.disable_ipv6 = 1/' /etc/sysctl.conf
                fi
                sudo sysctl -p >/dev/null 2>&1
                echo -e "${G}[+] IPv6 permanently disabled${N}"
            else
                echo
                progress_bar "Enabling IPv6 (Perm)" 3
                sudo sed -i 's/net.ipv6.conf.all.disable_ipv6 = 1/net.ipv6.conf.all.disable_ipv6 = 0/' /etc/sysctl.conf
                sudo sysctl -p >/dev/null 2>&1
                echo -e "${G}[+] IPv6 permanently enabled${N}"
            fi
            ;;
        3)
            echo -e "${Y}Operation cancelled${N}"
            return
            ;;
        *)
            echo -e "${R}Invalid option${N}"
            return
            ;;
    esac
}

toggle_ping() {
    local current_status=$(check_ping_status)
    local action=""
    
    if [ "$current_status" == "allowed" ]; then
        action="block"
    else
        action="allow"
    fi
    
    local box_width=53
    echo -e "\n╔$(printf '═%.0s' $(seq 1 $box_width))╗"
    printf "║$(printf ' %.0s' $(seq 1 $(((box_width-16)/2))))${W}PING MANAGEMENT${N}$(printf ' %.0s' $(seq 1 $(((box_width-16)/2))))║\n"
    echo -e "╠$(printf '═%.0s' $(seq 1 $box_width))╣"
    
    if [ "$current_status" == "allowed" ]; then
        echo -e "║ Current Status: ${G}Allowed${N}                           ║"
    else
        echo -e "║ Current Status: ${R}Blocked${N}                           ║"
    fi
    
    if [ "$action" == "block" ]; then
        echo -e "║ Action: ${R}Block Ping Responses${N}                      ║"
    else
        echo -e "║ Action: ${G}Allow Ping Responses${N}                      ║"
    fi
    
    echo -e "╠$(printf '═%.0s' $(seq 1 $box_width))╣"
    echo -e "║ ${Y}1${N}. Apply changes                                   ║"
    echo -e "║ ${Y}2${N}. Cancel                                          ║"
    echo -e "╚$(printf '═%.0s' $(seq 1 $box_width))╝"
    
    echo -ne "\n${Y}Select option [1-2]:${N} "
    read -r choice
    
    case $choice in
        1)
            if [ "$action" == "block" ]; then
                echo
                progress_bar "Blocking ping" 2
                sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP 2>/dev/null
                if command -v iptables-save >/dev/null 2>&1; then
                    sudo iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
                fi
                echo -e "${G}[+] Ping responses blocked${N}"
            else
                echo
                progress_bar "Allowing ping" 2
                sudo iptables -D INPUT -p icmp --icmp-type echo-request -j DROP 2>/dev/null || true
                if command -v iptables-save >/dev/null 2>&1; then
                    sudo iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
                fi
                echo -e "${G}[+] Ping responses allowed${N}"
            fi
            ;;
        2)
            echo -e "${Y}Operation cancelled${N}"
            return
            ;;
        *)
            echo -e "${R}Invalid option${N}"
            return
            ;;
    esac
}

smart_extract() {
    local file="$1"
    local dest="$2"
    
    echo -e "${C}[+] Smart extracting: $file${N}"
    
    mkdir -p "$dest"
    cd "$dest"
    
    case "$file" in
        *.tar.gz|*.tgz)
            tar -xzf "$file" >/dev/null 2>&1
            ;;
        *.tar)
            tar -xf "$file" >/dev/null 2>&1
            ;;
        *.zip)
            unzip -q "$file" >/dev/null 2>&1
            ;;
        *)
            echo -e "${R}[X] Unsupported archive format${N}"
            return 1
            ;;
    esac
    
    local nested_archives=$(find . -type f \( -name "*.tar.gz" -o -name "*.tgz" -o -name "*.tar" -o -name "*.zip" \) 2>/dev/null)
    
    for nested in $nested_archives; do
        echo -e "${C}[+] Found nested archive: $nested${N}"
        case "$nested" in
            *.tar.gz|*.tgz)
                tar -xzf "$nested" >/dev/null 2>&1
                ;;
            *.tar)
                tar -xf "$nested" >/dev/null 2>&1
                ;;
            *.zip)
                unzip -q "$nested" >/dev/null 2>&1
                ;;
        esac
    done
    
    find . -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null
    
    echo -e "${G}[+] Extraction complete, permissions set${N}"
}

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
    SYS[ipv6]=$(check_ipv6_status)
    SYS[ping]=$(check_ping_status)
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

show_info() {
    local dns_str=""
    if [ ${#DNS_LIST[@]} -gt 0 ]; then
        dns_str="${DNS_LIST[0]}"
        [ ${#DNS_LIST[@]} -gt 1 ] && dns_str="$dns_str, ${DNS_LIST[1]}"
    else
        dns_str="Not configured"
    fi
    
    local ipv6_status=""
    if [ "${SYS[ipv6]}" == "enabled" ]; then
        ipv6_status="${G}Enabled${N}"
    else
        ipv6_status="${R}Disabled${N}"
    fi
    
    local ping_status=""
    if [ "${SYS[ping]}" == "allowed" ]; then
        ping_status="${G}Allowed${N}"
    else
        ping_status="${R}Blocked${N}"
    fi
    
    local labels=(
        "CPU"
        "Performance"
        "Memory"
        "Uptime"
        "IPv6 Status"
        "Ping Status"
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
        "$ipv6_status"
        "$ping_status"
        "$dns_str"
        "${G}${NET[ip]}${N}"
        "${NET[city]}, ${NET[country]}"
        "${NET[isp]}"
        "$(echo "${MIR[current]}" | sed 's|https\?://||')"
        "${C}${MIR[version]}${N}"
    )
    
    # Function to get visual length (without ANSI codes)
    get_visual_length() {
        echo -e "$1" | sed 's/\x1B\[[0-9;]*[mK]//g' | wc -m | tr -d ' '
    }
    
    local max_label_len=0
    local max_value_len=0
    
    # Find max label length
    for label in "${labels[@]}"; do
        local len=${#label}
        [ $len -gt $max_label_len ] && max_label_len=$len
    done
    
    # Find max value length (visual length without ANSI codes)
    for value in "${values[@]}"; do
        local visual_len=$(get_visual_length "$value")
        [ $visual_len -gt $max_value_len ] && max_value_len=$visual_len
    done
    
    # Add padding
    max_label_len=$((max_label_len + 2))
    max_value_len=$((max_value_len + 2))
    
    local total_width=$((max_label_len + max_value_len + 3))
    
    echo -e "\n${Y}SYSTEM OVERVIEW${N}"
    printf "+%s+\n" "$(printf '%*s' $total_width '' | tr ' ' '-')"
    
    for ((i=0; i<${#labels[@]}; i++)); do
        local label="${labels[$i]}"
        local value="${values[$i]}"
        
        if [ "$label" = "IP Address" ] && [ "${NET[status]}" = "fail" ]; then
            label="Network Status"
            value="${R}Unavailable${N}"
        fi
        
        # Calculate padding based on visual length
        local value_visual_len=$(get_visual_length "$value")
        local padding=$((max_value_len - value_visual_len))
        
        printf "| %-${max_label_len}s| " "$label"
        echo -ne "$value"
        printf "%${padding}s|\n" ""
    done
    
    printf "+%s+\n" "$(printf '%*s' $total_width '' | tr ' ' '-')"
}

test_speed() {
    local url="$1"
    local result=$(wget --timeout=5 --tries=1 -O /dev/null "$url" 2>&1 | grep -o '[0-9.]* [KM]B/s' | tail -1)
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

check_mirror_release() {
    local mirror_url="$1"
    local release_url="${mirror_url}/dists/jammy/Release"
    local release_info=$(curl --max-time 3 -s "$release_url" 2>/dev/null | grep "Date:" | head -1)
    
    if [ -n "$release_info" ]; then
        echo "$release_info"
    else
        echo "No Release"
    fi
}

test_mirrors() {
    echo -e "\n${W}IRANIAN UBUNTU MIRROR ANALYSIS${N}"
    echo -e "+================================================================+"
    
    local mirrors=(
        "https://archive.ubuntu.mirrors.zagrio.net/ubuntu"
        "https://mirror.iranserver.com/ubuntu"
        "https://ubuntu-mirror.kimiahost.com/ubuntu"
        "https://ubuntu.avinahost.com/ubuntu"
        "https://ubuntu.mobinhost.com/ubuntu"
        "https://ubuntu.pishgaman.net/ubuntu"
        "https://ir.ubuntu.sindad.cloud/ubuntu"
        "http://mirror.aminidc.com/ubuntu"
        "https://mirror.arvancloud.ir/ubuntu"
        "https://mirrors.pardisco.co/ubuntu"
        "https://archive.ubuntu.petiak.ir/ubuntu"
        "https://linuxmirrors.ir/ubuntu"
        "https://ubuntu.pars.host"
        "https://ubuntu.parsvds.com/ubuntu"
        "http://mirror.faraso.org/ubuntu"
        "https://mirrors.ubuntu.dimit.cloud"
        "http://repo.iut.ac.ir/repo/Ubuntu"
        "https://ir.archive.ubuntu.com/ubuntu"
    )
    
    local mirror_names=(
        "Zagrio WebHosting"
        "Iranserver"
        "KimiaHost" 
        "Avina Host"
        "Mobinhost"
        "Pishgaman"
        "Sindad LLC"
        "Amin IDC"
        "ArvanCloud"
        "Pardis Co."
        "Petiak"
        "LinuxMirrors.ir"
        "Pars.host"
        "ParsvDS"
        "Faraso"
        "Dimit Network"
        "IUT University"
        "Official Iran Archive"
    )
    
    echo
    echo -e "${Y}Phase 1: Checking mirror availability and release dates${N}"
    progress_bar "Checking ${#mirrors[@]} mirrors" 10
    
    local temp_file="/tmp/mirror_availability_$$"
    
    for i in "${!mirrors[@]}"; do
        local mirror="${mirrors[$i]}"
        local name="${mirror_names[$i]}"
        
        (
            local release_info=$(check_mirror_release "$mirror")
            echo "$i|$mirror|$name|$release_info"
        ) >> "$temp_file" &
    done
    
    wait
    
    local working_mirrors=()
    local working_names=()
    local working_count=0
    local failed_count=0
    
    while IFS='|' read -r index mirror name release_info; do
        if [[ "$release_info" == "No Release" ]] || [[ -z "$release_info" ]]; then
            failed_count=$((failed_count + 1))
        else
            working_count=$((working_count + 1))
            working_mirrors+=("$mirror")
            working_names+=("$name")
        fi
    done < <(sort -t'|' -k1 -n "$temp_file")
    
    rm -f "$temp_file"
    
    echo -e "\n${G}Phase 1 Complete:${N} ${G}$working_count available${N}, ${R}$failed_count unavailable${N}"
    
    if [ ${#working_mirrors[@]} -eq 0 ]; then
        echo -e "\n${R}[X] No working mirrors found. Please check your internet connection.${N}"
        return 1
    fi
    
    echo -e "\n${Y}Phase 2: Testing speed of available mirrors${N}"
    progress_bar "Speed testing $working_count mirrors" 12
    
    local temp_speed_file="/tmp/mirror_speeds_$$"
    MIRROR_LIST=()
    
    for i in "${!working_mirrors[@]}"; do
        local mirror="${working_mirrors[$i]}"
        local name="${working_names[$i]}"
        
        (
            local speed=$(test_speed "$mirror")
            local release_info=$(check_mirror_release "$mirror")
            echo "$speed|$mirror|$name|$release_info"
        ) >> "$temp_speed_file" &
    done
    
    wait
    
    local speed_working_count=0
    while IFS='|' read -r speed mirror name release_info; do
        if [[ "$speed" != "0" ]]; then
            speed_working_count=$((speed_working_count + 1))
            MIRROR_LIST+=("$speed|$mirror|$name|$release_info")
        fi
    done < "$temp_speed_file"
    
    rm -f "$temp_speed_file"
    
    echo -e "\n${G}Phase 2 Complete:${N} ${G}$speed_working_count mirrors with speed data${N}"
    
    if [ ${#MIRROR_LIST[@]} -eq 0 ]; then
        echo -e "\n${R}[X] No mirrors passed speed test${N}"
        return 1
    fi
    
    IFS=$'\n' MIRROR_LIST=($(printf '%s\n' "${MIRROR_LIST[@]}" | sort -t'|' -k1 -nr))
    
    echo -e "\n${Y}MIRROR ANALYSIS RESULTS${N} (Working Mirrors Only - Sorted by Speed)"
    
    # Define column widths
    local col_rank=4
    local col_speed=12
    local col_name=28
    local col_date=35
    
    # Print header
    printf "+%-${col_rank}s+%-${col_speed}s+%-${col_name}s+%-${col_date}s+\n" \
        "$(printf '%*s' $col_rank '' | tr ' ' '-')" \
        "$(printf '%*s' $col_speed '' | tr ' ' '-')" \
        "$(printf '%*s' $col_name '' | tr ' ' '-')" \
        "$(printf '%*s' $col_date '' | tr ' ' '-')"
    
    printf "| %-$((col_rank-2))s | %-$((col_speed-2))s | %-$((col_name-2))s | %-$((col_date-2))s |\n" \
        "#" "Speed" "Mirror Name" "Release Date"
    
    printf "+%-${col_rank}s+%-${col_speed}s+%-${col_name}s+%-${col_date}s+\n" \
        "$(printf '%*s' $col_rank '' | tr ' ' '-')" \
        "$(printf '%*s' $col_speed '' | tr ' ' '-')" \
        "$(printf '%*s' $col_name '' | tr ' ' '-')" \
        "$(printf '%*s' $col_date '' | tr ' ' '-')"
    
    local rank=1
    local best_mirror=""
    local best_name=""
    local best_speed=0
    
    for result in "${MIRROR_LIST[@]}"; do
        local speed=$(echo "$result" | cut -d'|' -f1)
        local mirror=$(echo "$result" | cut -d'|' -f2)
        local name=$(echo "$result" | cut -d'|' -f3)
        local release_info=$(echo "$result" | cut -d'|' -f4)
        
        if [ "$rank" -eq 1 ]; then
            best_mirror="$mirror"
            best_name="$name"
            best_speed="$speed"
        fi
        
        local mbps=$(echo "scale=1; $speed / 128" | bc)
        local speed_str="${mbps} Mb/s"
        local clean_date=$(echo "$release_info" | sed 's/Date: //')
        
        # Prepare colored components
        local rank_str="$rank"
        if [ "$rank" -eq 1 ]; then
            rank_str="${G}$rank${N}"
            speed_str="${G}$speed_str${N}"
        elif [ "$rank" -le 3 ]; then
            rank_str="${Y}$rank${N}"
            speed_str="${Y}$speed_str${N}"
        else
            rank_str="${D}$rank${N}"
            speed_str="${C}$speed_str${N}"
        fi
        
        # Truncate name and date if too long
        local truncated_name="${name:0:$((col_name-2))}"
        local truncated_date="${clean_date:0:$((col_date-2))}"
        
        # Print row with proper alignment
        printf "| "
        echo -ne "$rank_str"
        printf "%$((col_rank-2-${#rank}))s | " ""
        echo -ne "$speed_str"
        local speed_visual_len=$(echo -e "$speed_str" | sed 's/\x1B\[[0-9;]*[mK]//g' | wc -m | tr -d ' ')
        printf "%$((col_speed-1-speed_visual_len))s | " ""
        printf "%-$((col_name-2))s | " "$truncated_name"
        printf "%-$((col_date-2))s |\n" "$truncated_date"
        
        rank=$((rank + 1))
    done
    
    printf "+%-${col_rank}s+%-${col_speed}s+%-${col_name}s+%-${col_date}s+\n" \
        "$(printf '%*s' $col_rank '' | tr ' ' '-')" \
        "$(printf '%*s' $col_speed '' | tr ' ' '-')" \
        "$(printf '%*s' $col_name '' | tr ' ' '-')" \
        "$(printf '%*s' $col_date '' | tr ' ' '-')"
    
    if [ -n "$best_mirror" ]; then
        local best_mbps=$(echo "scale=1; $best_speed / 128" | bc)
        echo -e "\n${G}FASTEST MIRROR DETECTED${N}"
        echo -e "Mirror: ${W}$best_name${N}"
        echo -e "URL: ${C}$best_mirror${N}"
        echo -e "Speed: ${G}${best_mbps} Mb/s${N}"
        
        echo -e "\n${W}MIRROR CONFIGURATION OPTIONS${N}"
        echo -e "+----------------------------------------------------------+"
        echo -e "| ${G}1${N}. Apply fastest mirror (recommended)               |"
        echo -e "| ${G}2${N}. Choose custom mirror from list                      |"
        echo -e "| ${G}3${N}. Back to main menu                                   |"
        echo -e "+----------------------------------------------------------+"
        
        echo -ne "\n${Y}Select option [1-3]:${N} "
        read -r mirror_choice
        
        case $mirror_choice in
            1)
                apply_mirror "$best_mirror" "$best_name"
                ;;
            2)
                choose_custom_mirror
                ;;
            3)
                return 0
                ;;
            *)
                echo -e "${R}Invalid selection${N}"
                ;;
        esac
    fi
}

apply_mirror() {
    local mirror_url="$1"
    local mirror_name="$2"
    
    echo -e "\n${C}Applying mirror: $mirror_name${N}"
    progress_bar "Configuring mirror" 3
    
    local version=$(lsb_release -sr 2>/dev/null | cut -d '.' -f 1)
    if [[ "$version" -ge 24 ]] 2>/dev/null; then
        sudo sed -i "s|URIs: https\?://[^ ]*|URIs: $mirror_url|g" /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null
    else
        sudo sed -i "s|https\?://[^ ]*|$mirror_url|g" /etc/apt/sources.list 2>/dev/null
    fi
    
    progress_bar "Updating package index" 5
    if sudo apt-get update >/dev/null 2>&1; then
        echo -e "\n${G}[+] Mirror configuration updated successfully${N}"
        echo -e "${G}[+] Active mirror: $mirror_name${N}"
    else
        echo -e "\n${R}[X] Failed to update package index${N}"
    fi
}

choose_custom_mirror() {
    echo -e "\n${Y}CUSTOM MIRROR SELECTION${N}"
    echo -e "Available working mirrors:"
    
    local custom_options=()
    local option_num=1
    
    for result in "${MIRROR_LIST[@]}"; do
        local speed=$(echo "$result" | cut -d'|' -f1)
        local mirror=$(echo "$result" | cut -d'|' -f2)
        local name=$(echo "$result" | cut -d'|' -f3)
        local mbps=$(echo "scale=1; $speed / 128" | bc)
        
        custom_options+=("$mirror|$name")
        printf "${G}%2d${N}. %-25s (${C}%.1f Mb/s${N})\n" "$option_num" "$name" "$mbps"
        option_num=$((option_num + 1))
    done
    
    echo -e "\n${G}$option_num${N}. Back to mirror options"
    
    echo -ne "\n${Y}Select mirror [1-$option_num]:${N} "
    read -r custom_choice
    
    if [[ "$custom_choice" =~ ^[0-9]+$ ]] && [ "$custom_choice" -ge 1 ] && [ "$custom_choice" -lt "$option_num" ]; then
        local selected_index=$((custom_choice - 1))
        local selected_info="${custom_options[$selected_index]}"
        local selected_mirror=$(echo "$selected_info" | cut -d'|' -f1)
        local selected_name=$(echo "$selected_info" | cut -d'|' -f2)
        
        apply_mirror "$selected_mirror" "$selected_name"
    elif [ "$custom_choice" -eq "$option_num" ]; then
        return 0
    else
        echo -e "${R}Invalid selection${N}"
    fi
}

install_acme() {
    echo -e "\n${W}ACME.SH INSTALLATION${N}"
    local box_width=62
    echo -e "+$(printf '=%.0s' $(seq 1 $box_width))+"
    echo -e "| Package: ACME.sh SSL Certificate Manager                     |"
    printf "| Version: %-51s |\n" "${VERSIONS[acme_sh]}"
    echo -e "| Type:    Automated Installation                              |"
    echo -e "+$(printf '=%.0s' $(seq 1 $box_width))+"
    
    echo -ne "\n${Y}Proceed with ACME.sh installation? [y/N]:${N} "
    read -r confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        local temp="/tmp/acme-install"
        local url="${DOWNLOAD_URLS[acme_sh]}"
        
        echo
        progress_bar "Preparing" 2
        rm -rf "$temp"
        mkdir -p "$temp"
        
        progress_bar "Downloading" 8
        if curl -L -o "$temp/acme-sh.tar.gz" "$url" 2>/dev/null; then
            echo -e "${G}[+] Download complete${N}"
        else
            echo -e "${R}[X] Download failed${N}"
            return 1
        fi
        
        progress_bar "Extracting" 3
        smart_extract "$temp/acme-sh.tar.gz" "$temp"
        
        local acme_script=$(find "$temp" -name "acme.sh" -type f | head -1)
        
        if [ -f "$acme_script" ]; then
            echo -e "\n${C}Installing ACME.sh...${N}"
            cd "$(dirname "$acme_script")"
            echo "+-------------------------------------------+"
            ./acme.sh --install
            echo "+-------------------------------------------+"
            echo -e "${G}[+] ACME.sh installation complete${N}"
            echo -e "${C}[+] You can now use: ~/.acme.sh/acme.sh${N}"
        else
            echo -e "${R}[X] ACME.sh script not found${N}"
        fi
        
        rm -rf "$temp"
    fi
}

install_3x_ui() {
    echo -e "\n${W}3X-UI INSTALLATION${N}"
    local box_width=62
    echo -e "+$(printf '=%.0s' $(seq 1 $box_width))+"
    echo -e "| Available Versions:                                          |"
    echo -e "| ${G}1${N}. 3X-UI v${VERSIONS[3x_ui_latest]} ${Y}(Recommended)${N}                              |"
    echo -e "| ${G}2${N}. 3X-UI v${VERSIONS[3x_ui_legacy]} ${D}(Legacy)${N}                                   |"
    echo -e "| ${G}3${N}. Back to Main Menu                                        |"
    echo -e "+$(printf '=%.0s' $(seq 1 $box_width))+"
    
    echo -ne "\n${Y}Select version [1-3] (default: 1):${N} "
    read -r version_choice
    
    [ -z "$version_choice" ] && version_choice="1"
    
    local url_key=""
    local version=""
    
    case $version_choice in
        1)
            url_key="3x_ui_latest"
            version="${VERSIONS[3x_ui_latest]}"
            ;;
        2)
            url_key="3x_ui_legacy"
            version="${VERSIONS[3x_ui_legacy]}"
            ;;
        3)
            return 0
            ;;
        *)
            echo -e "${R}Invalid selection${N}"
            return 1
            ;;
    esac
    
    echo -e "\n${C}Selected: 3X-UI v$version${N}"
    echo -ne "${Y}Proceed with installation? [y/N]:${N} "
    read -r confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        local temp="/tmp/3x-ui-install"
        local url="${DOWNLOAD_URLS[$url_key]}"
        
        echo
        progress_bar "Preparing" 2
        rm -rf "$temp"
        mkdir -p "$temp"
        
        progress_bar "Downloading" 8
        if curl -L -o "$temp/package.tar.gz" "$url" 2>/dev/null; then
            echo -e "${G}[+] Download complete${N}"
        else
            echo -e "${R}[X] Download failed${N}"
            return 1
        fi
        
        progress_bar "Extracting" 3
        smart_extract "$temp/package.tar.gz" "$temp"
        
        local install_script=$(find "$temp" -name "install.sh" -type f | head -1)
        
        if [ -f "$install_script" ]; then
            cp "$install_script" /root/
            chmod +x /root/install.sh
            
            find "$temp" -name "x-ui-linux-*.tar.gz" -exec cp {} /root/ \;
            find "$temp" -name "*.sh" -exec cp {} /root/ \;
            
            echo -e "\n${C}Launching 3X-UI v$version installer...${N}"
            echo "+-------------------------------------------+"
            cd /root
            bash /root/install.sh
            echo "+-------------------------------------------+"
            echo -e "${G}[+] 3X-UI v$version installation complete${N}"
        else
            echo -e "${R}[X] Installation script not found${N}"
        fi
        
        rm -rf "$temp"
    fi
}

network_menu() {
    while true; do
        local ipv6_status=$(check_ipv6_status)
        local ping_status=$(check_ping_status)
        
        local ipv6_display=""
        local ping_display=""
        local ipv6_action=""
        local ping_action=""
        
        if [ "$ipv6_status" == "enabled" ]; then
            ipv6_display="${G}Enabled${N} ${D}(Recommended)${N}"
            ipv6_action="${R}Turn OFF${N}"
        else
            ipv6_display="${R}Disabled${N} ${Y}(May cause issues)${N}"
            ipv6_action="${G}Turn ON${N}"
        fi
        
        if [ "$ping_status" == "allowed" ]; then
            ping_display="${G}Allowed${N} ${D}(Normal)${N}"
            ping_action="${R}Block${N}"
        else
            ping_display="${R}Blocked${N} ${Y}(Hidden from ping)${N}"
            ping_action="${G}Allow${N}"
        fi
        
        # Function to calculate visual length and pad
        pad_with_visual_length() {
            local str="$1"
            local target_len="$2"
            local visual_len=$(echo -e "$str" | sed 's/\x1B\[[0-9;]*[mK]//g' | wc -m | tr -d ' ')
            local padding=$((target_len - visual_len))
            echo -ne "$str"
            printf "%${padding}s" ""
        }
        
        local box_width=53
        echo -e "\n╔$(printf '═%.0s' $(seq 1 $box_width))╗"
        printf "║$(printf ' %.0s' $(seq 1 $(((box_width-19)/2))))${W}NETWORK MANAGEMENT${N}$(printf ' %.0s' $(seq 1 $(((box_width-19)/2))))║\n"
        echo -e "╠$(printf '═%.0s' $(seq 1 $box_width))╣"
        printf "║$(printf ' %.0s' $(seq 1 $(((box_width-14)/2))))${Y}CURRENT STATUS${N}$(printf ' %.0s' $(seq 1 $(((box_width-14)/2))))║\n"
        
        printf "║ • IPv6:           "
        pad_with_visual_length "$ipv6_display" 33
        echo " ║"
        
        printf "║ • Ping Response:  "
        pad_with_visual_length "$ping_display" 33
        echo " ║"
        
        echo -e "╠$(printf '═%.0s' $(seq 1 $box_width))╣"
        printf "║$(printf ' %.0s' $(seq 1 $(((box_width-13)/2))))${Y}QUICK ACTIONS${N}$(printf ' %.0s' $(seq 1 $(((box_width-14)/2))))║\n"
        
        printf "║ ${G}1${N}. Toggle IPv6 ("
        pad_with_visual_length "$ipv6_action" 8
        echo ")                      ║"
        
        printf "║ ${G}2${N}. Toggle Ping Response ("
        pad_with_visual_length "$ping_action" 5
        echo ")             ║"
        
        echo -e "║ ${G}3${N}. Back to Main Menu                        ║"
        echo -e "╚$(printf '═%.0s' $(seq 1 $box_width))╝"
        
        echo -ne "\n${Y}Select option [1-3]:${N} "
        read -r net_choice
        
        case $net_choice in
            1)
                toggle_ipv6
                ;;
            2)
                toggle_ping
                ;;
            3)
                break
                ;;
            *)
                echo -e "${R}Invalid option. Please select 1, 2, or 3.${N}"
                ;;
        esac
        
        if [ "$net_choice" != "3" ]; then
            echo -e "\n${D}Press Enter to continue...${N}"
            read -r
        fi
    done
}

menu() {
    echo -e "\n${W}MAIN MENU${N}"
    echo -e "| ${G}1${N}. Best Mirror        |"
    echo -e "| ${G}2${N}. Install 3X-UI      |"
    echo -e "| ${G}3${N}. Install ACME.sh    |"
    echo -e "| ${G}4${N}. Network Management |"
    echo -e "| ${G}5${N}. Refresh Info       |"
    echo -e "| ${G}6${N}. Exit               |"
}

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
        echo -ne "\n[$status] Select (1-6): "
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
                install_acme
                echo -e "\n${D}Press Enter to continue...${N}"
                read -r
                clear && header && show_info
                ;;
            4)
                network_menu
                clear && header && show_info
                ;;
            5)
                clear && header
                echo
                progress_bar "Refreshing" 2
                collect_dns
                collect_system
                collect_network 
                collect_mirror
                show_info
                ;;
            6)
                echo -e "\n${G}Thank you for using XenonNet System Helper${N}"
                echo -e "${D}Version 2.5 - @XenonNet${N}\n"
                exit 0
                ;;
            *)
                echo -e "${R}Invalid option${N}"
                ;;
        esac
    done
}

check_deps() {
    local missing=""
    command -v curl >/dev/null 2>&1 || missing="$missing curl"
    command -v wget >/dev/null 2>&1 || missing="$missing wget"
    command -v bc >/dev/null 2>&1 || missing="$missing bc"
    command -v tar >/dev/null 2>&1 || missing="$missing tar"
    
    if [ -n "$missing" ]; then
        echo -e "${R}Missing dependencies:$missing${N}"
        echo -e "Install with: ${Y}apt-get install$missing${N}"
        exit 1
    fi
    
    if ! command -v iptables >/dev/null 2>&1; then
        echo -e "${Y}Warning: iptables not found - ping management will be limited${N}"
    fi
}

check_deps
main
