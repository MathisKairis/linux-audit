name: Bug Report
description: Signaler un bug ou un problème
title: "[BUG] "
labels: ["bug", "needs-triage"]
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        Merci de signaler un bug ! Remplissez le formulaire ci-dessous pour nous aider à résoudre le problème.

  - type: textarea
    id: description
    attributes:
      label: Description du Bug
      description: Décrivez le problème que vous avez rencontré
      placeholder: |
        Exemple: Le script échoue lors de la vérification du firewall sur CentOS
    validations:
      required: true

  - type: textarea
    id: steps-to-reproduce
    attributes:
      label: Étapes pour Reproduire
      description: Comment reproduire le bug ?
      placeholder: |
        1. Lancez le script avec `sudo ./linux_audit.sh`
        2. Observez l'erreur...
        3. Le script se termine prématurément
    validations:
      required: true

  - type: textarea
    id: expected-behavior
    attributes:
      label: Comportement Attendu
      description: Que devrait-il se passer ?
      placeholder: |
        Le script devrait compléter toutes les vérifications sans erreur
    validations:
      required: true

  - type: textarea
    id: actual-behavior
    attributes:
      label: Comportement Réel
      description: Que se passe-t-il réellement ?
      placeholder: |
        Le script affiche une erreur et s'arrête
    validations:
      required: true

  - type: textarea
    id: error-output
    attributes:
      label: Sortie d'Erreur
      description: Copiez la sortie d'erreur complète
      render: bash
      placeholder: |
        [ERROR] Something went wrong
        command not found: ...
    validations:
      required: false

  - type: input
    id: os-version
    attributes:
      label: Système d'Exploitation
      description: Quelle distro Linux utilisez-vous ?
      placeholder: "Exemple: Ubuntu 22.04 LTS, CentOS 8.5"
    validations:
      required: true

  - type: input
    id: bash-version
    attributes:
      label: Version de Bash
      description: "Résultat de: bash --version"
      placeholder: "GNU bash, version 5.1.16"
    validations:
      required: true

  - type: input
    id: kernel-version
    attributes:
      label: Version du Kernel
      description: "Résultat de: uname -r"
      placeholder: "5.15.0-56-generic"
    validations:
      required: false

  - type: dropdown
    id: reproducibility
    attributes:
      label: Reproductibilité
      description: Pouvez-vous reproduire le bug ?
      options:
        - "Oui, systématiquement"
        - "Oui, mais intermittent"
        - "Non, je l'ai vu une fois"
        - "Non testé"
    validations:
      required: true

  - type: textarea
    id: additional-context
    attributes:
      label: Contexte Supplémentaire
      description: Toute autre information qui pourrait être utile
      placeholder: |
        - Est-ce un serveur de production ?
        - Avez-vous des configurations spéciales ?
        - Comment avez-vous installé le script ?
    validations:
      required: false

  - type: checkboxes
    id: terms
    attributes:
      label: Avant de Soumettre
      options:
        - label: "J'ai lu le [README.md](../README.md)"
          required: true
        - label: "J'ai vérifié qu'un bug similaire n'existe pas"
          required: true
        - label: "J'ai fourni des informations complètes pour aider au diagnostic"
          required: true
