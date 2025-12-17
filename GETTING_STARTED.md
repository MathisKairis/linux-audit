# 🚀 Getting Started

Bienvenue dans **Linux Security Audit Script** ! 

Ce guide vous aidera à commencer en 5 minutes.

## 1️⃣ Installation (1 minute)

### Option A: Git (Recommandé)

```bash
git clone https://github.com/username/linux-audit.git
cd linux-audit
chmod +x linux_audit.sh
```

### Option B: Direct Download

```bash
curl -O https://raw.githubusercontent.com/username/linux-audit/main/linux_audit.sh
chmod +x linux_audit.sh
```

### Option C: Docker (Recommended - Most Compatible)

**Note**: The script auto-detects missing commands and provides fallbacks. Docker images may be minimal but fully supported.

```bash
docker run -it --rm -v $(pwd):/audit ubuntu:22.04 bash -c \
  "apt-get update && apt-get install -y sudo && \
   cd /audit && chmod +x linux_audit.sh && sudo ./linux_audit.sh"
```

**Alternative with more tools pre-installed**:
```bash
docker run -it --rm -v $(pwd):/audit ubuntu:22.04 bash -c \
  "apt-get update && apt-get install -y sudo curl net-tools && \
   cd /audit && chmod +x linux_audit.sh && sudo ./linux_audit.sh"
```

---

## 2️⃣ Exécution (30 secondes)

```bash
# Audit simple
sudo ./linux_audit.sh

# OU avec log file
sudo ./linux_audit.sh | tee audit_report.log

# Export en JSON (pour dashboard/CI-CD)
sudo ./linux_audit.sh --json
```

---

## 2️⃣bis Vérifier l'Intégrité du Script

**Avant d'exécuter**, vérifiez que le script n'a pas été altéré lors du téléchargement :

```bash
# Le script affiche automatiquement son SHA256
sudo ./linux_audit.sh | head -20 | grep "SHA256"

# Ou vérifier manuellement
sha256sum linux_audit.sh

# Comparer avec les checksums publiés sur GitHub
```

Le checksum SHA256 est une empreinte cryptographique qui change si le fichier est modifié, même d'un seul byte.

---

## 3️⃣ Lisez le Rapport

Le script affichera un rapport formaté :

```
╔═══════════════════════════════════════════════════════════════╗
║                 LINUX SECURITY AUDIT SCRIPT                   ║
╚═══════════════════════════════════════════════════════════════╝

Hostname: myserver
OS: Ubuntu 22.04 LTS
...

[OK] SSH root login disabled
[OK] Firewall is active
[WARN] SSH running on standard port 22
[FAIL] World-writable files found
[INFO] Listening ports: 22,80,443

📊 Audit Summary
[OK]    24 checks passed
[WARN]  2 warnings  
[FAIL]  1 failures

Risk Level: MEDIUM ⚠️
```

---

## 4️⃣ Comprendre le Résultat

### Les Statuts

| Statut | Signification | Action |
|--------|---------------|--------|
| **[OK]** ✅ | Aucun problème | Continuez ! |
| **[WARN]** ⚠️ | À revoir | Examinez et considérez une amélioration |
| **[FAIL]** ❌ | Problème critique | Action immédiate recommandée |
| **[INFO]** ℹ️ | Information | Juste à titre informatif |

### Niveaux de Risque

- **🟢 LOW** - Tout va bien !
- **🟡 MEDIUM** - Quelques points à améliorer
- **🔴 HIGH** - Problèmes critiques à résoudre

---

## 5️⃣ Prochaines Étapes

### Si vous avez un risque LOW ✅

Bravo ! Votre système est bien configuré.

- Continuez à maintenir les bonnes pratiques
- Re-lancez l'audit mensuellement
- Gardez le kernel et les paquets à jour

### Si vous avez un risque MEDIUM ⚠️

Examinez les warnings :

1. Lisez chaque [WARN] et [FAIL]
2. Consultez le [README.md](README.md) complet pour les solutions
3. Appliquez les améliorations une par une
4. Re-lancez l'audit après chaque changement

### Si vous avez un risque HIGH 🔴

Agissez immédiatement :

1. Priorisez les [FAIL] en premier
2. Consultez [EXAMPLES.md](EXAMPLES.md) pour les patterns de configuration
3. Testez les changements dans un environnement non-production
4. Documentez chaque changement
5. Re-testez avec le script

---

## 📚 Documentation Complète

| Document | Utilité | Lire si... |
|----------|---------|-----------|
| **README.md** | Documentation complète | Vous voulez tous les détails |
| **QUICKREF.md** | Guide de référence rapide | Vous avez besoin d'une vue d'ensemble |
| **TESTING.md** | Guide de test | Vous voulez tester sur plusieurs distros |
| **EXAMPLES.md** | Exemples de sortie | Vous voulez comparer votre résultat |
| **CONTRIBUTING.md** | Comment aider | Vous voulez contribuer |

---

## 🆘 Questions Fréquentes

### Q: J'ai une erreur "Permission denied"

**R:** Assurez-vous que le script est exécutable :

```bash
chmod +x linux_audit.sh
sudo ./linux_audit.sh  # Lancez avec sudo
```

### Q: Script ne s'exécute pas du tout

**R:** Vérifiez que bash est disponible :

```bash
bash --version
bash -n linux_audit.sh  # Vérifie la syntaxe
```

### Q: Comment exporter le résultat ?

**R:** Plusieurs options :

```bash
# Fichier texte simple
sudo ./linux_audit.sh > audit.txt

# Avec log colorisé
sudo ./linux_audit.sh | tee audit_$(date +%Y%m%d).log

# JSON (futur)
# sudo ./linux_audit.sh --json > audit.json
```

### Q: Puis-je automatiser l'audit ?

**R:** Oui ! Ajoutez à cron :

```bash
# Éditer crontab
crontab -e

# Ajouter (audit quotidien à 2h du matin)
0 2 * * * /home/user/linux_audit/linux_audit.sh >> /var/log/security_audit.log 2>&1
```

### Q: Est-il sûr de lancer sur production ?

**R:** Oui ! C'est du mode audit uniquement :

- ✅ Aucune modification système
- ✅ Aucune installation de paquets
- ✅ Aucune modification de permissions
- ✅ Aucun risque

Vous pouvez lancer sans crainte.

### Q: Quelles sont les dépendances ?

**R:** Seulement les outils standard Linux :

```bash
# Tout système Linux a ces outils
- bash
- grep, awk, find
- ss ou netstat
- systemctl
```

Aucune installation supplémentaire nécessaire.

---

## 🎯 Cas d'Usage Communs

### Cas 1: Audit Seul

```bash
sudo ./linux_audit.sh
```

### Cas 2: Audit + Sauvegarde

```bash
sudo ./linux_audit.sh | tee audit_$(date +%Y%m%d_%H%M%S).log
```

### Cas 3: Audit Quotidien Automatisé

```bash
# Dans crontab
0 2 * * * /opt/linux-audit/linux_audit.sh >> /var/log/security.log 2>&1
```

### Cas 4: Alert sur Problèmes

```bash
sudo ./linux_audit.sh | grep -E "\[FAIL\]" | mail -s "Security Alert" admin@example.com
```

### Cas 5: Test dans Docker

```bash
docker run -it --rm -v $(pwd):/audit debian:bookworm bash -c \
  "apt-get update && apt-get install -y sudo && \
   cd /audit && chmod +x linux_audit.sh && sudo ./linux_audit.sh"
```

---

## 🔍 Vérifications Disponibles

### SSH (5 checks)
- ✓ Root login disabled
- ✓ Password authentication status
- ✓ Service running
- ✓ Public key auth enabled
- ✓ Port configuration

### Firewall (3 checks)
- ✓ UFW status
- ✓ iptables rules
- ✓ firewalld status

### Sécurité (11 plus)
- ✓ SELinux / AppArmor
- ✓ World-writable files
- ✓ Sudo logging
- ✓ Automatic updates
- ✓ Kernel version
- ✓ Docker security
- ✓ Backups
- ✓ Time sync
- ✓ Et plus...

---

## 💡 Tips & Tricks

### Tip 1: Exporter en texte brut (pour archivage)

```bash
sudo ./linux_audit.sh > audit_$(hostname)_$(date +%Y%m%d).log
```

### Tip 2: Chercher juste les problèmes

```bash
sudo ./linux_audit.sh | grep -E "\[FAIL\]|\[WARN\]"
```

### Tip 3: Comparer avant/après

```bash
# Avant modifications
sudo ./linux_audit.sh > audit_before.log

# ... faire les modifications ...

# Après modifications
sudo ./linux_audit.sh > audit_after.log

# Comparer
diff audit_before.log audit_after.log
```

### Tip 4: Utiliser dans un script

```bash
#!/bin/bash

./linux_audit.sh > /tmp/audit.log

if grep -q "\[FAIL\]" /tmp/audit.log; then
    echo "Critical issues found!"
    exit 1
fi

echo "Audit passed!"
exit 0
```

---

## 🚀 Prochaines Actions

### Niveau Débutant
1. ✅ Lancez l'audit une fois
2. ✅ Lisez le rapport
3. ✅ Comparez avec [EXAMPLES.md](EXAMPLES.md)

### Niveau Intermédiaire
1. ✅ Automatisez avec cron
2. ✅ Gardez l'historique des audits
3. ✅ Mettez en place les améliorations suggérées

### Niveau Avancé
1. ✅ Intégrez dans votre CI/CD
2. ✅ Exportez en JSON/CSV
3. ✅ Contribuez des nouveaux checks

---

## 📞 Obtenir de l'Aide

- 📖 **Docs complètes**: [README.md](README.md)
- 🧪 **Tests**: [TESTING.md](TESTING.md)
- 📊 **Exemples**: [EXAMPLES.md](EXAMPLES.md)
- 🐛 **Issues**: Ouvrir une GitHub issue
- 💬 **Chat**: Discussions GitHub

---

## 🎓 Ressources d'Apprentissage

- 🔐 [Linux Security Hardening Guide](https://www.cisecurity.org/)
- 🛡️ [CIS Benchmarks](https://www.cisecurity.org/benchmark/)
- 🐧 [Linux Man Pages Online](https://man7.org/)
- 🔍 [OWASP Security Testing](https://owasp.org/)

---

## ✅ Checklist d'Installation

- [ ] Clonez ou téléchargez le script
- [ ] Rendez-le exécutable: `chmod +x linux_audit.sh`
- [ ] Testez la syntaxe: `bash -n linux_audit.sh`
- [ ] Lancez le script: `sudo ./linux_audit.sh`
- [ ] Lisez le rapport
- [ ] Comparez avec les exemples
- [ ] Planifiez les améliorations

---

## 🎉 Vous êtes Prêt !

Vous avez maintenant un audit de sécurité Linux complet et automatisé.

**Prochaine étape ?**

1. Lancez l'audit
2. Examinez les résultats
3. Implémentez les améliorations
4. Automatisez les audits récurrents

---

**Besoin d'aide ?** Consultez le [README.md](README.md) complet ou ouvrez une issue sur GitHub.

**Bon audit ! 🛡️**
