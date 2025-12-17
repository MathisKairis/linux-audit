#!/bin/bash

################################################################################
# Linux Security Audit Script (Read-Only)
# 
# Description: Automatic security audit for Linux systems
# No system modifications - audit only
# 
# Usage: sudo ./linux_audit.sh
# 
# Author: Security Audit Team
# License: MIT
################################################################################

set -o pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status indicators
OK="[${GREEN}OK${NC}]"
WARN="[${YELLOW}WARN${NC}]"
FAIL="[${RED}FAIL${NC}]"
INFO="[${BLUE}INFO${NC}]"

# Counter for statistics
OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

################################################################################
# Helper Functions
################################################################################

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
        *"OK"*) ((OK_COUNT++)) ;;
        *"WARN"*) ((WARN_COUNT++)) ;;
        *"FAIL"*) ((FAIL_COUNT++)) ;;
    esac
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Erreur: Ce script doit être exécuté avec les droits root${NC}"
        exit 1
    fi
}

################################################################################
# SSH Security Checks
################################################################################

check_ssh_security() {
    print_header "🔐 SSH Security"
    
    SSH_CONFIG="/etc/ssh/sshd_config"
    
    if [ ! -f "$SSH_CONFIG" ]; then
        print_check "$FAIL" "SSH not installed or configuration not found"
        return
    fi
    
    # Check if root login is disabled
    if grep -q "^PermitRootLogin no" "$SSH_CONFIG"; then
        print_check "$OK" "Root login disabled"
    else
        print_check "$WARN" "Root login might be enabled (check: PermitRootLogin)"
    fi
    
    # Check if password authentication is disabled
    if grep -q "^PasswordAuthentication no" "$SSH_CONFIG"; then
        print_check "$OK" "Password authentication disabled"
    else
        print_check "$WARN" "Password authentication might be enabled"
    fi
    
    # Check if SSH service is running
    if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
        print_check "$OK" "SSH service is running"
    else
        print_check "$WARN" "SSH service is not running"
    fi
    
    # Check SSH key-based authentication
    if grep -q "^PubkeyAuthentication yes" "$SSH_CONFIG"; then
        print_check "$OK" "Public key authentication enabled"
    else
        print_check "$WARN" "Public key authentication status unclear"
    fi
    
    # Check SSH port (should not be 22 for better security)
    SSH_PORT=$(grep "^Port " "$SSH_CONFIG" | awk '{print $2}')
    if [ -z "$SSH_PORT" ]; then
        SSH_PORT="22"
    fi
    
    if [ "$SSH_PORT" != "22" ]; then
        print_check "$OK" "SSH running on non-standard port: $SSH_PORT"
    else
        print_check "$WARN" "SSH running on standard port 22"
    fi
}

################################################################################
# Firewall Checks
################################################################################

check_firewall() {
    print_header "🔥 Firewall Status"
    
    # Check UFW (Uncomplicated Firewall)
    if command -v ufw &> /dev/null; then
        if ufw status | grep -q "Status: active"; then
            print_check "$OK" "UFW firewall is active"
            local rules=$(ufw status | grep -c "ALLOW\|DENY\|REJECT")
            print_check "$INFO" "Number of firewall rules: $rules"
        else
            print_check "$FAIL" "UFW firewall is inactive"
        fi
    fi
    
    # Check iptables
    if command -v iptables &> /dev/null; then
        if iptables -L -n | grep -q "Chain INPUT"; then
            local rules=$(iptables -L -n | grep -c "ACCEPT\|DROP\|REJECT")
            if [ "$rules" -gt 5 ]; then
                print_check "$OK" "iptables has active rules: $rules rules configured"
            else
                print_check "$WARN" "iptables has few rules: $rules rules"
            fi
        else
            print_check "$WARN" "iptables not available or no rules"
        fi
    fi
    
    # Check firewalld (CentOS/RHEL)
    if command -v firewalld &> /dev/null; then
        if systemctl is-active --quiet firewalld; then
            print_check "$OK" "firewalld is active"
        else
            print_check "$WARN" "firewalld is not running"
        fi
    fi
}

################################################################################
# Open Ports Check
################################################################################

check_open_ports() {
    print_header "🔗 Open Ports"
    
    if command -v ss &> /dev/null; then
        local listening_ports=$(ss -tlnp 2>/dev/null | grep LISTEN | awk '{print $4}' | cut -d: -f2 | sort -u | tr '\n' ',' | sed 's/,$//')
        
        if [ -n "$listening_ports" ]; then
            print_check "$INFO" "Listening ports: $listening_ports"
        else
            print_check "$WARN" "No listening ports detected or ss not working"
        fi
    elif command -v netstat &> /dev/null; then
        local listening_ports=$(netstat -tlnp 2>/dev/null | grep LISTEN | awk '{print $4}' | cut -d: -f2 | sort -u | tr '\n' ',' | sed 's/,$//')
        print_check "$INFO" "Listening ports: $listening_ports"
    else
        print_check "$WARN" "ss/netstat not available - cannot check ports"
    fi
}

################################################################################
# SELinux / AppArmor Check
################################################################################

check_mandatory_access_control() {
    print_header "🛡️ Mandatory Access Control"
    
    # Check SELinux
    if command -v getenforce &> /dev/null; then
        local selinux_status=$(getenforce)
        if [ "$selinux_status" = "Enforcing" ]; then
            print_check "$OK" "SELinux is Enforcing"
        elif [ "$selinux_status" = "Permissive" ]; then
            print_check "$WARN" "SELinux is Permissive (not enforcing)"
        else
            print_check "$FAIL" "SELinux is Disabled"
        fi
    fi
    
    # Check AppArmor
    if command -v aa-enabled &> /dev/null; then
        if aa-enabled 2>/dev/null; then
            print_check "$OK" "AppArmor is enabled"
        else
            print_check "$WARN" "AppArmor is not enabled"
        fi
    fi
    
    # Check if either is enabled
    if ! command -v getenforce &> /dev/null && ! command -v aa-enabled &> /dev/null; then
        print_check "$WARN" "No MAC system detected (SELinux/AppArmor)"
    fi
}

################################################################################
# World-Writable Files Check
################################################################################

check_world_writable_files() {
    print_header "📝 World-Writable Files"
    
    # Check critical directories
    local critical_dirs=("/etc" "/root" "/home" "/boot")
    local found_files=0
    
    for dir in "${critical_dirs[@]}"; do
        if [ -d "$dir" ]; then
            local www_files=$(find "$dir" -type f -perm -002 2>/dev/null | head -10)
            if [ -n "$www_files" ]; then
                ((found_files++))
                print_check "$WARN" "World-writable files in $dir"
                echo "$www_files" | sed 's/^/    /'
            fi
        fi
    done
    
    if [ $found_files -eq 0 ]; then
        print_check "$OK" "No world-writable files in critical directories"
    fi
}

################################################################################
# Sudo Logging Check
################################################################################

check_sudo_logging() {
    print_header "📋 Sudo Logging"
    
    # Check sudo configuration
    if [ -d "/etc/sudoers.d" ]; then
        if grep -r "log_output\|logfile" /etc/sudoers.d 2>/dev/null | grep -q "log"; then
            print_check "$OK" "Sudo logging appears to be configured"
        else
            print_check "$WARN" "Sudo logging might not be configured"
        fi
    fi
    
    # Check sudo log file
    if [ -f "/var/log/auth.log" ]; then
        local sudo_logs=$(grep -c "sudo" /var/log/auth.log 2>/dev/null || echo "0")
        print_check "$OK" "Auth log found with $sudo_logs sudo entries"
    elif [ -f "/var/log/secure" ]; then
        local sudo_logs=$(grep -c "sudo" /var/log/secure 2>/dev/null || echo "0")
        print_check "$OK" "Secure log found with $sudo_logs sudo entries"
    else
        print_check "$WARN" "No sudo log files found (/var/log/auth.log or /var/log/secure)"
    fi
}

################################################################################
# Automatic Updates Check
################################################################################

check_automatic_updates() {
    print_header "🔄 Automatic Updates"
    
    # Check Ubuntu/Debian
    if [ -f "/etc/apt/apt.conf.d/50unattended-upgrades" ]; then
        if [ -s "/etc/apt/apt.conf.d/50unattended-upgrades" ]; then
            print_check "$OK" "Unattended-upgrades is configured (Ubuntu/Debian)"
        else
            print_check "$WARN" "Unattended-upgrades file exists but empty"
        fi
    fi
    
    # Check if automatic updates service is running
    if systemctl is-active --quiet unattended-upgrades; then
        print_check "$OK" "Unattended-upgrades service is running"
    elif systemctl is-enabled --quiet unattended-upgrades 2>/dev/null; then
        print_check "$OK" "Unattended-upgrades is enabled"
    else
        print_check "$WARN" "Automatic updates service might not be running"
    fi
    
    # Check CentOS/RHEL yum-cron
    if command -v yum-cron &> /dev/null; then
        if systemctl is-active --quiet yum-cron; then
            print_check "$OK" "yum-cron is running (CentOS/RHEL)"
        else
            print_check "$WARN" "yum-cron is not running"
        fi
    fi
}

################################################################################
# Kernel Version Check
################################################################################

check_kernel_version() {
    print_header "🐧 Kernel Information"
    
    local kernel_version=$(uname -r)
    print_check "$INFO" "Kernel version: $kernel_version"
    
    # Check kernel release date (basic check)
    if [[ $kernel_version == *"5."* ]]; then
        print_check "$OK" "Running Linux kernel 5.x (relatively recent)"
    elif [[ $kernel_version == *"6."* ]]; then
        print_check "$OK" "Running Linux kernel 6.x (very recent)"
    else
        print_check "$WARN" "Running older kernel version: $kernel_version"
    fi
    
    # Check if kernel updates are available
    if command -v needrestart &> /dev/null; then
        if needrestart -k 2>/dev/null | grep -q "REQUIRED"; then
            print_check "$WARN" "Kernel update requires restart"
        else
            print_check "$OK" "System up-to-date with kernel"
        fi
    fi
}

################################################################################
# Docker Privileged Containers Check
################################################################################

check_docker_security() {
    print_header "🐳 Docker Security"
    
    if ! command -v docker &> /dev/null; then
        print_check "$INFO" "Docker not installed"
        return
    fi
    
    if ! systemctl is-active --quiet docker; then
        print_check "$INFO" "Docker daemon is not running"
        return
    fi
    
    # Check for privileged containers
    local priv_containers=$(docker ps --format "{{.ID}} {{.Names}}" 2>/dev/null | while read -r id name; do
        if docker inspect "$id" 2>/dev/null | grep -q '"Privileged": true'; then
            echo "$name"
        fi
    done)
    
    if [ -n "$priv_containers" ]; then
        print_check "$FAIL" "Found privileged containers:"
        echo "$priv_containers" | sed 's/^/    /'
    else
        print_check "$OK" "No privileged containers running"
    fi
    
    # Check Docker daemon configuration
    if [ -f "/etc/docker/daemon.json" ]; then
        if grep -q '"userns-remap"' /etc/docker/daemon.json; then
            print_check "$OK" "User namespace remapping is configured"
        else
            print_check "$WARN" "User namespace remapping not configured"
        fi
    fi
}

################################################################################
# Backup Jobs Check
################################################################################

check_backup_jobs() {
    print_header "💾 Backup Jobs"
    
    local backup_found=0
    
    # Check cron jobs
    if [ -d "/etc/cron.d" ] || [ -d "/etc/cron.daily" ]; then
        local cron_backups=$(find /etc/cron.* -type f 2>/dev/null | xargs grep -l "backup\|rsync\|tar\|dd" 2>/dev/null | wc -l)
        if [ "$cron_backups" -gt 0 ]; then
            print_check "$OK" "Backup jobs found in cron: $cron_backups job(s)"
            ((backup_found++))
        fi
    fi
    
    # Check systemd timers
    if command -v systemctl &> /dev/null; then
        local systemd_backups=$(systemctl list-timers --all 2>/dev/null | grep -c "backup\|rsync" || echo "0")
        if [ "$systemd_backups" -gt 0 ]; then
            print_check "$OK" "Backup jobs found in systemd timers: $systemd_backups timer(s)"
            ((backup_found++))
        fi
    fi
    
    if [ $backup_found -eq 0 ]; then
        print_check "$WARN" "No backup jobs detected"
    fi
}

################################################################################
# Time Synchronization Check
################################################################################

check_time_sync() {
    print_header "🕐 Time Synchronization"
    
    local time_sync_found=0
    
    # Check chrony
    if command -v chronyc &> /dev/null; then
        if systemctl is-active --quiet chrony; then
            if chronyc tracking 2>/dev/null | grep -q "Leap status"; then
                print_check "$OK" "Chrony is running and synchronized"
                ((time_sync_found++))
            fi
        fi
    fi
    
    # Check NTP
    if command -v ntpq &> /dev/null; then
        if systemctl is-active --quiet ntp; then
            print_check "$OK" "NTP service is running"
            ((time_sync_found++))
        fi
    fi
    
    # Check systemd-timesyncd
    if systemctl is-active --quiet systemd-timesyncd; then
        print_check "$OK" "systemd-timesyncd is running"
        ((time_sync_found++))
    fi
    
    if [ $time_sync_found -eq 0 ]; then
        print_check "$WARN" "No time synchronization service detected"
    fi
    
    # Show current system time
    local current_time=$(date "+%Y-%m-%d %H:%M:%S %Z")
    print_check "$INFO" "Current system time: $current_time"
}

################################################################################
# System Information
################################################################################

print_system_info() {
    print_header "ℹ️ System Information"
    
    echo -e "${BLUE}Hostname:${NC} $(hostname)"
    echo -e "${BLUE}OS:${NC} $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
    echo -e "${BLUE}Uptime:${NC} $(uptime -p)"
    echo -e "${BLUE}CPU Count:${NC} $(nproc)"
    echo -e "${BLUE}Total Memory:${NC} $(free -h | awk 'NR==2 {print $2}')"
    echo ""
}

################################################################################
# Summary Report
################################################################################

print_summary() {
    print_header "📊 Audit Summary"
    
    local total=$((OK_COUNT + WARN_COUNT + FAIL_COUNT))
    
    echo -e "${GREEN}[OK]${NC}    $OK_COUNT checks passed"
    echo -e "${YELLOW}[WARN]${NC}  $WARN_COUNT warnings"
    echo -e "${RED}[FAIL]${NC}  $FAIL_COUNT failures"
    echo -e "${BLUE}Total:${NC}  $total checks performed\n"
    
    # Risk assessment
    if [ $FAIL_COUNT -gt 0 ]; then
        echo -e "${RED}Risk Level: HIGH${NC} - Immediate action required"
    elif [ $WARN_COUNT -gt 3 ]; then
        echo -e "${YELLOW}Risk Level: MEDIUM${NC} - Review recommendations"
    else
        echo -e "${GREEN}Risk Level: LOW${NC} - System is well configured"
    fi
    
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "Audit completed at: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

################################################################################
# Main Execution
################################################################################

main() {
    clear
    
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                 LINUX SECURITY AUDIT SCRIPT                   ║"
    echo "║                      Read-Only Mode                           ║"
    echo "║                                                               ║"
    echo "║              No system modifications will be made             ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    check_root
    
    print_system_info
    
    # Run all checks
    check_ssh_security
    check_firewall
    check_open_ports
    check_mandatory_access_control
    check_world_writable_files
    check_sudo_logging
    check_automatic_updates
    check_kernel_version
    check_docker_security
    check_backup_jobs
    check_time_sync
    
    # Print summary
    print_summary
}

# Run main function
main "$@"
