# 🛡️ Linux Security Audit Script

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Bash](https://img.shields.io/badge/Bash-5.0%2B-green.svg)
![Status](https://img.shields.io/badge/Status-Active-brightgreen.svg)

Script d’audit de sécurité Linux en lecture seule, conçu pour fournir une évaluation rapide et fiable de la posture de sécurité d’un système.

Aucune modification système n’est effectuée.

## 🎯 Objectif du projet

Fournir un audit de sécurité simple, lisible et exploitable, sans faux positifs excessifs, basé sur des contrôles concrets observables sur le système.

Ce script est volontairement :

 - non intrusif
 - sans remédiation automatique
 - orienté analyse humaine


## 📋 Fonctionnalités

Le script effectue un audit sur les domaines de sécurité essentiels, adaptés à un diagnostic rapide.

### ✅ Vérifications Incluses

| Domaine | Détails |
|---------|---------|
| **🔐 SSH** | État du service, root login, authentification par mot de passe, port, MaxAuthTries |
| **🔥 Firewall** | Détection de firewall (ufw, iptables, firewalld) |
| **🔗 Ports** | Ports TCP en écoute |
| **🛡️ MAC** | Statut AppArmor |
| **📝 Fichiers** | Fichiers world-writable dans les répertoires critiques |
| **📋 Sudo** | Présence de logs sudo via journald |
| **🔄 Mises à jour** | Statut des mises à jour automatiques |
| **🐧 Kernel** | Version du noyau |
| **👥 Comptes** | Détection de comptes UID 0 supplémentaires |

## 🚀 Installation & Utilisation

### Prérequis
- Linux (Debian, Ubuntu, CentOS, RHEL, Fedora, etc.)
- Bash 5.0 ou supérieur
- Droits root/sudo
- Utilitaires standards : `grep`, `awk`, `find`, `ss`/`netstat`

### Installation

```bash
# Cloner le dépôt
git clone https://github.com/MathisKairis/linux-audit.git
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

### Interprétation

- **🟢 LOW** - Système bien configuré
- **🟡 MEDIUM** - Révision des recommandations nécessaire
- **🔴 HIGH** - Action immédiate requise
  
Le niveau HIGH n’est déclenché que par des événements critiques réels, par exemple :
- compte UID 0 supplémentaire

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


## 🔒 Mode Lecture Seule

**⚠️ Ce script est en mode audit lecture seule uniquement.**

- ❌ Aucune modification de configuration
- ❌ Aucune installation de paquets
- ❌ Aucune modification de permissions
- ✅ Rapports détaillés uniquement

Le script n'effectue que des vérifications et rapports.


## 🛠️ Compatibilité

| Distribution | Support | Notes |
|-------------|---------|-------|
| Ubuntu | ✅ Complet | Testé sur 20.04 LTS+ |
| Debian | ✅ Complet | Support complet |
| RHEL | ✅ Complet | RHEL 8+ |
| Rocky | ✅ Complet | Support complet |
| Alpine | ⚠️ Partiel | Utilitaires limités |


## ⚠️ Limites connues
- Pas de remédiation automatique
- Pas d’export JSON
- Pas de scoring CIS

  Ces choix sont volontaires.




Interprétation finale laissée à l’analyste


## 🤝 Contribution

Les contributions sont bienvenues !

1. Fork le dépôt
2. Créez une branche (`git checkout -b feature/amelioration`)
3. Commitez vos changements (`git commit -m 'Add new audit check'`)
4. Poussez vers la branche (`git push origin feature/amelioration`)
5. Ouvrez une Pull Request



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



## 👨‍💻 Auteur
Mathis Kairis
Projet personnel – cybersécurité & Linux
Open source

**Security Audit Team**
- MIT Licensed
- Open Source
- Community Driven

---

**Dernière mise à jour:** 17 Décembre 2025

Faites une ⭐ si ce projet vous a été utile !



