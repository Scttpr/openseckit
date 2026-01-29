---
title: "Modèle de registre de risques - Toutes phases"
constitutional_principle: "II - Risk Analysis"
ssdlc_phase: "all"
last_updated: "2025-11-29"
reviewers:
  - security-champion-team
  - risk-management-team
description: "Artefact de reporting pour suivre les risques identifiés. Sert de 'snapshot' (photo à un instant T) pour les audits et la direction."
tags:
  - risk-register
  - reporting
  - governance
  - snapshot
difficulty: "débutant"
estimated_time: "Génération automatique ou 15 min de mise à jour"
prerequisites:
  - "Modélisation des menaces et notation des risques complétées"
related_templates:
  - "risk-scoring-template-planning.md"
  - "../01-threat-modeling/stride-threat-model-template-planning.md"
---

# Modèle de registre de risques

> **💡 Conseil opérationnel : Gestion "Live" vs "Snapshot"**
>
> Ce document est un **artefact de reporting** (une "photo" à un instant T), conçu pour l'archivage, les audits et la communication formelle.
>
> **Au quotidien**, ne maintenez pas ce tableau manuellement. Gérez les risques là où vous travaillez (Jira, GitHub Issues, GitLab) :
> * Utilisez un label `Type: Risque`.
> * Utilisez des labels de score : `Risque:P0-Critique`, `Risque:P1-Élevé`.
> * Liez les tickets d'atténuation aux tickets de risques.
>
> **Utilisation de ce modèle** : Remplissez ce fichier uniquement lors des jalons clés (fin de release, audit trimestriel) en exportant l'état de vos tickets.

---

## 1. Vue d'ensemble (snapshot)

### Posture de risque actuelle

**Date du snapshot** : `YYYY-MM-DD`

| Priorité | Nombre | Résumé statut |
|----------|--------|---------------|
| **P0 - Critique** (80-125) | 0 | ✅ Aucun en suspens |
| **P1 - Élevé** (49-79) | 0 | ⚠️ [X] en atténuation |
| **P2 - Moyen** (25-48) | 0 | 🔄 [X] dans backlog |
| **P3 - Faible** (11-24) | 0 | 📋 Suivis, non bloquants |
| **P4 - Minimal** (1-10) | 0 | 👁️ Surveillance |
| **Total risques actifs** | **0** | |

### Tendance des risques (trimestriel)

```
Mois        Critique  Élevé  Moyen   Faible  Minimal
----------- --------- ------ ------- ------- -------
2024-12     1         5      7       6       10
2025-01     0         2      5       8       12
Tendance    ✅ -1     ✅ -3  ✅ -2   ⚠️ +2   ⚠️ +2
```

**Interprétation** : Risque global en baisse. Risques P0-P2 réduits par atténuation. Augmentation P3-P4 due à modélisation menaces nouvelles fonctionnalités (attendue).

---

## 2. Risques actifs majeurs

*Listez ici uniquement les risques P0 et P1 qui nécessitent l'attention de la direction.*

### Risques P0 - critiques (score 80-125)
*Doit être vide pour une mise en production.*

| ID | Titre du risque | Score | Propriétaire | Date cible | Statut approbation |
|----|-----------------|-------|--------------|------------|--------------------|
| [Vide] | | | | | |

### Risques P1 - élevés (score 49-79)

#### Risque R-[Année]-[NNN] : [Titre du risque]

| Champ | Valeur |
|-------|--------|
| **ID risque** | [Lien vers ticket Jira/GitHub] |
| **Score actuel** | **[Score]** (C:[ ] × P:[ ] × E:[ ]) |
| **Source** | [Ex: Modèle menaces STRIDE - T01] |
| **Description** | [Description courte de la vulnérabilité et de l'impact] |
| **Plan d'atténuation** | 1. [Action immédiate]<br>2. [Action long terme] |
| **Statut** | 🔄 En cours / ⏸️ Bloqué |
| **Propriétaire** | [Nom/Équipe] |
| **Risque résiduel visé** | [Score visé] (P3 - Faible) |
| **Approbation** | [Nom du validateur] (requis pour P1) |

---

## 3. Risques moyens et faibles (synthèse)

*Export simplifié des risques P2/P3.*

| ID | Priorité | Titre | Propriétaire | Statut | Date cible |
|----|----------|-------|--------------|--------|------------|
| R-003 | P2 | Logs audit manquants | Sécurité | 🔄 En cours | YYYY-MM-DD |
| R-004 | P2 | Politique mdp faible | Produit | 📋 Backlog | YYYY-MM-DD |
| R-005 | P3 | Timeout session long | Produit | 📋 Planifié | YYYY-MM-DD |

---

## 4. Risques acceptés (exceptions)

*Risques que la direction a accepté de ne PAS corriger pour l'instant.*

| ID | Titre | Score | Validé par | Justification métier | Re-revue |
|----|-------|-------|------------|----------------------|----------|
| R-012 | Admin sans MFA (VPN) | 36 | CTO | Coût implémentation trop élevé pour MVP. VPN suffit. | T3 2025 |

---

## 5. Décisions et signatures

**Pour ce snapshot :**

- [ ] Tous les risques P0 sont clos.
- [ ] Tous les risques P1 ont un plan d'action validé.
- [ ] La direction est informée des risques acceptés.

**Signatures du snapshot :**

| Rôle | Nom | Date |
| :--- | :--- | :--- |
| **Security champion** | `[Nom]` | `[Date]` |
| **Engineering lead** | `[Nom]` | `[Date]` |
| **Product owner** | `[Nom]` | `[Date]` |