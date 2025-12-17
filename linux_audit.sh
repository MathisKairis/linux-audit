#!/bin/bash

################################################################################
# Linux Security Audit Script – Quick Edition (Read-Only)
################################################################################

set -o pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

OK="[${GREEN}OK${NC}]"
WARN="[${YELLOW}WARN${NC}]"
FAIL="[${RED}FAIL${NC}]"
INFO="[${BLUE}INFO${NC}]"

OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_check() {
    local status=$1
    local message=$2
    echo -e "${status} ${message}"

    case $status in
        *OK*) ((OK_COUNT++)) ;;
        *WARN*) ((WARN_COUNT++)) ;;
        *FAIL*) ((FAIL_COUNT++)) ;;
    esac
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Run this script as root${NC}"
        exit 1
    fi
}

################################################################################
# System Information
################################################################################
print_system_info() {
    print_header "ℹ️ System Information"
    echo "Hostname: $(hostname)"
    echo "OS: $(. /etc/os-release && echo "$PRETTY_NAME")"
    echo "Uptime: $(uptime -p)"
}

################################################################################
# SSH
################################################################################
check_ssh_security() {
    print_header "🔐 SSH Security"

    if ! command -v sshd &>/dev/null; then
        print_check "$FAIL" "OpenSSH server not installed"
        return
    fi

    local SSHD_EFFECTIVE
    SSHD_EFFECTIVE=$(sshd -T 2>/dev/null)

    if echo "$SSHD_EFFECTIVE" | grep -q "permitrootlogin no"; then
        print_check "$OK" "Root login disabled"
    else
        print_check "$WARN" "Root login might be enabled"
    fi

    if echo "$SSHD_EFFECTIVE" | grep -q "passwordauthentication no"; then
        print_check "$OK" "Password authentication disabled"
    else
        print_check "$WARN" "Password authentication might be enabled"
    fi

    if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
        print_check "$OK" "SSH service running"
    else
        print_check "$WARN" "SSH service not running"
    fi

    local maxauth
    maxauth=$(echo "$SSHD_EFFECTIVE" | awk '/^maxauthtries/ {print $2}')

    if [[ -n "$maxauth" && "$maxauth" -le 3 ]]; then
        print_check "$OK" "MaxAuthTries limited to $maxauth"
    else
        print_check "$WARN" "MaxAuthTries is ${maxauth:-default}"
    fi

    local port
    port=$(echo "$SSHD_EFFECTIVE" | awk '/^port / {print $2}')

    if [[ "$port" != "22" ]]; then
        print_check "$OK" "SSH running on non-standard port $port"
    else
        print_check "$WARN" "SSH running on port 22"
    fi
}

################################################################################
# Firewall
################################################################################
check_firewall() {
    print_header "🔥 Firewall Status"

    local detected=0

    if command -v ufw &>/dev/null; then
        detected=1
        ufw status | grep -q "Status: active" \
            && print_check "$OK" "UFW active" \
            || print_check "$FAIL" "UFW inactive"
    fi

    if command -v iptables &>/dev/null; then
        detected=1
        iptables -L -n | grep -q "Chain INPUT" \
            && print_check "$OK" "iptables rules present" \
            || print_check "$WARN" "iptables present but no rules"
    fi

    if command -v firewalld &>/dev/null; then
        detected=1
        systemctl is-active --quiet firewalld \
            && print_check "$OK" "firewalld active" \
            || print_check "$WARN" "firewalld inactive"
    fi

    if [[ "$detected" -eq 0 ]]; then
        print_check "$WARN" "No firewall detected"
    fi
}

################################################################################
# Open Ports
################################################################################
check_open_ports() {
    print_header "🔗 Open Ports"

    if command -v ss &>/dev/null; then
        local ports
        ports=$(ss -tln 2>/dev/null \
            | awk 'NR>1 {print $4}' \
            | sed 's/.*://g' \
            | grep -E '^[0-9]+$' \
            | sort -u \
            | tr '\n' ',' \
            | sed 's/,$//')

        print_check "$INFO" "Listening ports: ${ports:-none}"
    else
        print_check "$WARN" "ss command not available"
    fi
}

################################################################################
# MAC
################################################################################
check_mandatory_access_control() {
    print_header "🛡️ Mandatory Access Control"

    if command -v aa-enabled &>/dev/null; then
        aa-enabled 2>/dev/null | grep -q Yes \
            && print_check "$OK" "AppArmor enabled" \
            || print_check "$WARN" "AppArmor disabled"
    else
        print_check "$WARN" "No MAC system detected"
    fi
}

################################################################################
# World-Writable Files
################################################################################
check_world_writable_files() {
    print_header "📝 World-Writable Files"

    if find /etc /root /home /boot -type f -perm -002 2>/dev/null | head -1 | grep -q .; then
        print_check "$WARN" "World-writable files found"
    else
        print_check "$OK" "No world-writable files"
    fi
}

################################################################################
# Sudo Logging
################################################################################
check_sudo_logging() {
    print_header "📋 Sudo Logging"

    journalctl -u sudo &>/dev/null \
        && print_check "$OK" "Sudo logs available via journald" \
        || print_check "$WARN" "No sudo logs detected"
}

################################################################################
# Automatic Updates
################################################################################
check_automatic_updates() {
    print_header "🔄 Automatic Updates"

    systemctl is-enabled unattended-upgrades &>/dev/null \
        && print_check "$OK" "Automatic updates enabled" \
        || print_check "$WARN" "Automatic updates disabled"
}

################################################################################
# Kernel
################################################################################
check_kernel_version() {
    print_header "🐧 Kernel Information"
    print_check "$INFO" "Kernel: $(uname -r)"
}

################################################################################
# Users
################################################################################
check_user_security() {
    print_header "👥 User & Account Security"

    if awk -F: '($3==0)&&($1!="root")' /etc/passwd | grep -q .; then
        print_check "$FAIL" "Extra UID 0 accounts found"
    else
        print_check "$OK" "No extra UID 0 users"
    fi
}

################################################################################
# Summary
################################################################################
print_summary() {
    print_header "📊 Audit Summary"

    local total=$((OK_COUNT + WARN_COUNT + FAIL_COUNT))

    echo "[OK]    $OK_COUNT"
    echo "[WARN]  $WARN_COUNT"
    echo "[FAIL]  $FAIL_COUNT"
    echo "Total:  $total"

    if [[ $FAIL_COUNT -gt 0 ]]; then
        echo "Risk Level: HIGH"
    elif [[ $WARN_COUNT -gt 3 ]]; then
        echo "Risk Level: MEDIUM"
    else
        echo "Risk Level: LOW"
    fi
}

################################################################################
# Main
################################################################################
main() {
    clear
    check_root
    print_system_info

    check_ssh_security
    check_firewall
    check_open_ports
    check_mandatory_access_control
    check_world_writable_files
    check_sudo_logging
    check_automatic_updates
    check_kernel_version
    check_user_security

    print_summary
}

main
