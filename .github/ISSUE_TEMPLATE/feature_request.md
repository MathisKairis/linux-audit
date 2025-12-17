name: Feature Request
description: Proposer une nouvelle fonctionnalité
title: "[FEATURE] "
labels: ["enhancement", "feature-request"]
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        # 💡 Demande de Fonctionnalité

        Nous apprécions vos suggestions pour améliorer le script d'audit Linux !

  - type: textarea
    id: description
    attributes:
      label: Description de la Fonctionnalité
      description: Décrivez la fonctionnalité que vous aimeriez voir
      placeholder: |
        Exemple: Ajouter une vérification pour les conteneurs Podman
    validations:
      required: true

  - type: textarea
    id: motivation
    attributes:
      label: Motivation
      description: Pourquoi cette fonctionnalité est-elle importante ?
      placeholder: |
        Exemple: Podman devient plus populaire et devrait être contrôlé comme Docker
    validations:
      required: true

  - type: textarea
    id: use-case
    attributes:
      label: Cas d'Utilisation
      description: Comment serait utilisée cette fonctionnalité ?
      placeholder: |
        Exemple: Les administrateurs utilisant Podman auraient un audit plus complet
    validations:
      required: true

  - type: textarea
    id: implementation
    attributes:
      label: Idée d'Implémentation (Optionnel)
      description: Avez-vous des idées sur comment l'implémenter ?
      placeholder: |
        Exemple: Créer une fonction check_podman() similaire à check_docker_security()
    validations:
      required: false

  - type: dropdown
    id: priority
    attributes:
      label: Priorité
      description: Quelle est l'importance de cette fonctionnalité ?
      options:
        - "Basse - Nice to have"
        - "Moyenne - Utile"
        - "Haute - Important"
        - "Critique - Essential"
    validations:
      required: true

  - type: checkboxes
    id: terms
    attributes:
      label: Avant de Soumettre
      options:
        - label: "J'ai vérifié qu'une demande similaire n'existe pas"
          required: true
        - label: "Cette fonctionnalité s'aligne avec le scope du projet"
          required: true
