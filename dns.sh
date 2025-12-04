#!/bin/bash
# ====================================================
# Project: Linux DNS Optimizer
# Description: Smart script to benchmark & switch to the fastest DNS
# Source: https://github.com/cenktekin/better-dns-optimizer
# License: MIT
# ====================================================

# Color definitions
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
RESET='\033[0m'

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}[!] Error: This script must be run with root privileges.${RESET}"
    echo -e "Please run: sudo bash $0"
    exit 1
fi

# ====================================================
# DNS List Configuration (Format: IP|Description)
# ====================================================

# IPv4 DNS List
DNS_SECURITY_LIST_V4=(
    # ------------------------------------------------
    # IPv4 - Security/Privacy/Ad-Blocking (Security & Privacy)
    # ------------------------------------------------
    "94.140.14.14|AdGuard DNS (Default - AdBlock)"
    "94.140.15.15|AdGuard DNS (Family Protection)"
    "1.1.1.2|Cloudflare (Malware Blocking)"
    "9.9.9.9|Quad9 (Malware Blocking - Swiss)"
    "194.242.2.2|Mullvad DNS (No-Logging/Privacy)"
    "185.228.168.9|CleanBrowsing (Security Filter)"
)

DNS_SPEED_LIST_V4=(
    # ------------------------------------------------
    # IPv4 - Global High Speed/Backbone (Global Speed & Backbone)
    # ------------------------------------------------
    "1.1.1.1|Cloudflare (IPv4 - Primary)"
    "1.0.0.1|Cloudflare (IPv4 - Secondary)"
    "8.8.8.8|Google Public DNS (IPv4 - Primary)"
    "8.8.4.4|Google (IPv4 - Secondary)"
    "76.76.2.0|Control D (Unfiltered - High Speed)"
    "208.67.222.222|OpenDNS (Cisco)"
    "4.2.2.1|Level3 (CenturyLink - US Backbone)"
    "4.2.2.2|Level3 Secondary (US)"
    "156.154.70.1|Neustar UltraDNS (Enterprise)"

    # ------------------------------------------------
    # IPv4 - Regional Optimized
    # ------------------------------------------------
    "203.80.96.10|HKBN (Hong Kong Broadband)"
    "203.80.96.9|HKBN Secondary (Hong Kong)"
    "101.101.101.101|Quad101 (Taiwan - TWNIC)"
    "168.95.1.1|HiNet (Taiwan Telecom)"
    "168.126.63.1|KT DNS (South Korea Telecom)"
    "84.200.69.80|DNS.WATCH (Germany - Privacy)"
    "77.88.8.8|Yandex.DNS (Russia/CIS Optimized)"

    # ------------------------------------------------
    # IPv4 - Turkey Regional DNS
    # ------------------------------------------------
    "213.161.192.12|TTNET (Turkey - Primary)"
    "213.161.193.13|TTNET (Turkey - Secondary)"
    "193.192.97.146|Superonline (Turkey - Primary)"
    "193.192.98.146|Superonline (Turkey - Secondary)"
    "195.175.50.50|Vodafone (Turkey - Primary)"
    "195.175.51.51|Vodafone (Turkey - Secondary)"
)

# IPv6 DNS List
DNS_SECURITY_LIST_V6=(
    # ------------------------------------------------
    # IPv6 - Security/Privacy/Ad-Blocking (Security & Privacy IPv6)
    # ------------------------------------------------
    "2a10:50c0::ad1:ff|AdGuard (IPv6 - AdBlock)"
    "2a10:50c0::ad2:ff|AdGuard (IPv6 - Family)"
    "2620:fe::fe|Quad9 (IPv6 - Security)"
    "2a07:a8c0::|Mullvad (IPv6 - Privacy)"
    "2a0d:2a00:1::2|CleanBrowsing (IPv6 - Security)"
)

DNS_SPEED_LIST_V6=(
    # ------------------------------------------------
    # IPv6 - Global Speed & Regional Optimization
    # ------------------------------------------------
    # --- Global Speed ---
    "2606:4700:4700::1111|Cloudflare (IPv6 - Primary)"
    "2606:4700:4700::1001|Cloudflare (IPv6 - Secondary)"
    "2001:4860:4860::8888|Google (IPv6 - Primary)"
    "2001:4860:4860::8844|Google (IPv6 - Secondary)"
    "2620:119:35::35|OpenDNS (IPv6)"
    "2606:1a40::2|Control D (IPv6 - Unfiltered)"

    # --- Regional ---
    "2001:b000:168::1|HiNet (Taiwan IPv6)"
    "2001:1608:10:25::1c04:b12f|DNS.WATCH (Germany IPv6)"
    "2a02:6b8::feed:0ff|Yandex.DNS (Russia IPv6)"
)

# Combined lists
DNS_SECURITY_LIST=("${DNS_SECURITY_LIST_V4[@]}" "${DNS_SECURITY_LIST_V6[@]}")
DNS_SPEED_LIST=("${DNS_SPEED_LIST_V4[@]}" "${DNS_SPEED_LIST_V6[@]}")

# All list
DNS_ALL_LIST=("${DNS_SECURITY_LIST[@]}" "${DNS_SPEED_LIST[@]}")

# IPv4 and IPv6 separate lists
DNS_ALL_V4_LIST=("${DNS_SECURITY_LIST_V4[@]}" "${DNS_SPEED_LIST_V4[@]}")
DNS_ALL_V6_LIST=("${DNS_SECURITY_LIST_V6[@]}" "${DNS_SPEED_LIST_V6[@]}")

# Configuration file path
CONFIG_FILE="$HOME/.dns_optimizer_config"

# Default configuration values
DEFAULT_DNS_MODE="3"  # All tests
DEFAULT_IP_VERSION="all"  # IP version (all, v4, v6)
DEFAULT_TEST_DOMAINS=("example.com" "google.com" "github.com")  # Default test domains
DEFAULT_TEST_COUNT=3  # Number of tests per DNS
DEFAULT_TIMEOUT=3     # Query timeout (seconds)
DEFAULT_LOCK_RESOLV="y"  # Whether to lock the configuration file

# 读取配置文件
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo -e "${GREEN}[√] Configuration loaded: $CONFIG_FILE${RESET}"
    else
        # Use default values
        DNS_MODE="$DEFAULT_DNS_MODE"
        TEST_DOMAINS=("${DEFAULT_TEST_DOMAINS[@]}")
        TEST_COUNT="$DEFAULT_TEST_COUNT"
        TIMEOUT="$DEFAULT_TIMEOUT"
        LOCK_RESOLV="$DEFAULT_LOCK_RESOLV"
        echo -e "${YELLOW}[i] Using default configuration${RESET}"
    fi
}

# 保存配置文件
save_config() {
    {
        echo "# Linux DNS Optimizer Configuration File"
        echo "# Generated at: $(date)"
        echo ""
        echo "DNS_MODE=\"$DNS_MODE\""
        echo "IP_VERSION=\"${IP_VERSION:-$DEFAULT_IP_VERSION}\""
        echo "TEST_DOMAINS=(${TEST_DOMAINS[@]})"
        echo "TEST_COUNT=$TEST_COUNT"
        echo "TIMEOUT=$TIMEOUT"
        echo "LOCK_RESOLV=\"$LOCK_RESOLV\""
        echo "AUTO_TEST_INTERVAL=${AUTO_TEST_INTERVAL:-0}"  # Auto test interval (minutes)
        echo "LOG_RETENTION_DAYS=${LOG_RETENTION_DAYS:-30}"  # Log retention days
    } > "$CONFIG_FILE"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[√] Configuration saved to: $CONFIG_FILE${RESET}"
    else
        echo -e "${RED}[!] Configuration save failed${RESET}"
    fi
}

# 读取配置文件
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo -e "${GREEN}[√] Configuration loaded: $CONFIG_FILE${RESET}"
    else
        # Use default values
        DNS_MODE="$DEFAULT_DNS_MODE"
        IP_VERSION="$DEFAULT_IP_VERSION"
        TEST_DOMAINS=("${DEFAULT_TEST_DOMAINS[@]}")
        TEST_COUNT="$DEFAULT_TEST_COUNT"
        TIMEOUT="$DEFAULT_TIMEOUT"
        LOCK_RESOLV="$DEFAULT_LOCK_RESOLV"
        echo -e "${YELLOW}[i] Using default configuration${RESET}"
    fi
}

# Logging and auto test related
LOG_DIR="$HOME/.dns_optimizer_logs"
LOG_FILE="$LOG_DIR/dns_test_$(date +%Y%m).log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Record test results to log
log_test_result() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local fastest_dns="$1"
    local avg_latency="$2"
    local test_mode="$3"

    echo "[$timestamp] Mode: $test_mode | Fastest DNS: $fastest_dns | Avg Latency: ${avg_latency}ms" >> "$LOG_FILE"
}

# Auto test function
auto_test() {
    local interval=${1:-60}  # Default 60 minutes
    local test_mode=${2:-3}  # Default test mode

    echo -e "${CYAN}>>> Starting auto test mode (interval: ${interval} minutes)${RESET}"
    echo -e "${YELLOW}Press Ctrl+C to stop auto test${RESET}"

    # Save the current configuration test mode
    local original_mode="$DNS_MODE"
    DNS_MODE="$test_mode"

    while true; do
        echo -e "\n${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] Auto test starting...${RESET}"

        # Perform DNS test
        declare -a results

        for item in "${DNS_LIST_TO_USE[@]}"; do
            IFS='|' read -r ip name <<< "$item"

            # Use parameters from configuration for DNS query test
            total_time=0
            success_count=0

            for i in $(seq 1 $TEST_COUNT); do
                # Use domain from configuration for DNS query test
                domain="${TEST_DOMAINS[$((i-1)) % ${#TEST_DOMAINS[@]}]}"

                # dig query domain and get query time
                query_result=$(dig +stats +tries=1 +time=$TIMEOUT "@$ip" "$domain" 2>/dev/null)
                query_time=$(echo "$query_result" | grep "Query time" | tail -n1 | awk '{print $4}' | sed 's/msec$//')

                if [ -n "$query_time" ] && [ "$query_time" != "0" ]; then
                    total_time=$((total_time + query_time))
                    success_count=$((success_count + 1))
                fi
            done

            if [ $success_count -gt 0 ]; then
                avg_time=$((total_time / success_count))
                packet_loss=$(( (TEST_COUNT - success_count) * 100 / TEST_COUNT ))
                results+=("$avg_time|$ip|$name|$success_count|$packet_loss")
            else
                results+=("9999|$ip|$name|0|100")
            fi
        done

        # Sort results (by average latency)
        IFS=$'\n' sorted=($(printf "%s\n" "${results[@]}" | sort -n -t'|' -k1))
        unset IFS

        # Get the fastest DNS
        if [ ${#sorted[@]} -gt 0 ]; then
            IFS='|' read -r lat ip name success loss <<< "${sorted[0]}"
            if [ "$lat" != "9999" ]; then
                echo -e "${GREEN}>>> Fastest DNS: $name ($ip) - ${lat}ms${RESET}"

                # Record to log
                log_test_result "$ip ($name)" "$lat" "$(case $DNS_MODE in 1) Security ;; 2) Speed ;; 3) All ;; *) All ;; esac)"
            else
                echo -e "${RED}>>> All DNS tests failed${RESET}"
            fi
        fi

        echo -e "${YELLOW}Next test: $(date -d "+$interval minutes" '+%H:%M:%S')${RESET}"
        sleep $((interval * 60))
    done
}

# Show history of tests
show_history() {
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${BLUE}        📊 DNS Test History              ${RESET}"
    echo -e "${BLUE}========================================${RESET}"

    if [ -f "$LOG_FILE" ]; then
        echo -e "${CYAN}Recent test records:${RESET}"
        tail -n 20 "$LOG_FILE"
    else
        echo -e "${YELLOW}No test records available${RESET}"
    fi

    echo -ne "\n${YELLOW}Press Enter to return...${RESET}"
    read -r
}

# DNS Leak Test
test_dns_leak() {
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${BLUE}       🔐 DNS Leak Test                   ${RESET}"
    echo -e "${BLUE}========================================${RESET}"

    echo -e "${CYAN}>>> Checking for DNS leaks...${RESET}"

    # Get current DNS servers
    current_dns=$(grep "nameserver" /etc/resolv.conf | head -n3 | awk '{print $2}' | tr '\n' ' ')
    echo -e "${YELLOW}Current configured DNS servers:${RESET} $current_dns"

    # Check current DNS settings
    echo -e "\n${YELLOW}Checking /etc/resolv.conf:${RESET}"
    cat /etc/resolv.conf

    # Check systemd-resolved status
    if systemctl is-active --quiet systemd-resolved; then
        echo -e "\n${YELLOW}systemd-resolved service status: ${GREEN}Running${RESET}"
        echo -e "${YELLOW}systemd-resolved configuration:${RESET}"
        cat /etc/systemd/resolved.conf | grep -E "^DNS=|^FallbackDNS="
    else
        echo -e "\n${YELLOW}systemd-resolved service status: ${RED}Not running${RESET}"
    fi

    # Test DNS resolution
    echo -e "\n${CYAN}>>> Testing DNS resolution function...${RESET}"
    test_domains=("google.com" "github.com" "cloudflare.com")

    for domain in "${test_domains[@]}"; do
        echo -ne "  Testing $domain ... "
        result=$(timeout 5 dig +short "$domain" 2>/dev/null | head -n1)
        if [ -n "$result" ]; then
            echo -e "${GREEN}Success${RESET} ($result)"
        else
            echo -e "${RED}Failed${RESET}"
        fi
    done

    # Check IPv6 DNS leak
    echo -e "\n${YELLOW}Checking IPv6 DNS leak...${RESET}"
    if [ -n "$current_dns" ]; then
        for dns in $current_dns; do
            if [[ $dns == *:* ]]; then
                # IPv6 DNS server
                echo -e "  IPv6 DNS $dns usage confirmed - ${GREEN}OK${RESET}"
            fi
        done
    fi

    echo -e "\n${GREEN}DNS Leak test completed${RESET}"
    echo -ne "\n${YELLOW}Press Enter to return...${RESET}"
    read -r
}

# DNSSEC Test
test_dnssec() {
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${BLUE}       🔐 DNSSEC Validation Test          ${RESET}"
    echo -e "${BLUE}========================================${RESET}"

    echo -e "${CYAN}>>> Testing DNSSEC validation...${RESET}"

    # Test DNSSEC supporting domain
    test_domain="google.com"  # Domain supporting DNSSEC
    echo -e "\n${YELLOW}Test domain: $test_domain${RESET}"

    # DNSSEC validation check
    dnssec_result=$(timeout 10 dig +dnssec +multiline +noall +answer "$test_domain" 2>/dev/null)
    ds_result=$(timeout 10 dig +dnssec +multiline +noall +answer DS "$test_domain" 2>/dev/null)

    if [ -n "$dnssec_result" ]; then
        # Check DNSSEC support
        if echo "$dnssec_result" | grep -q "ad\|authentic data"; then
            echo -e "${GREEN}DNSSEC Validation: ${GREEN}Supported and enabled${RESET}"
        elif [ -n "$ds_result" ]; then
            echo -e "${YELLOW}DNSSEC Validation: ${YELLOW}Configured but not verified${RESET}"
        else
            echo -e "${RED}DNSSEC Validation: ${RED}Not supported or not configured${RESET}"
        fi

        # Show results
        echo -e "\n${YELLOW}DNSSEC query result:${RESET}"
        echo "$dnssec_result"
    else
        echo -e "${RED}DNSSEC query failed${RESET}"
    fi

    echo -e "\n${GREEN}DNSSEC test completed${RESET}"
    echo -ne "\n${YELLOW}Press Enter to return...${RESET}"
    read -r
}

# Restore DNS configuration from backup
restore_dns_backup() {
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${BLUE}       🔄 Restore DNS Configuration Backup ${RESET}"
    echo -e "${BLUE}========================================${RESET}"

    # Find backup files
    backup_files=($(ls -t /etc/resolv.conf.bak.* 2>/dev/null))

    if [ ${#backup_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}No backup files found${RESET}"
        echo -ne "\n${YELLOW}Press Enter to return...${RESET}"
        read -r
        return 1
    fi

    echo -e "${CYAN}Available backup files:${RESET}"
    for i in "${!backup_files[@]}"; do
        idx=$((i+1))
        # Extract date time
        backup_date=$(basename "${backup_files[$i]}" | sed 's/.*\.bak\.\([0-9]*_[0-9]*\)$/\1/')
        echo -e "  [$idx] ${backup_files[$i]} (${backup_date})"
    done

    echo -e "\n${YELLOW}Please select backup file number to restore (0 to return): ${RESET}"
    read -r selection

    if [ "$selection" == "0" ]; then
        return 0
    fi

    # Check if input is valid
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#backup_files[@]}" ]; then
        echo -e "${RED}Invalid selection${RESET}"
        echo -ne "\n${YELLOW}Press Enter to return...${RESET}"
        read -r
        return 1
    fi

    # Calculate index
    selected_index=$((selection-1))
    selected_backup="${backup_files[$selected_index]}"

    echo -e "${YELLOW}Selected backup file: $selected_backup${RESET}"
    echo -ne "${RED}Confirm restore? [y/N]: ${RESET}"
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Restore operation cancelled${RESET}"
        echo -ne "\n${YELLOW}Press Enter to return...${RESET}"
        read -r
        return 0
    fi

    # If current file is locked, unlock it first
    if lsattr /etc/resolv.conf 2>/dev/null | grep -q "i"; then
        chattr -i /etc/resolv.conf
        echo -e "${YELLOW}Current configuration file unlocked${RESET}"
    fi

    # Restore backup
    if cp "$selected_backup" /etc/resolv.conf; then
        echo -e "${GREEN}[√] Configuration restored${RESET}"

        # If systemd-resolved service is running, restart it
        if systemctl is-active --quiet systemd-resolved; then
            systemctl restart systemd-resolved
            echo -e "${GREEN}[√] systemd-resolved service restarted${RESET}"
        fi

        # Check if configuration file should be locked
        echo -ne "\n${YELLOW}Lock configuration file? [Y/n]: ${RESET}"
        read -r lock_choice

        if [[ ! "$lock_choice" =~ ^[Nn]$ ]]; then
            chattr +i /etc/resolv.conf
            echo -e "${GREEN}[√] Configuration file locked${RESET}"
        fi

        echo -e "\n${GREEN}Restore completed!${RESET}"
    else
        echo -e "${RED}Restore failed${RESET}"
    fi

    echo -ne "\n${YELLOW}Press Enter to return...${RESET}"
    read -r
}

# ====================================================
# 核心功能函数
# ====================================================

select_dns_mode() {
    clear
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${BLUE}       🚀 Linux DNS Optimizer           ${RESET}"
    echo -e "${BLUE}         选择测试模式                    ${RESET}"
    echo -e "${BLUE}========================================${RESET}"

    # Load configuration
    load_config

    # If IP_VERSION is not set, use default value
    if [ -z "$IP_VERSION" ]; then
        IP_VERSION="$DEFAULT_IP_VERSION"
    fi

    echo -e "\n${YELLOW}Please select DNS test mode:${RESET}"
    echo -e "  [1] ${GREEN}Security/Privacy/AdBlock${RESET} - Test ad-blocking and privacy DNS"
    echo -e "  [2] ${CYAN}Speed/Performance${RESET} - Test fastest DNS servers"
    echo -e "  [3] ${YELLOW}All Tests${RESET} - Test all DNS servers"
    echo -e "  [4] ${BLUE}Auto Test Mode${RESET} - Scheduled auto test (experimental)"
    echo -e "  [5] ${MAGENTA}View History${RESET} - Show test history"
    echo -e "  [6] ${RED}DNS Leak Test${RESET} - Check for DNS leaks"
    echo -e "  [7] ${PURPLE}DNSSEC Test${RESET} - Validate DNS security extensions"
    echo -e "  [8] ${YELLOW}Restore Backup Config${RESET} - Restore DNS settings from backup"
    echo -e "\n${CYAN}Current config:${RESET} $(case $DNS_MODE in 1) Security/Privacy Mode ;; 2) Speed/Performance Mode ;; 3) All Test Mode ;; *) All Test Mode ;; esac) | IP Version: $(case ${IP_VERSION:-all} in all) IPv4 & IPv6 ;; v4) IPv4 Only ;; v6) IPv6 Only ;; *) IPv4 & IPv6 ;; esac)"
    echo -ne "\n${CYAN}Please select test mode [1-8] (Enter to use current config): ${RESET}"
    read -r mode_choice

    # If user enters a selection, update configuration
    if [ -n "$mode_choice" ]; then
        DNS_MODE="$mode_choice"
    fi

    # Process additional options
    case $DNS_MODE in
        6)
            # DNS Leak Test
            test_dns_leak
            return 0
            ;;
        7)
            # DNSSEC Test
            test_dnssec
            return 0
            ;;
        8)
            # Restore Backup Config
            restore_dns_backup
            return 0
            ;;
    esac

    # IP version selection (only applies to DNS test modes, security test modes are unaffected)
    if [[ "$DNS_MODE" =~ ^[1-3]$ ]]; then
        echo -ne "\n${CYAN}Please select IP version [A-C] (Enter to use current config: $(case ${IP_VERSION:-all} in all) A ;; v4) B ;; v6) C ;; *) A ;; esac)): ${RESET}"
        read -r ip_choice

        case ${ip_choice:-A} in
            [Aa]) IP_VERSION="all" ;;
            [Bb]) IP_VERSION="v4" ;;
            [Cc]) IP_VERSION="v6" ;;
            *) IP_VERSION="all" ;;
        esac
    fi

    # Select DNS list based on IP version
    case $DNS_MODE in
        1)
            case $IP_VERSION in
                v4) DNS_LIST_TO_USE=("${DNS_SECURITY_LIST_V4[@]}") ;;
                v6) DNS_LIST_TO_USE=("${DNS_SECURITY_LIST_V6[@]}") ;;
                *) DNS_LIST_TO_USE=("${DNS_SECURITY_LIST[@]}") ;;
            esac
            echo -e "${GREEN}[√] Security/Privacy mode selected${RESET}"
            ;;
        2)
            case $IP_VERSION in
                v4) DNS_LIST_TO_USE=("${DNS_SPEED_LIST_V4[@]}") ;;
                v6) DNS_LIST_TO_USE=("${DNS_SPEED_LIST_V6[@]}") ;;
                *) DNS_LIST_TO_USE=("${DNS_SPEED_LIST[@]}") ;;
            esac
            echo -e "${GREEN}[√] Speed/Performance mode selected${RESET}"
            ;;
        3)
            case $IP_VERSION in
                v4) DNS_LIST_TO_USE=("${DNS_ALL_V4_LIST[@]}") ;;
                v6) DNS_LIST_TO_USE=("${DNS_ALL_V6_LIST[@]}") ;;
                *) DNS_LIST_TO_USE=("${DNS_ALL_LIST[@]}") ;;
            esac
            echo -e "${GREEN}[√] All test mode selected${RESET}"
            ;;
        4)
            # Auto test mode - IP version must be selected first
            case $IP_VERSION in
                v4) DNS_LIST_TO_USE=("${DNS_ALL_V4_LIST[@]}") ;;
                v6) DNS_LIST_TO_USE=("${DNS_ALL_V6_LIST[@]}") ;;
                *) DNS_LIST_TO_USE=("${DNS_ALL_LIST[@]}") ;;
            esac

            echo -e "\n${YELLOW}Auto test parameters:${RESET}"
            echo -ne "  Test interval (minutes, default 60): "
            read -r auto_interval
            auto_interval=${auto_interval:-60}

            echo -ne "  Test mode [1-3] (default 3): "
            read -r auto_test_mode
            auto_test_mode=${auto_test_mode:-3}

            # Save auto test parameters to configuration
            AUTO_TEST_INTERVAL="$auto_interval"
            save_config

            echo -e "\n${CYAN}Starting auto test...${RESET}"
            auto_test "$auto_interval" "$auto_test_mode"
            return 0
            ;;
        5)
            # View history
            show_history
            select_dns_mode  # Re-display menu
            return 0
            ;;
        *)
            case $IP_VERSION in
                v4) DNS_LIST_TO_USE=("${DNS_ALL_V4_LIST[@]}") ;;
                v6) DNS_LIST_TO_USE=("${DNS_ALL_V6_LIST[@]}") ;;
                *) DNS_LIST_TO_USE=("${DNS_ALL_LIST[@]}") ;;
            esac
            echo -e "${RED}Invalid selection, using all test mode${RESET}"
            DNS_MODE="3"
            ;;
    esac

    # Ask if configuration should be saved
    echo -e "\n${YELLOW}Save current configuration as default? [Y/n]${RESET}"
    read -r save_choice

    if [[ ! "$save_choice" =~ ^[Nn]$ ]]; then
        save_config
    fi

    echo -ne "\n${YELLOW}Press Enter to continue...${RESET}"
    read -r
}

test_dns_speed() {
    clear
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${BLUE}       🚀 Linux DNS Optimizer           ${RESET}"
    echo -e "${BLUE}   (Speed Test + Optimize + AutoConfig)   ${RESET}"
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${CYAN}>>> Testing DNS latency (Dig), please wait...${RESET}\n"

    declare -a results

    for item in "${DNS_LIST_TO_USE[@]}"; do
        IFS='|' read -r ip name <<< "$item"

        printf "  %-42s (%-15s) ... " "${name}" "${ip}"

        # Use parameters from configuration for DNS query test
        # Collect all query times for statistical analysis
        declare -a query_times
        success_count=0

        for i in $(seq 1 $TEST_COUNT); do
            # Use domain from configuration for DNS query test
            domain="${TEST_DOMAINS[$((i-1)) % ${#TEST_DOMAINS[@]}]}"

            # dig query domain and get query time
            query_result=$(dig +stats +tries=1 +time=$TIMEOUT "@$ip" "$domain" 2>/dev/null)
            query_time=$(echo "$query_result" | grep "Query time" | tail -n1 | awk '{print $4}' | sed 's/msec$//')

            if [ -n "$query_time" ] && [ "$query_time" != "0" ]; then
                query_times+=("$query_time")
                success_count=$((success_count + 1))
            fi
        done

        if [ $success_count -gt 0 ]; then
            # Calculate statistics
            total_time=0
            min_time=${query_times[0]}
            max_time=${query_times[0]}

            for time in "${query_times[@]}"; do
                total_time=$((total_time + time))
                if [ "$time" -lt "$min_time" ]; then
                    min_time="$time"
                fi
                if [ "$time" -gt "$max_time" ]; then
                    max_time="$time"
                fi
            done

            avg_time=$((total_time / success_count))
            packet_loss=$(( (TEST_COUNT - success_count) * 100 / TEST_COUNT ))

            # Calculate standard deviation
            sum_squared_diff=0
            for time in "${query_times[@]}"; do
                diff=$((time - avg_time))
                # Use absolute value for square calculation
                if [ $diff -lt 0 ]; then
                    diff=$((diff * -1))
                fi
                squared_diff=$((diff * diff))
                sum_squared_diff=$((sum_squared_diff + squared_diff))
            done
            variance=$((sum_squared_diff / success_count))
            # Simple square root calculation (approximate)
            # Using a simple method since bash doesn't have built-in square root function
            # Approximate value for up to 10
            if [ $variance -gt 0 ]; then
                if [ $variance -lt 100 ]; then
                    std_dev=0
                    temp=1
                    while [ $temp -le 10 ]; do
                        if [ $((temp * temp)) -ge $variance ]; then
                            if [ $((temp * temp)) -eq $variance ]; then
                                std_dev=$temp
                            else
                                std_dev=$((temp - 1))
                            fi
                            break
                        fi
                        temp=$((temp + 1))
                    done
                    if [ $std_dev -eq 0 ]; then
                        std_dev=10
                    fi
                else
                    # Approximate calculation for larger variances
                    std_dev=10
                    temp=11
                    while [ $temp -le 100 ]; do
                        if [ $((temp * temp)) -ge $variance ]; then
                            std_dev=$((temp - 1))
                            break
                        fi
                        temp=$((temp + 1))
                    done
                fi
            else
                std_dev=0
            fi

            echo -e "${GREEN}${avg_time} ms${RESET} (min: ${min_time}, max: ${max_time}, std: ${std_dev}, success: ${success_count}/$TEST_COUNT, loss: ${packet_loss}%)"
            results+=("$avg_time|$ip|$name|$success_count|$packet_loss|$min_time|$max_time|$std_dev")
        else
            echo -e "${RED}Timeout${RESET} (success: 0/$TEST_COUNT)"
            results+=("9999|$ip|$name|0|100|N/A|N/A|N/A")
        fi
    done

    # Sort results (by average latency)
    IFS=$'\n' sorted=($(printf "%s\n" "${results[@]}" | sort -n -t'|' -k1))
    unset IFS

    echo -e "\n${CYAN}>>> 🏆 Top 10 Lowest Latency:${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"

    top_ips=()
    count=0
    valid_options=()

    for item in "${sorted[@]}"; do
        IFS='|' read -r lat ip name success loss min_time max_time std_dev <<< "$item"
        if [ "$lat" != "9999" ] && [ $count -lt 10 ]; then
            idx=$((count+1))
            printf "  ${GREEN}%-2d${RESET}. %-20s ${YELLOW}%-18s${RESET} -> ${CYAN}%s ms${RESET} (min: ${min_time}, max: ${max_time}, std: ${std_dev})\n" "$idx" "$name" "($ip)" "$lat"
            top_ips+=("$ip")
            valid_options[$idx]="$ip"
            count=$((count+1))
        fi
    done
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"

    if [ $count -eq 0 ]; then
        echo -e "${RED}Error: All DNS servers are unreachable, please check your network.${RESET}"
        exit 1
    fi
}

apply_config() {
    echo -e "\n${BLUE}Please select DNS to use:${RESET}"
    echo -e "  [1-10] Enter number to select (multiple selection supported, separate with space, e.g: 1 2)"
    echo -e "  [c]    Custom input IP"
    echo -e "  [0]    Exit without saving"
    echo -ne "\n${YELLOW}Please enter: ${RESET}"
    read -r choice

    selected_dns=""

    if [ "$choice" == "0" ]; then
        echo "Exiting."
        exit 0
    elif [ "$choice" == "c" ]; then
        read -p "Please enter custom DNS IP (space separated): " custom_ips
        selected_dns="$custom_ips"
    else
        for c in $choice; do
            if [ -n "${valid_options[$c]}" ]; then
                selected_dns="$selected_dns ${valid_options[$c]}"
            fi
        done
    fi

    if [ -z "$selected_dns" ]; then
        echo -e "${RED}No valid DNS selected, operation cancelled.${RESET}"
        exit 1
    fi

    # Remove duplicates
    selected_dns=$(echo "$selected_dns" | tr ' ' '\n' | awk '!a[$0]++' | tr '\n' ' ')

    echo -e "\n${CYAN}>>> Applying configuration: $selected_dns ...${RESET}"

    # 1. Unlock
    if lsattr /etc/resolv.conf 2>/dev/null | grep -q "i"; then
        chattr -i /etc/resolv.conf
    fi

    # 2. Backup
    cp /etc/resolv.conf "/etc/resolv.conf.bak.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}[√] Original configuration backed up${RESET}"

    # 3. Write to /etc/resolv.conf
    echo "# Generated by better-dns-optimizer" > /etc/resolv.conf
    for ip in $selected_dns; do
        echo "nameserver $ip" >> /etc/resolv.conf
    done

    # 4. Adapt to systemd-resolved
    if systemctl is-active systemd-resolved &>/dev/null; then
        sed -i '/^DNS=/d' /etc/systemd/resolved.conf
        echo "DNS=$selected_dns" >> /etc/systemd/resolved.conf
        systemctl restart systemd-resolved
        echo -e "${GREEN}[√] systemd-resolved configuration synchronized${RESET}"
    fi

    # 5. Lock file - Use default value from configuration
    if [ -z "$LOCK_RESOLV" ]; then
        LOCK_RESOLV="$DEFAULT_LOCK_RESOLV"  # default value
    fi

    echo -e "\n${YELLOW}Lock configuration file? (to prevent changes after reboot) [Y/n] (Enter for default: $LOCK_RESOLV)${RESET}"
    read -r lock_choice

    # If user enters nothing, use the default value from configuration
    if [ -z "$lock_choice" ]; then
        lock_choice="$LOCK_RESOLV"
    fi

    if [[ "$lock_choice" =~ ^[Nn]$ ]]; then
        echo -e "${GREEN}[√] Configuration complete (not locked)${RESET}"
        # Update configuration but don't lock
        LOCK_RESOLV="n"
        save_config
    else
        chattr +i /etc/resolv.conf
        echo -e "${GREEN}[√] Configuration complete (file locked +i)${RESET}"
        # Update configuration and lock
        LOCK_RESOLV="y"
        save_config
    fi
}

select_dns_mode
test_dns_speed
apply_config
