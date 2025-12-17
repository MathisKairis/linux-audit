# 🛡️ Linux Security Audit Script

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Bash](https://img.shields.io/badge/Bash-5.0%2B-green.svg)
![Status](https://img.shields.io/badge/Status-Active-brightgreen.svg)

Audit de sécurité automatisé et complet pour les systèmes Linux. **Lecture seule** - aucune modification système ne sera effectuée.

## 📋 Fonctionnalités

Le script effectue un audit complet sur 11 domaines de sécurité critiques :

### ✅ Vérifications Incluses

| Domaine | Détails |
|---------|---------|
| **🔐 SSH** | État du root login, authentification par mot de passe, clés publiques, port SSH |
| **🔥 Firewall** | État UFW/firewalld/iptables, nombre de règles actives |
| **🔗 Ports** | Ports en écoute, services actifs |
| **🛡️ MAC** | SELinux (Enforcing/Permissive), AppArmor status |
| **📝 Fichiers** | Détection de fichiers world-writable dans les répertoires critiques |
| **📋 Sudo** | Configuration de la journalisation sudo, logs disponibles |
| **🔄 Mises à jour** | Unattended-upgrades, yum-cron, services actifs |
| **🐧 Kernel** | Version du kernel, nécessité de redémarrage |
| **🐳 Docker** | Conteneurs privilégiés, configuration userns-remap |
| **💾 Backups** | Jobs de sauvegarde cron/systemd détectés |
| **🕐 Temps** | Synchronisation NTP/Chrony/systemd-timesyncd |

## 🚀 Installation & Utilisation

### Prérequis
- Linux (Debian, Ubuntu, CentOS, RHEL, Fedora, etc.)
- Bash 5.0 ou supérieur
- Droits root/sudo
- Utilitaires standards : `grep`, `awk`, `find`, `ss`/`netstat`

### Installation

```bash
# Cloner le dépôt
git clone https://github.com/votre-username/linux-audit.git
cd linux-audit

# Rendre le script exécutable
chmod +x linux_audit.sh
```

### Utilisation

```bash
# Exécuter l'audit
sudo ./linux_audit.sh

# Ou avec droits root
su -
./linux_audit.sh
```

## 📊 Format de Sortie

Le script utilise un format de sortie standardisé et lisible :

```
[OK]    SSH root login disabled
[WARN]  Password authentication might be enabled
[FAIL]  Firewall is inactive
[INFO]  Listening ports: 22,80,443
```

### Indicateurs de Statut

- **[OK]** - Vérification réussie, pas de problème détecté
- **[WARN]** - Attention requise, configuration à revoir
- **[FAIL]** - Échec critique, action immédiate recommandée
- **[INFO]** - Information générale, pas un statut pass/fail

### Rapport Récapitulatif

À la fin, le script affiche :

```
📊 Audit Summary

[OK]    24 checks passed
[WARN]  3 warnings
[FAIL]  1 failures
Total:  28 checks performed

Risk Level: MEDIUM - Review recommendations

Audit completed at: 2025-12-17 14:30:25
```

### Niveaux de Risque

- **🟢 LOW** - Système bien configuré
- **🟡 MEDIUM** - Révision des recommandations nécessaire
- **🔴 HIGH** - Action immédiate requise

## 💡 Exemples d'Utilisation

### Audit complet
```bash
sudo ./linux_audit.sh
```

### Rediriger la sortie dans un fichier
```bash
sudo ./linux_audit.sh > audit_report.txt 2>&1
```

### Export avec timestamp
```bash
sudo ./linux_audit.sh | tee audit_$(date +%Y%m%d_%H%M%S).log
```

## 📝 Détails des Vérifications

### SSH Security
- ✓ PermitRootLogin est désactivé
- ✓ PasswordAuthentication est désactivé
- ✓ Service SSH actif
- ✓ Authentification par clé publique activée
- ✓ Port SSH non standard (sécurité renforcée)

### Firewall
- ✓ UFW actif et règles configurées
- ✓ iptables avec règles actives
- ✓ firewalld fonctionnel (RHEL/CentOS)

### Mandatory Access Control
- ✓ SELinux en mode Enforcing (idéal)
- ✓ SELinux en mode Permissive (à améliorer)
- ✓ AppArmor activé

### Fichiers World-Writable
- ✓ Scan des répertoires critiques : `/etc`, `/root`, `/home`, `/boot`
- ✓ Identifie les risques de permissions

### Sudo Logging
- ✓ Configuration de la journalisation dans `/etc/sudoers.d`
- ✓ Logs sudo présents dans `/var/log/auth.log` ou `/var/log/secure`

### Mises à Jour Automatiques
- ✓ Unattended-upgrades configuré (Debian/Ubuntu)
- ✓ yum-cron actif (CentOS/RHEL)

### Kernel
- ✓ Version actuelle du kernel
- ✓ Détecte si redémarrage nécessaire

### Docker
- ✓ Conteneurs privilégiés détectés
- ✓ User namespace remapping configuré

### Backups
- ✓ Jobs cron de sauvegarde
- ✓ Timers systemd de sauvegarde

### Synchronisation Horaire
- ✓ Chrony synchronisé
- ✓ NTP en fonctionnement
- ✓ systemd-timesyncd actif

## 🔒 Mode Lecture Seule

**⚠️ Ce script est en mode audit lecture seule uniquement.**

- ❌ Aucune modification de configuration
- ❌ Aucune installation de paquets
- ❌ Aucune modification de permissions
- ✅ Rapports détaillés uniquement

Le script n'effectue que des vérifications et rapports.

## 📊 Résultats & Interprétation

### Résultat : [OK]
La vérification a réussi. Le système respecte cette recommandation de sécurité.

### Résultat : [WARN]
Attention. Cette configuration mérite d'être examinée ou améliorée selon vos besoins.

### Résultat : [FAIL]
Critique. Cette configuration pose un risque de sécurité et nécessite une action.

## 🛠️ Compatibilité

| Distribution | Support | Notes |
|-------------|---------|-------|
| Ubuntu | ✅ Complet | Testé sur 20.04 LTS+ |
| Debian | ✅ Complet | Support complet |
| CentOS | ✅ Complet | CentOS 8+ |
| RHEL | ✅ Complet | RHEL 8+ |
| Fedora | ✅ Complet | Versions récentes |
| Rocky | ✅ Complet | Support complet |
| Alpine | ⚠️ Partiel | Utilitaires limités |

## 🧪 Testing

Pour tester le script dans un environnement Docker :

```bash
# Avec Ubuntu
docker run -it --rm -v $(pwd):/audit ubuntu:22.04 bash
apt-get update && apt-get install -y sudo
cd /audit
chmod +x linux_audit.sh
sudo ./linux_audit.sh

# Avec Debian
docker run -it --rm -v $(pwd):/audit debian:bookworm bash
apt-get update && apt-get install -y sudo
cd /audit
chmod +x linux_audit.sh
sudo ./linux_audit.sh
```

## 📋 Requêtes Système

Le script utilise les commandes système standards :
- `getenforce` - SELinux status
- `aa-enabled` - AppArmor status
- `systemctl` - Service management
- `grep`, `awk`, `find` - Text processing
- `ss` ou `netstat` - Network information
- `docker` - Container inspection
- `chronyc`, `ntpq` - Time sync
- `ufw` - Firewall status

Toutes les erreurs sont supprimées (`2>/dev/null`) pour éviter les messages de bruit.

## 🤝 Contribution

Les contributions sont bienvenues !

1. Fork le dépôt
2. Créez une branche (`git checkout -b feature/amelioration`)
3. Commitez vos changements (`git commit -m 'Add new audit check'`)
4. Poussez vers la branche (`git push origin feature/amelioration`)
5. Ouvrez une Pull Request

### Idées d'Améliorations
- [ ] Support de plus de distros Linux
- [ ] Export JSON/CSV des résultats
- [ ] Gestion des alertes email
- [ ] Comparaison avec benchmarks CIS
- [ ] Dashboard web interactif
- [ ] Tests automatisés

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

## ⚠️ Disclaimer

Ce script est fourni "tel quel" à titre informatif. L'auteur ne peut être tenu responsable des conséquences de son utilisation. 

**Utilisez toujours avec prudence dans les environnements de production.**

Testez d'abord dans un environnement de développement ou un conteneur Docker.

## 📞 Support & Questions

Pour les questions, problèmes ou suggestions :
- 📧 Ouvrez une issue GitHub
- 💬 Participez aux discussions
- 🐛 Signalez les bugs

## 🎯 Roadmap

- [x] Audit SSH complet
- [x] Vérification Firewall
- [x] Détection ports ouverts
- [x] MAG (SELinux/AppArmor)
- [x] Fichiers sensibles
- [x] Logging sudo
- [x] Mises à jour auto
- [x] Info kernel
- [x] Sécurité Docker
- [x] Jobs de sauvegarde
- [x] Sync horaire
- [ ] Export JSON
- [ ] Web dashboard
- [ ] Alertes email
- [ ] Benchmarks CIS

## 👨‍💻 Auteur

**Security Audit Team**
- MIT Licensed
- Open Source
- Community Driven

---

**Dernière mise à jour:** 17 Décembre 2025

Faites une ⭐ si ce projet vous a été utile !
