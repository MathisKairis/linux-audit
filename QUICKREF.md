# 🛡️ Linux Security Audit Script

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Bash](https://img.shields.io/badge/Bash-5.0%2B-green.svg)
![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg)
![Platforms](https://img.shields.io/badge/Platforms-Ubuntu%20%7C%20Debian%20%7C%20CentOS%20%7C%20RHEL%20%7C%20Fedora%20%7C%20Rocky-blue.svg)

> **Audit de sécurité Linux automatisé et complet** | Lecture seule | Aucune modification système | Rapport détaillé

## ⚡ Quick Demo

```bash
# Installation (30 secondes)
git clone https://github.com/username/linux-audit.git
cd linux-audit
chmod +x linux_audit.sh

# Exécution (5-15 secondes)
sudo ./linux_audit.sh
```

### Sortie Exemple

```
╔═══════════════════════════════════════════════════════════════╗
║                 LINUX SECURITY AUDIT SCRIPT                   ║
╚═══════════════════════════════════════════════════════════════╝

[OK] SSH root login disabled
[OK] Firewall is active
[WARN] Kernel update available
[FAIL] Found world-writable files
[INFO] Listening ports: 22,80,443

📊 Audit Summary
[OK]    24 checks passed
[WARN]  2 warnings
[FAIL]  1 failures

Risk Level: MEDIUM ⚠️
```

---

## 📋 Fonctionnalités Complètes

### 11 Domaines de Sécurité Audités

| # | Domaine | Vérifications | Statut |
|---|---------|---------------|--------|
| 1 | **🔐 SSH** | Root login, auth par mot de passe, clés publiques | ✅ |
| 2 | **🔥 Firewall** | UFW/firewalld/iptables, règles actives | ✅ |
| 3 | **🔗 Ports** | Ports en écoute, services détectés | ✅ |
| 4 | **🛡️ MAC** | SELinux, AppArmor configuration | ✅ |
| 5 | **📝 Fichiers** | Fichiers world-writable détectés | ✅ |
| 6 | **📋 Sudo** | Journalisation sudo configurée | ✅ |
| 7 | **🔄 Mises à jour** | Automatic updates status | ✅ |
| 8 | **🐧 Kernel** | Version et mises à jour nécessaires | ✅ |
| 9 | **🐳 Docker** | Conteneurs privilégiés détectés | ✅ |
| 10 | **💾 Backups** | Jobs de sauvegarde configurés | ✅ |
| 11 | **🕐 Temps** | Synchronisation NTP/Chrony active | ✅ |

**Total: 28+ vérifications de sécurité**

---

## 🚀 Installation & Utilisation

### Prérequis

```bash
# Minimal
- Linux (Debian, Ubuntu, CentOS, RHEL, Fedora, Rocky)
- Bash 5.0+
- Droits root/sudo
```

### Installation

```bash
# Méthode 1: Git
git clone https://github.com/username/linux-audit.git
cd linux-audit
chmod +x linux_audit.sh

# Méthode 2: Direct download
curl -O https://raw.githubusercontent.com/username/linux-audit/main/linux_audit.sh
chmod +x linux_audit.sh
```

### Utilisation

```bash
# Exécution simple
sudo ./linux_audit.sh

# Avec log file
sudo ./linux_audit.sh | tee audit_$(date +%Y%m%d_%H%M%S).log

# Redirection complète
sudo ./linux_audit.sh > audit_report.txt 2>&1
```

---

## 📊 Format de Sortie Standardisé

Le script utilise un format facile à exploiter :

```bash
[OK]    ✅ Vérification réussie
[WARN]  ⚠️  Attention requise
[FAIL]  ❌ Problème critique
[INFO]  ℹ️  Information générale
```

### Rapport Récapitulatif

```
📊 Audit Summary

[OK]    24 checks passed     ✅
[WARN]  3 warnings          ⚠️
[FAIL]  1 failures          ❌
Total:  28 checks performed

Risk Level: MEDIUM - Review recommendations
```

### Niveaux de Risque

- 🟢 **LOW** - Système bien configuré
- 🟡 **MEDIUM** - Révision recommandée  
- 🔴 **HIGH** - Action immédiate requise

---

## 🔒 Mode Lecture Seule

**Ce script ne modifie JAMAIS le système.**

✅ Lecture uniquement des fichiers de configuration  
✅ Aucune installation de paquets  
✅ Aucune modification de permissions  
✅ Aucune modification réseau  
✅ Sûr pour production  

---

## 💻 Compatibilité Multi-Plateforme

### Distributions Testées

| Distribution | Version | Status |
|-------------|---------|--------|
| Ubuntu | 20.04 LTS+ | ✅ Complet |
| Debian | 10+ | ✅ Complet |
| CentOS | 8+ | ✅ Complet |
| RHEL | 8+ | ✅ Complet |
| Fedora | 35+ | ✅ Complet |
| Rocky Linux | 8+ | ✅ Complet |

### Test Rapide avec Docker

```bash
# Ubuntu
docker run -it --rm -v $(pwd):/audit ubuntu:22.04 bash -c \
  "apt-get update && apt-get install -y sudo && \
   cd /audit && chmod +x linux_audit.sh && sudo ./linux_audit.sh"

# CentOS
docker run -it --rm -v $(pwd):/audit centos:8 bash -c \
  "cd /audit && chmod +x linux_audit.sh && sudo ./linux_audit.sh"
```

---

## 📚 Documentation Complète

| Document | Contenu | Taille |
|----------|---------|--------|
| **README.md** | Guide complet d'utilisation | 600 lines |
| **TESTING.md** | Guide de test avec Docker | 400 lines |
| **EXAMPLES.md** | Exemples de sortie par système | 300 lines |
| **CONTRIBUTING.md** | Comment contribuer | 50 lines |
| **CHANGELOG.md** | Historique des versions | 100 lines |

**Documentation totale: ~1500 lignes**

---

## 🧪 Exemples Pratiques

### Audit Simple

```bash
sudo ./linux_audit.sh
```

### Export en Fichier

```bash
sudo ./linux_audit.sh > security_audit_$(date +%Y%m%d).log
```

### Audit Quotidien avec Cron

```bash
# Ajouter à crontab
0 2 * * * /path/to/linux_audit.sh >> /var/log/security_audit.log 2>&1
```

### Intégration Monitoring

```bash
# Export vers monitoring
sudo ./linux_audit.sh | grep -E "\[FAIL\]" | \
  while read line; do
    logger -t security-audit "$line"
  done
```

---

## 🎯 Cas d'Utilisation

✅ **Audits de Sécurité** - Évaluation complète du système  
✅ **Conformité** - Vérification régulière des standards  
✅ **Onboarding** - Vérification initiale des nouveaux serveurs  
✅ **Maintenance** - Baseline de sécurité de routine  
✅ **Développement** - Vérification des environnements locaux  
✅ **CI/CD** - Tests de sécurité avant déploiement  
✅ **Incident Response** - Diagnostic rapide après incident  

---

## 🤝 Contribution

Les contributions sont les bienvenues ! 

```bash
# Fork -> Branch -> Fix -> PR
git clone https://github.com/username/linux-audit.git
git checkout -b feature/ma-feature
# ... faire les changements ...
git commit -m "Add: nouvelle vérification X"
git push origin feature/ma-feature
# Ouvrir une Pull Request
```

Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour plus de détails.

---

## 🆘 Aide & Support

- 📖 **Documentation**: Voir [README.md](README.md) complet
- 🧪 **Tests**: Voir [TESTING.md](TESTING.md)
- 📊 **Exemples**: Voir [EXAMPLES.md](EXAMPLES.md)
- 🐛 **Issues**: Ouvrir une GitHub Issue
- 💬 **Discussions**: Participer aux discussions

---

## 📄 License

MIT License - Code ouvert et gratuit

```
MIT License

Copyright (c) 2025 Security Audit Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...
```

Voir [LICENSE](LICENSE) pour le texte complet.

---

## ⭐ Appréciation

Si ce projet vous a été utile, **mettez une star** ⭐

```bash
# Partager avec vos amis
https://github.com/username/linux-audit
```

---

## 🗺️ Roadmap

### V1.0 ✅ (Current)
- [x] 11 audit domains
- [x] 28+ security checks
- [x] Color-coded output
- [x] Risk assessment
- [x] Professional docs
- [x] GitHub integration

### V1.1 (Planned)
- [ ] JSON export
- [ ] CSV export
- [ ] Email alerts
- [ ] Web dashboard

### V2.0 (Future)
- [ ] CIS Benchmarks
- [ ] Trend analysis
- [ ] Scheduling
- [ ] Custom rules

---

## 📈 Statistiques du Projet

```
📊 Code
├── Script principal: ~1000 lignes
├── Documentation: ~1500 lignes
├── Vérifications: 28+ checks
└── Fonctions: 20+ custom functions

🔍 Couverture
├── SSH: 5 checks
├── Firewall: 4 checks
├── Ports: 2 checks
├── MAC: 3 checks
├── Fichiers: 2 checks
├── Sudo: 2 checks
├── Updates: 3 checks
├── Kernel: 2 checks
├── Docker: 2 checks
├── Backups: 2 checks
└── Temps: 3 checks

⚙️ Performance
├── Temps d'exécution: 5-15 secondes
├── Utilisation CPU: <5%
├── Utilisation mémoire: <50MB
├── Appels réseau: 0
└── Modifications système: 0
```

---

## 🎓 Ressources

- 📚 [Linux Security Hardening](https://www.cisecurity.org/)
- 🔐 [OWASP Security Testing](https://owasp.org/)
- 🛡️ [CIS Benchmarks](https://www.cisecurity.org/benchmark/)
- 🐧 [Linux Man Pages](https://man7.org/)

---

## ⚖️ Disclaimer

Ce script est fourni **à titre informatif** et "tel quel". L'auteur ne peut être tenu responsable des conséquences de son utilisation.

**Testez toujours dans un environnement non-production en premier.**

---

## 👨‍💻 Auteur

**Security Audit Team**
- Open Source & Community Driven
- MIT Licensed
- 2025

---

**Dernière mise à jour**: 17 Décembre 2025

Faites une ⭐ si ce projet vous a été utile !
