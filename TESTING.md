# Testing Guide

## Test Environment Setup

### Option 1: Local Linux Machine

```bash
# Clone the repo
git clone https://github.com/your-username/linux-audit.git
cd linux-audit

# Make executable
chmod +x linux_audit.sh

# Run the audit
sudo ./linux_audit.sh
```

### Option 2: Docker (Recommended for Testing)

#### Ubuntu 22.04 LTS

```bash
docker run -it --rm \
  -v $(pwd):/audit \
  ubuntu:22.04 bash -c \
  "apt-get update && \
   apt-get install -y sudo systemctl && \
   cd /audit && \
   chmod +x linux_audit.sh && \
   sudo ./linux_audit.sh"
```

#### Debian Bookworm

```bash
docker run -it --rm \
  -v $(pwd):/audit \
  debian:bookworm bash -c \
  "apt-get update && \
   apt-get install -y sudo && \
   cd /audit && \
   chmod +x linux_audit.sh && \
   sudo ./linux_audit.sh"
```

#### CentOS 8

```bash
docker run -it --rm \
  -v $(pwd):/audit \
  centos:8 bash -c \
  "cd /audit && \
   chmod +x linux_audit.sh && \
   sudo ./linux_audit.sh"
```

#### Rocky Linux 9

```bash
docker run -it --rm \
  -v $(pwd):/audit \
  rockylinux:9 bash -c \
  "cd /audit && \
   chmod +x linux_audit.sh && \
   sudo ./linux_audit.sh"
```

### Option 3: WSL2 (Windows)

```bash
# In PowerShell on Windows
wsl --install -d Ubuntu-22.04

# Then in the WSL terminal
git clone https://github.com/your-username/linux-audit.git
cd linux-audit
chmod +x linux_audit.sh
sudo ./linux_audit.sh
```

## Expected Output

When running successfully, you should see:

```
╔═══════════════════════════════════════════════════════════════╗
║                 LINUX SECURITY AUDIT SCRIPT                   ║
║                      Read-Only Mode                           ║
║                                                               ║
║              No system modifications will be made             ║
╚═══════════════════════════════════════════════════════════════╝

Hostname: myserver
OS: Ubuntu 22.04.1 LTS
Uptime: 2 days, 3 hours
CPU Count: 4
Total Memory: 8.0G

╔════════════════════════════════════════════════════════════════╗
║ 🔐 SSH Security
╚════════════════════════════════════════════════════════════════╝

[OK] Root login disabled
[OK] Public key authentication enabled
[WARN] SSH running on standard port 22
...
```

## Test Scenarios

### Secure System

A well-configured system should show:
- Mostly [OK] statuses
- Few [WARN] entries
- No [FAIL] entries
- Risk Level: LOW

### Warning System

A system needing attention should show:
- Mixed [OK] and [WARN]
- Some [FAIL] entries
- Risk Level: MEDIUM or HIGH

### Unsecured System

A poorly configured system will show:
- Multiple [FAIL] entries
- Risk Level: HIGH
- Action items needed

## Verifying Specific Checks

### Verify SSH Check
```bash
# Check actual SSH config
grep "PermitRootLogin" /etc/ssh/sshd_config
grep "PasswordAuthentication" /etc/ssh/sshd_config
```

### Verify Firewall Check
```bash
# Check UFW
sudo ufw status

# Or check iptables
sudo iptables -L -n
```

### Verify World-Writable Files
```bash
# Manually check for world-writable files
find /etc -type f -perm -002 2>/dev/null
find /root -type f -perm -002 2>/dev/null
```

### Verify Backup Jobs
```bash
# Check cron jobs
ls /etc/cron.d
ls /etc/cron.daily

# Check systemd timers
systemctl list-timers
```

### Verify Time Sync
```bash
# Check NTP/Chrony
chronyc tracking    # If using Chrony
ntpstat            # If using NTP
systemctl status systemd-timesyncd  # If using systemd-timesyncd
```

## Known Issues & Workarounds

### Issue: "sudo: sorry, you must have a tty to run sudo"

**Solution**: Use Docker with `-it` flags or allocate a tty

### Issue: "service not found" warnings

**Solution**: Normal - script checks for various services based on distro

### Issue: Permission denied on audit output

**Solution**: Run with `sudo` or redirect to a writable location

## Performance Notes

- **Execution Time**: 5-15 seconds depending on system
- **CPU Usage**: Minimal (<5%)
- **Memory Usage**: <50MB
- **Network**: No network calls made
- **Disk I/O**: Minimal read-only operations

## Troubleshooting

### Script doesn't run

1. Check permissions: `ls -l linux_audit.sh`
2. Check bash version: `bash --version`
3. Verify syntax: `bash -n linux_audit.sh`
4. Try with explicit bash: `bash linux_audit.sh`

### Permission denied errors

All checks use `2>/dev/null` to suppress permission errors. If you see many errors:
- Run with `sudo`
- Check you have read permissions on `/etc/ssh/sshd_config` and other config files

### Docker compatibility issues

- Some Docker images have minimal tools - use `-slim` or `-full` variants
- Alpine Linux has limited package availability
- Official images are recommended

## Contributing Test Cases

If you find issues with specific distributions:

1. Document the OS and version
2. Show the error output
3. Include output of `uname -a`
4. Submit a GitHub issue with [TEST] tag

## Automated Testing

The GitHub Actions CI automatically:
- Checks bash syntax
- Runs ShellCheck linting
- Tests on Ubuntu latest

For local testing before pushing:

```bash
# Check syntax
bash -n linux_audit.sh

# Run ShellCheck (if installed)
shellcheck linux_audit.sh

# Test on Docker
./test-docker.sh
```

---

**Last Updated**: 2025-12-17
