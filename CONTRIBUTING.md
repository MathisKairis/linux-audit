# Contributing Guidelines

## Comment Contribuer

Merci de votre intérêt pour contribuer à ce projet ! Voici comment vous pouvez aider.

## Code de Conduite

Soyez respectueux, inclusif et constructif dans vos interactions.

## Rapporter des Bugs

1. Vérifiez que le bug n'a pas déjà été signalé
2. Fournissez :
   - Version du système d'exploitation
   - Version de Bash
   - Sortie complète du script
   - Étapes pour reproduire le problème

Exemple :
```
OS: Ubuntu 22.04 LTS
Bash: 5.1.16
Issue: SSH check fails when sshd_config is not readable
```

## Proposer des Améliorations

1. Décrivez clairement l'amélioration souhaitée
2. Expliquez pourquoi c'est utile
3. Listez les distributions affectées

## Pull Requests

1. Fork le dépôt
2. Créez une branche : `git checkout -b feature/nom-feature`
3. Commitez avec messages clairs : `git commit -m "Add: description"`
4. Poussez : `git push origin feature/nom-feature`
5. Ouvrez une PR avec description détaillée

### Conventions de Code

- Bash strict : `set -o pipefail`
- Indentation : 4 espaces
- Noms de fonction : `check_something`
- Variables globales MAJUSCULES : `SSH_CONFIG`
- Commentaires clairs : `# Description`

## Tests

Avant de soumettre une PR :

```bash
# Vérifier la syntaxe
bash -n linux_audit.sh

# Tester sur plusieurs distributions
docker run -it --rm -v $(pwd):/audit ubuntu:latest bash -c "apt-get update && chmod +x /audit/linux_audit.sh && sudo /audit/linux_audit.sh"
```

## Merci ! 🙏

Chaque contribution compte, qu'elle soit code, documentation, ou rapports de bugs.
