# Linux Audit Script - Configuration Examples

This document provides examples of expected outputs for different system configurations.

## Secure Ubuntu Server

### Configuration
- SSH: Root login disabled, key-based auth only
- Firewall: UFW active with rules
- SELinux: Not applicable (Ubuntu)
- AppArmor: Enabled
- Kernel: Latest LTS version
- Automatic updates:
 Enabled
- Docker: None or non-privileged containers

### Expected Output

```
╔════════════════════════════════════════════════════════════════╗
║ 🔐 SSH Security
╚════════════════════════════════════════════════════════════════╝

[OK] Root login disabled
[OK] Public key authentication enabled
[OK] SSH service is running
[WARN] SSH running on standard port 22
[OK] SSH key-based authentication configured

╔════════════════════════════════════════════════════════════════╗
║ 🔥 Firewall Status
╚════════════════════════════════════════════════════════════════╝

[OK] UFW firewall is active
[INFO] Number of firewall rules: 15
[OK] iptables has active rules: 32 rules configured

╔════════════════════════════════════════════════════════════════╗
║ 🛡️ Mandatory Access Control
╚════════════════════════════════════════════════════════════════╝

[OK] AppArmor is enabled

╔════════════════════════════════════════════════════════════════╗
║ 📝 World-Writable Files
╚════════════════════════════════════════════════════════════════╝

[OK] No world-writable files in critical directories

...

📊 Audit Summary

[OK]    24 checks passed
[WARN]  2 warnings
[FAIL]  0 failures
Total:  26 checks performed

Risk Level: LOW - System is well configured
```

---

## CentOS/RHEL Enterprise Server

### Configuration
- SELinux: Enforcing mode
- firewalld: Active
- yum-cron: Enabled for automatic updates
- Docker: Present with namespace remapping

### Expected Output

```
╔════════════════════════════════════════════════════════════════╗
║ 🛡️ Mandatory Access Control
╚════════════════════════════════════════════════════════════════╝

[OK] SELinux is Enforcing

╔════════════════════════════════════════════════════════════════╗
║ 🔥 Firewall Status
╚════════════════════════════════════════════════════════════════╝

[OK] firewalld is active

╔════════════════════════════════════════════════════════════════╗
║ 🔄 Automatic Updates
╚════════════════════════════════════════════════════════════════╝

[OK] yum-cron is running (CentOS/RHEL)

╔════════════════════════════════════════════════════════════════╗
║ 🐳 Docker Security
╚════════════════════════════════════════════════════════════════╝

[OK] No privileged containers running
[OK] User namespace remapping is configured

📊 Audit Summary

[OK]    26 checks passed
[WARN]  1 warnings
[FAIL]  0 failures
Total:  27 checks performed

Risk Level: LOW - System is well configured
```

---

## Development Laptop (Less Secure)

### Configuration
- Firewall: Disabled for development
- SSH: Standard configuration
- Docker: Some privileged containers for local dev
- Automatic updates: Disabled

### Expected Output

```
╔════════════════════════════════════════════════════════════════╗
║ 🔥 Firewall Status
╚════════════════════════════════════════════════════════════════╝

[FAIL] UFW firewall is inactive

╔════════════════════════════════════════════════════════════════╗
║ 🔐 SSH Security
╚════════════════════════════════════════════════════════════════╝

[WARN] Root login might be enabled (check: PermitRootLogin)
[WARN] Password authentication might be enabled

╔════════════════════════════════════════════════════════════════╗
║ 🐳 Docker Security
╚════════════════════════════════════════════════════════════════╝

[FAIL] Found privileged containers:
    dev-container
    test-postgres

╔════════════════════════════════════════════════════════════════╗
║ 🔄 Automatic Updates
╚════════════════════════════════════════════════════════════════╝

[WARN] Automatic updates service might not be running

📊 Audit Summary

[OK]    14 checks passed
[WARN]  4 warnings
[FAIL]  2 failures
Total:  20 checks performed

Risk Level: MEDIUM - Review recommendations
```

---

## Hardened Security Server

### Configuration
- SSH: Non-standard port, root disabled, key-only auth
- Firewall: Active with minimal rules (only required ports)
- SELinux: Enforcing with custom policies
- Kernel: Latest with security patches
- Backup: Regular automated backups configured
- Time: Chrony synchronized to multiple NTP servers

### Expected Output

```
╔════════════════════════════════════════════════════════════════╗
║ 🔐 SSH Security
╚════════════════════════════════════════════════════════════════╝

[OK] Root login disabled
[OK] Password authentication disabled
[OK] SSH service is running
[OK] Public key authentication enabled
[OK] SSH running on non-standard port: 2222

╔════════════════════════════════════════════════════════════════╗
║ 🔥 Firewall Status
╚════════════════════════════════════════════════════════════════╝

[OK] UFW firewall is active
[INFO] Number of firewall rules: 8

╔════════════════════════════════════════════════════════════════╗
║ 🛡️ Mandatory Access Control
╚════════════════════════════════════════════════════════════════╝

[OK] SELinux is Enforcing

╔════════════════════════════════════════════════════════════════╗
║ 💾 Backup Jobs
╚════════════════════════════════════════════════════════════════╝

[OK] Backup jobs found in cron: 2 job(s)

╔════════════════════════════════════════════════════════════════╗
║ 🕐 Time Synchronization
╚════════════════════════════════════════════════════════════════╝

[OK] Chrony is running and synchronized

📊 Audit Summary

[OK]    28 checks passed
[WARN]  0 warnings
[FAIL]  0 failures
Total:  28 checks performed

Risk Level: LOW - System is well configured
```

---

## Legacy System (Needs Updates)

### Configuration
- Old Linux kernel
- No firewall configured
- Unattended-upgrades disabled
- No backup jobs

### Expected Output

```
╔════════════════════════════════════════════════════════════════╗
║ 🐧 Kernel Information
╚════════════════════════════════════════════════════════════════╝

[INFO] Kernel version: 4.15.0-72-generic
[WARN] Running older kernel version: 4.15.0-72-generic
[WARN] Kernel update requires restart

╔════════════════════════════════════════════════════════════════╗
║ 🔥 Firewall Status
╚════════════════════════════════════════════════════════════════╝

[WARN] UFW firewall is inactive

╔════════════════════════════════════════════════════════════════╗
║ 🔄 Automatic Updates
╚════════════════════════════════════════════════════════════════╝

[WARN] Automatic updates service might not be running

╔════════════════════════════════════════════════════════════════╗
║ 💾 Backup Jobs
╚════════════════════════════════════════════════════════════════╝

[WARN] No backup jobs detected

📊 Audit Summary

[OK]    12 checks passed
[WARN]  8 warnings
[FAIL]  2 failures
Total:  22 checks performed

Risk Level: HIGH - Immediate action required
```

---

## How to Use These Examples

1. **Compare** your system's output with these examples
2. **Identify** areas where your system differs significantly
3. **Review** the [README.md](README.md) for remediation steps
4. **Test** fixes in a non-production environment first
5. **Re-run** the audit to verify improvements

## Customization

You can extend the script by:

1. Adding new functions for custom checks
2. Adjusting severity levels for your environment
3. Creating distribution-specific variants
4. Integrating with monitoring systems

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

**Last Updated**: 2025-12-17
