#!/bin/bash

################################################################################
# Linux Security Audit Script – Quick Edition (Read-Only)
# Version: 1.1.0
################################################################################

set -o pipefail

# --- Variables de couleurs ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Indicateurs Visuels ---
OK="[${GREEN}OK${NC}]"
WARN="[${YELLOW}WARN${NC}]"
FAIL="[${RED}FAIL${NC}]"
INFO="[${BLUE}INFO${NC}]"

# --- Compteurs ---
OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# --- Configuration JSON ---
declare -a JSON_RESULTS
JSON_OUTPUT=false

# ------------------------------------------------------------------------------
# Fonctions Utilitaires
# ------------------------------------------------------------------------------

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_check() {
    local status=$1
    local message=$2
    local clean_status=""
    
    # Affichage standard
    echo -e "${status} ${message}"

    # Mise à jour compteurs et statut pour JSON
    case $status in
        *OK*) 
            ((OK_COUNT++)) 
            clean_status="OK"
            ;;
        *WARN*) 
            ((WARN_COUNT++)) 
            clean_status="WARN"
            ;;
        *FAIL*) 
            ((FAIL_COUNT++)) 
            clean_status="FAIL"
            ;;
        *INFO*) 
            clean_status="INFO"
            ;;
    esac

    # Stockage pour JSON si activé
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        # Échapper les guillemets pour le JSON
        local clean_msg="${message//\"/\\\"}"
        JSON_RESULTS+=("{\"status\": \"$clean_status\", \"message\": \"$clean_msg\"}")
    fi
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: Run this script as root${NC}"
        exit 1
    fi
}

check_script_integrity() {
    local script_path="$0"
    if command -v sha256sum &>/dev/null; then
        local hash=$(sha256sum "$script_path" | awk '{print $1}')
        echo -e "${BLUE}Script SHA256:${NC} $hash"
    fi
}

# ------------------------------------------------------------------------------
# Modules d'Audit
# ------------------------------------------------------------------------------

# 1. System Info
print_system_info() {
    print_header "ℹ️ System Information"
    check_script_integrity
    echo "Hostname: $(hostname)"
    
    # Fallback pour OS detection
    if [ -f /etc/os-release ]; then
        echo "OS: $(. /etc/os-release && echo "$PRETTY_NAME")"
    else
        echo "OS: Unknown (missing /etc/os-release)"
    fi

    # Fallback pour Uptime
    if command -v uptime &>/dev/null; then
        echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    fi
}

# 2. SSH Security (Amélioré v1.1.0)
check_ssh_security() {
    print_header "🔐 SSH Security"

    if ! command -v sshd &>/dev/null; then
        print_check "$FAIL" "OpenSSH server not installed"
        return
    fi

    local SSHD_EFFECTIVE
    SSHD_EFFECTIVE=$(sshd -T 2>/dev/null)

    # Root Login
    if echo "$SSHD_EFFECTIVE" | grep -q "permitrootlogin no"; then
        print_check "$OK" "Root login disabled"
    else
        print_check "$WARN" "Root login might be enabled"
    fi

    # Password Auth
    if echo "$SSHD_EFFECTIVE" | grep -q "passwordauthentication no"; then
        print_check "$OK" "Password authentication disabled"
    else
        print_check "$WARN" "Password authentication might be enabled"
    fi

    # Service Status
    if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
        print_check "$OK" "SSH service running"
    else
        print_check "$WARN" "SSH service not running"
    fi

    # Protocol 2 (Nouveau v1.1.0)
    local proto=$(echo "$SSHD_EFFECTIVE" | awk '/^protocol / {print $2}')
    if [[ "$proto" == "2" ]] || [[ -z "$proto" ]]; then
        # Modern SSH implies proto 2 if not set
        print_check "$OK" "SSH Protocol 2 enforced"
    else
        print_check "$FAIL" "SSH Protocol 1 might be active"
    fi

    # MaxAuthTries (Nouveau v1.1.0)
    local maxauth
    maxauth=$(echo "$SSHD_EFFECTIVE" | awk '/^maxauthtries/ {print $2}')
    if [[ -n "$maxauth" && "$maxauth" -le 4 ]]; then
        print_check "$OK" "MaxAuthTries limited to $maxauth"
    else
        print_check "$WARN" "MaxAuthTries is ${maxauth:-default} (consider <= 4)"
    fi

    # Port
    local port
    port=$(echo "$SSHD_EFFECTIVE" | awk '/^port / {print $2}')
    if [[ "$port" != "22" ]]; then
        print_check "$OK" "SSH running on non-standard port $port"
    else
        print_check "$WARN" "SSH running on standard port 22"
    fi
}

# 3. Firewall
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
        local rules=$(iptables -L -n | grep -c "Chain")
        if [[ $rules -gt 0 ]]; then
             iptables -L -n | grep -q "Chain INPUT" \
                && print_check "$OK" "iptables rules present" \
                || print_check "$WARN" "iptables present but logic unclear"
        fi
    fi

    if command -v firewalld &>/dev/null; then
        detected=1
        systemctl is-active --quiet firewalld \
            && print_check "$OK" "firewalld active" \
            || print_check "$WARN" "firewalld inactive"
    fi

    if [[ "$detected" -eq 0 ]]; then
        print_check "$WARN" "No standard firewall detected"
    fi
}

# 4. Open Ports
check_open_ports() {
    print_header "🔗 Open Ports"
    if command -v ss &>/dev/null; then
        local ports
        ports=$(ss -tln 2>/dev/null | awk 'NR>1 {print $4}' | sed 's/.*://g' | grep -E '^[0-9]+$' | sort -u | tr '\n' ',' | sed 's/,$//')
        print_check "$INFO" "Listening ports: ${ports:-none}"
    else
        print_check "$WARN" "ss command not available"
    fi
}

# 5. MAC
check_mandatory_access_control() {
    print_header "🛡️ Mandatory Access Control"
    if command -v aa-enabled &>/dev/null; then
        aa-enabled 2>/dev/null | grep -q Yes \
            && print_check "$OK" "AppArmor enabled" \
            || print_check "$WARN" "AppArmor disabled"
    elif [ -f /etc/selinux/config ]; then
         grep -q "SELINUX=enforcing" /etc/selinux/config \
            && print_check "$OK" "SELINUX enabled" \
            || print_check "$WARN" "SELINUX disabled/permissive"
    else
        print_check "$WARN" "No MAC system detected"
    fi
}

# 6. Files
check_world_writable_files() {
    print_header "📝 World-Writable Files"
    if find /etc /root /boot -type f -perm -002 2>/dev/null | head -1 | grep -q .; then
        print_check "$FAIL" "World-writable files found in critical dirs"
    else
        print_check "$OK" "No world-writable files in critical dirs"
    fi
}

# 7. Logging
check_sudo_logging() {
    print_header "📋 Sudo Logging"
    if command -v journalctl &>/dev/null; then
        journalctl -u sudo &>/dev/null \
            && print_check "$OK" "Sudo logs available via journald" \
            || print_check "$INFO" "No explicit sudo logs found (checked journald)"
    else
        print_check "$INFO" "journalctl not available (skipping check)"
    fi
}

# 8. Updates
check_automatic_updates() {
    print_header "🔄 Automatic Updates"
    if systemctl is-enabled unattended-upgrades &>/dev/null; then
        print_check "$OK" "Unattended-upgrades enabled"
    elif systemctl is-enabled yum-cron &>/dev/null; then
        print_check "$OK" "yum-cron enabled"
    else
        print_check "$WARN" "Automatic updates might be disabled"
    fi
}

# 9. Kernel
check_kernel_version() {
    print_header "🐧 Kernel Information"
    print_check "$INFO" "Kernel: $(uname -r)"
}

# 10. User Security (Nouveau v1.1.0)
check_user_security() {
    print_header "👥 User & Account Security"

    # UID 0 Check
    local extra_root
    extra_root=$(awk -F: '($3==0)&&($1!="root") {print $1}' /etc/passwd)
    if [[ -n "$extra_root" ]]; then
        print_check "$FAIL" "Extra UID 0 accounts found: $extra_root"
    else
        print_check "$OK" "No extra UID 0 users found"
    fi

    # Empty Password Check
    if [ -r /etc/shadow ]; then
        local empty_pass
        empty_pass=$(awk -F: '($2=="") {print $1}' /etc/shadow)
        if [[ -n "$empty_pass" ]]; then
            print_check "$FAIL" "Accounts with empty password found: $empty_pass"
        else
            print_check "$OK" "No accounts with empty password"
        fi
    else
        print_check "$INFO" "Cannot read /etc/shadow (permission denied)"
    fi
}

# ------------------------------------------------------------------------------
# Export JSON (Nouveau v1.1.0)
# ------------------------------------------------------------------------------
export_json() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local hostname=$(hostname)
    local output_file="audit_report_$(date +%s).json"
    
    local risk_level="LOW"
    if [[ $FAIL_COUNT -gt 0 ]]; then risk_level="HIGH"; 
    elif [[ $WARN_COUNT -gt 3 ]]; then risk_level="MEDIUM"; fi

    # Construction manuelle du JSON pour éviter dépendance jq
    {
        echo "{"
        echo "  \"audit\": {"
        echo "    \"timestamp\": \"$timestamp\","
        echo "    \"hostname\": \"$hostname\","
        echo "    \"version\": \"1.1.0\""
        echo "  },"
        echo "  \"summary\": {"
        echo "    \"ok\": $OK_COUNT,"
        echo "    \"warnings\": $WARN_COUNT,"
        echo "    \"failures\": $FAIL_COUNT,"
        echo "    \"risk_level\": \"$risk_level\""
        echo "  },"
        echo "  \"checks\": ["
        
        local len=${#JSON_RESULTS[@]}
        for (( i=0; i<$len; i++ )); do
            if [[ $i -eq $((len-1)) ]]; then
                echo "    ${JSON_RESULTS[$i]}"
            else
                echo "    ${JSON_RESULTS[$i]},"
            fi
        done
        
        echo "  ]"
        echo "}" 
    } > "$output_file"

    echo -e "\n${INFO} JSON Report generated: ${BLUE}$output_file${NC}"
}

print_summary() {
    print_header "📊 Audit Summary"

    local total=$((OK_COUNT + WARN_COUNT + FAIL_COUNT))

    echo -e "${GREEN}[OK]    $OK_COUNT${NC}"
    echo -e "${YELLOW}[WARN]  $WARN_COUNT${NC}"
    echo -e "${RED}[FAIL]  $FAIL_COUNT${NC}"
    echo "Total:  $total"
    echo ""

    if [[ $FAIL_COUNT -gt 0 ]]; then
        echo -e "Risk Level: ${RED}HIGH${NC} - Immediate action required"
    elif [[ $WARN_COUNT -gt 3 ]]; then
        echo -e "Risk Level: ${YELLOW}MEDIUM${NC} - Review recommendations"
    else
        echo -e "Risk Level: ${GREEN}LOW${NC} - System is well configured"
    fi
}

show_help() {
    echo "Linux Security Audit Script v1.1.0"
    echo "Usage: sudo ./linux_audit.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --json    Export results to a JSON file"
    echo "  --help    Show this help message"
    echo ""
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    # Argument handling
    if [[ "$1" == "--help" ]]; then
        show_help
        exit 0
    fi

    if [[ "$1" == "--json" ]]; then
        JSON_OUTPUT=true
    fi

    clear
    check_root
    
    # Execution des modules
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
    
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        export_json
    fi
}

main "$@"
