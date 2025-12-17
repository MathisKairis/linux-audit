# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- JSON/CSV export functionality
- Email alert integration
- CIS Benchmark compliance checks
- Web dashboard for visualization
- Automated GitHub Actions CI/CD
- Support for more Linux distributions

## [1.0.0] - 2025-12-17

### Added
- Initial release of Linux Security Audit Script
- SSH security checks (root login, password auth, key-based auth)
- Firewall status (UFW, firewalld, iptables)
- Open ports detection
- SELinux and AppArmor verification
- World-writable files detection
- Sudo logging verification
- Automatic updates status
- Kernel version and update requirements
- Docker privileged containers detection
- Backup jobs discovery
- Time synchronization checks
- Colored output with status indicators
- Comprehensive audit summary report
- Read-only mode - no system modifications
- Support for Debian, Ubuntu, CentOS, RHEL, Fedora, Rocky Linux
- Detailed README with examples
- MIT License
- Contributing guidelines
- This changelog

### Features
- 11 security audit categories
- 28+ individual checks
- Color-coded output ([OK], [WARN], [FAIL], [INFO])
- Risk level assessment (LOW, MEDIUM, HIGH)
- Cross-platform compatibility
- Error handling and fallbacks
- Sudo requirement check

---

## How to Update

To stay informed about updates:

1. Watch 👁️ the repository
2. Enable notifications
3. Check this file regularly

## Versioning

- `MAJOR`: Breaking changes
- `MINOR`: New features (backward compatible)
- `PATCH`: Bug fixes

---

**Last Updated**: 2025-12-17
