#!/bin/bash

################################################################################
# Linux Security Audit Script (Read-Only)
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
JSON_OUTPUT=0

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
    [[ $EUID -ne 0 ]] && echo -e "${RED}Run as root${NC}" && exit 1
}

check_script_integrity() {
    command -v sha256sum &>/dev/null && \
    echo -e "${BLUE}Script SHA256: $(sha256sum "$0" | awk '{print $1}')${NC}"
}

################################################################################
# SSH
################################################################################
check_ssh_security() {
    print_header "🔐 SSH Security"

    [[ ! -f /etc/ssh/sshd_config ]] && print_check "$FAIL" "SSH not installed" && return

    if command -v sshd &>/dev/null; then
        SSHD_EFFECTIVE=$(sshd -T 2>/dev/null)
    fi

    echo "$SSHD_EFFECTIVE" | grep -q "permitrootlogin no" \
        && print_check "$OK" "Root login disabled (effective)" \
        || print_check "$WARN" "Root login might be enabled"

    echo "$SSHD_EFFECTIVE" | grep -q "passwordauthentication no" \
        && print_check "$OK" "Password authentication disabled (effective)" \
        || print_check "$WARN" "Password authentication might be enabled"

    systemctl is-active --quiet ssh || systemctl is-active --quiet sshd \
        && print_check "$OK" "SSH service running" \
        || print_check "$WARN" "SSH service not running"

    local maxauth=$(echo "$SSHD_EFFECTIVE" | grep maxauthtries | awk '{print $2}')
    [[ -n "$maxauth" && "$maxauth" -le 3 ]] \
        && print_check "$OK" "MaxAuthTries limited to $maxauth" \
        || print_check "$WARN" "MaxAuthTries is $maxauth"

    local port=$(echo "$SSHD_EFFECTIVE" | grep "^port " | awk '{print $2}')
    [[ "$port" != "22" ]] \
        && print_check "$OK" "SSH on non-standard port $port" \
        || print_check "$WARN" "SSH running on port 22"
}

################################################################################
# FIREWALL
################################################################################
check_firewall() {
    print_header "🔥 Firewall Status"
    local detected=0

    if command -v ufw &>/dev/null; then
        detected=1
        ufw status | grep -q "active" \
            && print_check "$OK" "UFW active" \
            || print_check "$FAIL" "UFW inactive"
    fi

    if command -v iptables &>/dev/null; then
        detected=1
        iptables -L -n | grep -q "Chain INPUT" \
            && print_check "$OK" "iptables rules present" \
            || print_check "$WARN" "iptables empty"
    fi

    if command -v firewalld &>/dev/null; then
        detected=1
        systemctl is-active --quiet firewalld \
            && print_check "$OK" "firewalld active" \
            || print_check "$WARN" "firewalld inactive"
    fi

    [[ "$detected" -eq 0 ]] && print_check "$WARN" "No firewall detected"
}

################################################################################
# PORTS
################################################################################
check_open_ports() {
    print_header "🔗 Open Ports"

    if command -v ss &>/dev/null; then
        ports=$(ss -tln | awk '{print $4}' | cut -d: -f2 | grep -v '^$' | sort -u | tr '\n' ',' | sed 's/,$//')
        print_check "$INFO" "Listening ports: ${ports:-none}"
    else
        print_check "$WARN" "ss not available"
    fi
}

################################################################################
# MAC
################################################################################
check_mandatory_access_control() {
    print_header "🛡️ Mandatory Access Control"

    command -v getenforce &>/dev/null && {
        [[ "$(getenforce)" == "Enforcing" ]] \
            && print_check "$OK" "SELinux Enforcing" \
            || print_check "$WARN" "SELinux not enforcing"
    }

    command -v aa-enabled &>/dev/null && {
        aa-enabled 2>/dev/null | grep -q Yes \
            && print_check "$OK" "AppArmor enabled" \
            || print_check "$WARN" "AppArmor disabled"
    }
}

################################################################################
# FILES
################################################################################
check_world_writable_files() {
    print_header "📝 World-Writable Files"
    find /etc /root /home /boot -type f -perm -002 2>/dev/null | head -1 \
        && print_check "$WARN" "World-writable files found" \
        || print_check "$OK" "No world-writable files"
}

################################################################################
# SUDO
################################################################################
check_sudo_logging() {
    print_header "📋 Sudo Logging"

    journalctl -u sudo &>/dev/null \
        && print_check "$OK" "Sudo logs via journald" \
        || print_check "$WARN" "No sudo logs detected"
}

################################################################################
# UPDATES
################################################################################
check_automatic_updates() {
    print_header "🔄 Automatic Updates"

    systemctl is-enabled unattended-upgrades &>/dev/null \
        && print_check "$OK" "Unattended upgrades enabled" \
        || print_check "$WARN" "Automatic updates disabled"
}

################################################################################
# KERNEL
################################################################################
check_kernel_version() {
    print_header "🐧 Kernel Information"
    local k=$(uname -r)
    print_check "$INFO" "Kernel: $k"
}

################################################################################
# DOCKER
################################################################################
check_docker_security() {
    print_header "🐳 Docker Security"
    command -v docker &>/dev/null \
        && print_check "$INFO" "Docker installed" \
        || print_check "$INFO" "Docker not installed"
}

################################################################################
# USERS
################################################################################
check_user_security() {
    print_header "👥 User & Account Security"

    awk -F: '($3==0)&&($1!="root")' /etc/passwd | grep -q . \
        && print_check "$FAIL" "Extra UID 0 accounts found" \
        || print_check "$OK" "No extra UID 0 users"
}

################################################################################
# SYSTEM INFO
################################################################################
print_system_info() {
    print_header "ℹ️ System Information"
    echo "Hostname: $(hostname)"
    echo "OS: $(. /etc/os-release && echo "$PRETTY_NAME")"
    echo "Uptime: $(uptime -p)"
}

################################################################################
# SUMMARY
################################################################################
print_summary() {
    print_header "📊 Audit Summary"
    local total=$((OK_COUNT + WARN_COUNT + FAIL_COUNT))
    echo "[OK]    $OK_COUNT"
    echo "[WARN]  $WARN_COUNT"
    echo "[FAIL]  $FAIL_COUNT"
    echo "Total:  $total"

    [[ $FAIL_COUNT -gt 0 ]] && echo "Risk Level: HIGH" \
    || [[ $WARN_COUNT -gt 3 ]] && echo "Risk Level: MEDIUM" \
    || echo "Risk Level: LOW"
}

################################################################################
# MAIN
################################################################################
main() {
    clear
    check_root
    check_script_integrity
    print_system_info

    check_ssh_security
    check_firewall
    check_open_ports
    check_mandatory_access_control
    check_world_writable_files
    check_sudo_logging
    check_automatic_updates
    check_kernel_version
    check_docker_security
    check_user_security

    print_summary
}

main
