---
title: "Procédure de patching d'urgence"
constitutional_principle: "VII - Patch Management"
ssdlc_phase: "implementation"
difficulty: "intermediate"
estimated_time: "30 minutes"
estimated_time_execution: "4-24 hours"
tags: ["emergency", "incident-response", "critical-patch", "procedure"]
---

# Procédure de patching d'urgence

## Objectif

Définir la procédure à suivre pour appliquer rapidement un patch critique en réponse à une vulnérabilité activement exploitée.

**Principe** : En cas de vulnérabilité critique, chaque minute compte. Une procédure claire évite les erreurs sous pression.

---

## Déclenchement de la procédure

### Critères d'activation

La procédure d'urgence est activée si **AU MOINS 2** des critères suivants sont remplis :

- [ ] **CVSS ≥ 9.0** (Critical)
- [ ] **Exploit public disponible** (PoC fonctionnel publié)
- [ ] **Attaques actives observées** (CISA KEV, threat intel)
- [ ] **Asset exposé publiquement** (API, site web)
- [ ] **Données sensibles accessibles** (PII, paiements, secrets)
- [ ] **Recommandation vendor "patch immediately"**

**Exemples historiques** :

- Log4Shell (CVE-2021-44228) - CVSS 10.0, exploit public, attaques actives
- Heartbleed (CVE-2014-0160) - Impact massive, données sensibles
- Apache Struts RCE (CVE-2017-5638) - Exploit trivial, attaques immédiates

---

## Étape 1 : Alerte et mobilisation (15 minutes)

### 1.1 Notification d'urgence

**Responsable** : Security Champion ou premier détecteur

**Actions** :

```bash
# Envoyer alerte sur tous les canaux
- Slack: @channel dans #security-alerts
- Email: security@example.com + ciso@example.com
- SMS: Astreinte On-Call
- Téléphone: CISO si indisponible par autres canaux
```

**Template d'alerte** :

```
🚨 ALERTE SÉCURITÉ CRITIQUE 🚨

CVE: [EXAMPLE: CVE-2024-12345]
CVSS: 9.8 (Critical)
Composant affecté: [Nom + version]
Impact: [RCE / Data breach / DoS]
Exploit public: [Oui/Non + lien]
Attaques actives: [Oui/Non + source]

Action requise: Patch d'urgence
SLA: 24-48h
Procédure: https://wiki.example.com/emergency-patching

War room: https://meet.example.com/emergency-YYYYMMDD
```

---

### 1.2 Constituer l'équipe d'urgence

**War Room** (virtuel ou physique) :

- **Security Champion** (lead)
- **DevOps Lead** (déploiement)
- **Tech Lead** (tests techniques)
- **Product Manager** (décisions business)
- **SRE On-Call** (monitoring)
- **CISO** (escalade si nécessaire)

**Durée** : Jusqu'à résolution complète

---

## Étape 2 : Évaluation rapide (30 minutes)

### 2.1 Vérifier l'exposition

**Checklist** :

- [ ] **Identifier les assets affectés** : Vérifier les fichiers de dépendances, configurations, versions déployées
- [ ] **Vérifier les environnements** : Production, Staging, Development
- [ ] **Vérifier l'exposition réseau** : Services publics, internes, VPN uniquement
- [ ] **Consulter les logs d'accès** : Rechercher des tentatives d'exploitation

**Output attendu** :

```markdown
## Assets affectés
- [x] API Production - Version vulnérable
- [x] Backend Staging - Version vulnérable
- [ ] Frontend Production - Pas affecté
- [ ] Base de données - Pas affecté

## Exposition
- API Production : **Publique** (internet)
- Backend Staging : **Interne** (VPN only)

## Tentatives d'exploitation détectées
- **Non** (logs propres)
```

---

### 2.2 Identifier le patch ou mitigation

**Option A : Patch officiel disponible**

- Vérifier la disponibilité de la version patchée auprès du fournisseur
- Consulter les release notes et changelogs
- Identifier les changements breaking potentiels

**Option B : Pas de patch disponible → Mitigation temporaire**

Mitigations possibles :

- [ ] **Désactiver la feature vulnérable** (si non critique)
- [ ] **Règle WAF** (bloquer les patterns d'exploitation)
- [ ] **Restriction réseau** (firewall, IP whitelist)
- [ ] **Contournement applicatif** (feature flag)
- [ ] **Workaround code** (patch manuel temporaire)

---

## Étape 3 : Mitigation immédiate (1-2 heures)

### 3.1 Appliquer mitigation temporaire (si patch indisponible)

**Option 1 : Règle WAF**

- Configurer des règles pour bloquer les patterns d'exploitation connus
- Valider que les règles ne bloquent pas le trafic légitime
- Documenter les règles appliquées

**Option 2 : Restriction réseau**

- Limiter l'accès par IP whitelist si applicable
- Configurer le firewall pour bloquer l'accès non autorisé
- Vérifier l'impact sur les utilisateurs légitimes

**Option 3 : Désactivation de feature**

- Désactiver la fonctionnalité vulnérable via feature flag ou configuration
- Communiquer sur l'indisponibilité temporaire si nécessaire
- Documenter la procédure de réactivation

**Vérification de la mitigation** :

- [ ] Tester que l'exploit est effectivement bloqué
- [ ] Vérifier que les fonctionnalités critiques restent opérationnelles
- [ ] Documenter la mitigation appliquée
- [ ] Planifier le retrait de la mitigation après application du patch

---

## Étape 4 : Tests rapides (2-4 heures)

### 4.1 Appliquer le patch en environnement de test

**Actions** :

- [ ] Créer une branche hotfix dédiée
- [ ] Mettre à jour le composant vulnérable vers la version patchée
- [ ] Vérifier que la vulnérabilité est corrigée (scan de sécurité)
- [ ] Commiter et pousser les changements
- [ ] Déployer sur environnement de développement
- [ ] Déployer sur environnement de staging

---

### 4.2 Tests de non-régression accélérés

**Tests critiques uniquement** (pas de suite complète) :

**1. Tests de smoke**

- [ ] Vérifier que les endpoints principaux répondent
- [ ] Tester les fonctionnalités critiques de l'application

**2. Tests de sécurité**

- [ ] Scanner pour confirmer que la vulnérabilité est corrigée
- [ ] Vérifier qu'aucune nouvelle vulnérabilité n'a été introduite

**3. Tests de performance**

- [ ] Exécuter tests de charge sur endpoints critiques
- [ ] Comparer avec la baseline de performance

**Durée maximale** : 2 heures (tests critiques uniquement)

**Décision GO/NO-GO** :

- [ ] Endpoints critiques fonctionnent
- [ ] Vulnérabilité corrigée (scan confirmé)
- [ ] Pas de régression de performance > 20%
- [ ] Logs propres (pas d'erreurs)

**Si NO-GO** : Rollback + investiguer → Appliquer mitigation temporaire en production

---

## Étape 5 : Déploiement production (1-2 heures)

### 5.1 Préparation

**Actions préalables** :

- [ ] **Backup complet** : Configuration, base de données, état actuel
- [ ] **Préparer la procédure de rollback** : Documenter les étapes
- [ ] **Désactiver auto-scaling temporairement** (si applicable)
- [ ] **Annoncer la maintenance** (si downtime nécessaire) : Status page, communication

---

### 5.2 Déploiement graduel

**Option A : Blue/Green (recommandé pour urgence)**

- Déployer la nouvelle version en parallèle de l'ancienne
- Tester la nouvelle version
- Basculer le trafic instantanément
- Monitorer 15 minutes minimum
- Si problème : rollback immédiat vers l'ancienne version

**Option B : Canary (si plus de temps disponible)**

- Déployer la nouvelle version sur un sous-ensemble de serveurs
- Router 10% du trafic vers la nouvelle version
- Monitorer 30 minutes
- Si OK : augmenter progressivement (25%, 50%, 100%)
- Si problème : rollback immédiat

**Option C : Rolling update**

- Déployer progressivement sur chaque serveur
- Attendre validation avant de continuer
- En cas de problème : arrêter et rollback

---

### 5.3 Vérification post-déploiement (30 minutes)

**Checklist** :

- [ ] **Service opérationnel** : Tous les endpoints critiques répondent
- [ ] **Vulnérabilité corrigée** : Scanner DAST/SAST confirme la correction
- [ ] **Logs propres** : Pas d'erreurs critiques dans les logs applicatifs
- [ ] **Métriques normales** :
  - CPU < 80%
  - Mémoire < 80%
  - Taux d'erreur < 1%
  - Latence dans les limites acceptables
- [ ] **Monitoring renforcé** : Maintenir le War Room actif pendant 1 heure

---

## Étape 6 : Communication (30 minutes)

### 6.1 Communication interne

**Template d'email (toute l'entreprise)** :

```
Objet: [RÉSOLU] Patch de sécurité critique appliqué

Bonjour,

Une vulnérabilité critique ([EXAMPLE: CVE-2024-12345], CVSS 9.8) a été détectée dans [composant].

Actions prises :
✅ Patch appliqué en production à [HH:MM]
✅ Vulnérabilité corrigée et vérifiée
✅ Aucune exploitation détectée
✅ Aucun impact utilisateur

Temps de résolution : [X heures]
Downtime : [0 minute / X minutes]

Détails techniques : [lien wiki interne]

Merci à l'équipe pour la réactivité.

-- Security Team
```

---

### 6.2 Communication externe (si applicable)

**Si données clients potentiellement affectées** :

```
Objet: Notification de sécurité - Action préventive

Cher client,

Nous vous informons qu'une vulnérabilité de sécurité a été identifiée et corrigée sur notre plateforme le [DATE].

Aucune donnée client n'a été compromise. Cette action était préventive.

Si vous avez des questions : security@example.com

Cordialement,
[Company] Security Team
```

**Channels** :

- [ ] Email clients (si impact potentiel)
- [ ] Status page (<https://status.example.com>)
- [ ] Blog post (si haute visibilité)
- [ ] Réseaux sociaux (si demandes publiques)

---

## Étape 7 : Post-mortem (72 heures après)

### 7.1 Réunion de retour d'expérience

**Participants** : Toute l'équipe d'urgence

**Questions** :

1. Qu'est-ce qui a bien fonctionné ?
2. Qu'est-ce qui a mal fonctionné ?
3. Quelles améliorations apporter à la procédure ?
4. Des outils manquants ?
5. Formation nécessaire ?

---

### 7.2 Documentation

**Template de post-mortem** :

```markdown
# Post-Mortem: [EXAMPLE: CVE-2024-12345]

**Date incident** : AAAA-MM-JJ HH:MM
**Date résolution** : AAAA-MM-JJ HH:MM
**Durée** : X heures

## Chronologie
- T+0min : Vulnérabilité détectée
- T+15min : War room constitué
- T+1h : Mitigation temporaire appliquée
- T+4h : Patch testé en staging
- T+6h : Patch déployé en production
- T+6h30 : Vérification post-patch OK

## Impact
- Downtime : 0 minute
- Utilisateurs affectés : 0
- Données compromises : Aucune

## Actions bien exécutées
- ✅ Détection rapide (alertes Snyk)
- ✅ Mobilisation efficace
- ✅ Tests rapides mais suffisants

## Points d'amélioration
- ❌ Pas de backup automatisé (fait manuellement)
- ❌ Tests de régression trop longs (4h)
- ❌ Procédure de rollback pas testée

## Actions correctives
1. Automatiser backup pré-déploiement
2. Créer suite de tests de régression rapide (<1h)
3. Tester rollback trimestriellement

**Responsable suivi** : [Security Champion]
**Deadline** : AAAA-MM-JJ
```

---

## Checklist finale

- [ ] Vulnérabilité détectée et évaluée
- [ ] Équipe d'urgence mobilisée (War room)
- [ ] Assets affectés identifiés
- [ ] Mitigation temporaire appliquée (si patch indisponible)
- [ ] Patch testé en staging
- [ ] Backup pré-déploiement effectué
- [ ] Patch déployé en production
- [ ] Vérification post-patch OK
- [ ] Communication interne effectuée
- [ ] Communication externe (si nécessaire)
- [ ] Post-mortem planifié
- [ ] Documentation mise à jour

---

## Contacts d'urgence

| Rôle | Nom | Téléphone | Email |
|------|-----|-----------|-------|
| Security Champion | [Nom] | +33 X XX XX XX XX | <security@example.com> |
| DevOps Lead | [Nom] | +33 X XX XX XX XX | <devops@example.com> |
| CISO | [Nom] | +33 X XX XX XX XX | <ciso@example.com> |
| CTO | [Nom] | +33 X XX XX XX XX | <cto@example.com> |
| Astreinte On-Call | [Rotation] | +33 X XX XX XX XX | <oncall@example.com> |

---

**Prochaine étape** : Prioriser les vulnérabilités avec [vulnerability-prioritization-matrix.md](vulnerability-prioritization-matrix.md)
