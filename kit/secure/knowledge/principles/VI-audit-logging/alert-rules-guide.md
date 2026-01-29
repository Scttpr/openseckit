---
title: "Template de règles d'alerte sécurité"
constitutional_principle: "VI - Audit Logging"
ssdlc_phase: "design"
difficulty: "intermediate"
estimated_time: "2-3 hours"
tags: ["alerting", "detection", "siem", "security-monitoring", "incident-response"]
---

# Template de règles d'alerte sécurité

## Métadonnées du projet

**Projet** : [Nom du projet]
**Date de création** : [AAAA-MM-JJ]
**Responsable** : [Nom du security champion]
**Dernière révision** : [AAAA-MM-JJ]
**Version** : 1.0.0

---

## Objectif

Définir les règles d'alerte de sécurité pour détecter automatiquement les activités suspectes et déclencher une réponse appropriée.

**Principe** : Détecter tôt pour réagir vite. Chaque minute compte lors d'une compromission.

---

## 1. Règles d'authentification

### RULE-AUTH-001 : Brute Force Login

**Description** : Détecte les tentatives de connexion par force brute

**Indicateurs** :

- ≥ 5 tentatives de connexion échouées en 5 minutes
- Même utilisateur ou même IP source

**Requête (SIEM-agnostic)** :

```
event_type = "authentication_failed"
GROUP BY user, source_ip
TIMEFRAME 5 minutes
THRESHOLD count >= 5
```

**Implémentation Elasticsearch** :

```json
{
  "rule_type": "threshold",
  "threshold": {
    "field": "user.keyword",
    "value": 5,
    "cardinality": {
      "field": "source_ip",
      "value": 1
    }
  },
  "query": "event_type:authentication_failed",
  "timeframe": "5m"
}
```

**Implémentation Splunk** :

```spl
index=security event_type="authentication_failed"
| bucket _time span=5m
| stats count by user, source_ip, _time
| where count >= 5
```

**Sévérité** : MEDIUM
**Action** :

- [ ] Notification Slack/Teams
- [ ] Email security team
- [ ] Bloquer l'IP temporairement (30 min)
- [ ] Créer ticket incident si > 10 tentatives

**Faux positifs** :

- Utilisateurs oubliant leur mot de passe
- Scripts de tests automatisés

**Mitigation faux positifs** :

- Whitelist : IPs internes, environnements de test
- Augmenter le seuil à 10 pour utilisateurs connus

---

### RULE-AUTH-002 : Connexion depuis pays inhabituel

**Description** : Détecte une connexion réussie depuis un pays jamais utilisé par l'utilisateur

**Indicateurs** :

- Connexion réussie
- Pays source différent de l'historique des 90 derniers jours

**Requête** :

```
event_type = "authentication_success"
WHERE geoip.country NOT IN (historical_countries_last_90d)
```

**Implémentation Elasticsearch** :

```json
{
  "rule_type": "new_terms",
  "new_terms": {
    "field": "geoip.country_name",
    "history_window_start": "now-90d"
  },
  "query": "event_type:authentication_success",
  "timeframe": "5m"
}
```

**Sévérité** : HIGH
**Action** :

- [ ] Notification immédiate (SMS + Email)
- [ ] Déclencher MFA challenge additionnel
- [ ] Loguer l'événement pour investigation
- [ ] Si pays blacklisté (Corée du Nord, etc.) : bloquer immédiatement

---

### RULE-AUTH-003 : Credential Stuffing

**Description** : Détecte des tentatives de credential stuffing (nombreux utilisateurs ciblés, même IP)

**Indicateurs** :

- ≥ 20 tentatives de connexion échouées en 10 minutes
- Utilisateurs différents
- Même IP source

**Requête** :

```
event_type = "authentication_failed"
GROUP BY source_ip
HAVING unique_count(user) >= 20
TIMEFRAME 10 minutes
```

**Implémentation Splunk** :

```spl
index=security event_type="authentication_failed"
| bucket _time span=10m
| stats dc(user) as unique_users by source_ip, _time
| where unique_users >= 20
```

**Sévérité** : HIGH
**Action** :

- [ ] Bloquer l'IP immédiatement
- [ ] Alerter SOC/SecOps
- [ ] Vérifier si comptes compromis
- [ ] Forcer rotation MDP si connexions réussies

---

## 2. Règles d'autorisation

### RULE-AUTHZ-001 : Escalade de privilèges

**Description** : Détecte une tentative d'accès à une ressource admin par un utilisateur non-admin

**Indicateurs** :

- `event_type = "authorization_denied"`
- `user.role != "admin"`
- `resource` contient "admin" ou "privileged"

**Requête** :

```
event_type = "authorization_denied"
WHERE user.role != "admin"
AND (resource LIKE "%admin%" OR resource LIKE "%privileged%")
```

**Implémentation Elasticsearch** :

```json
{
  "rule_type": "query",
  "query": "event_type:authorization_denied AND NOT user.role:admin AND (resource:*admin* OR resource:*privileged*)",
  "timeframe": "5m"
}
```

**Sévérité** : HIGH
**Action** :

- [ ] Notification immédiate security team
- [ ] Créer ticket incident
- [ ] Logger user, IP, ressource tentée
- [ ] Si ≥ 3 tentatives : suspendre compte temporairement

---

### RULE-AUTHZ-002 : IDOR (Insecure Direct Object Reference)

**Description** : Détecte un utilisateur tentant d'accéder aux données d'un autre utilisateur

**Indicateurs** :

- `event_type = "authorization_denied"`
- `reason` contient "IDOR" ou "forbidden_resource"
- Même utilisateur tente plusieurs IDs différents

**Requête** :

```
event_type = "authorization_denied"
WHERE reason LIKE "%IDOR%"
GROUP BY user
HAVING count(DISTINCT resource_id) >= 5
TIMEFRAME 10 minutes
```

**Sévérité** : MEDIUM
**Action** :

- [ ] Notification security champion
- [ ] Logger détails pour investigation
- [ ] Vérifier si vulnérabilité applicative (code review)

---

## 3. Règles de détection d'intrusion

### RULE-IDS-001 : SQL Injection détectée

**Description** : Détecte des tentatives d'injection SQL dans les paramètres de requêtes

**Indicateurs** :

- Logs WAF ou application
- Payload contient : `' OR`, `UNION SELECT`, `DROP TABLE`, `--`, etc.

**Requête** :

```
event_type = "waf_blocked" OR event_type = "sql_injection_attempt"
WHERE payload MATCHES_REGEX /'|--|UNION|SELECT.*FROM|DROP\s+TABLE/i
```

**Implémentation Splunk** :

```spl
index=security (event_type="waf_blocked" OR event_type="sql_injection_attempt")
| regex payload="(?i)('|--|UNION|SELECT.*FROM|DROP\s+TABLE)"
| stats count by user, source_ip, endpoint
```

**Sévérité** : CRITICAL
**Action** :

- [ ] Bloquer l'IP immédiatement
- [ ] Alerter développeurs (potentielle vulnérabilité)
- [ ] Code review de l'endpoint ciblé
- [ ] Escalader au SOC si attaque sophistiquée

---

### RULE-IDS-002 : XSS (Cross-Site Scripting) détecté

**Description** : Détecte des tentatives d'injection XSS

**Indicateurs** :

- Payload contient : `<script>`, `onerror=`, `javascript:`, etc.

**Requête** :

```
event_type = "xss_attempt" OR event_type = "waf_blocked"
WHERE payload MATCHES_REGEX /<script|onerror=|javascript:|<img.*onerror/i
```

**Sévérité** : HIGH
**Action** :

- [ ] Bloquer l'IP temporairement
- [ ] Vérifier l'input validation de l'endpoint
- [ ] Logger pour investigation

---

### RULE-IDS-003 : Path Traversal détecté

**Description** : Détecte des tentatives de path traversal

**Indicateurs** :

- URL contient : `../`, `..\\`, `/etc/passwd`, etc.

**Requête** :

```
event_type = "path_traversal_attempt" OR http.status = 400
WHERE url MATCHES_REGEX /\.\.[\/\\]|\/etc\/passwd|\/windows\/system32/i
```

**Sévérité** : HIGH
**Action** :

- [ ] Bloquer l'IP
- [ ] Vérifier que l'endpoint n'est pas vulnérable
- [ ] Alerter équipe dev

---

## 4. Règles de détection de données

### RULE-DATA-001 : Exfiltration de données

**Description** : Détecte un volume de téléchargement anormalement élevé

**Indicateurs** :

- `event_type = "data_export"` ou `api_call = "download"`
- Volume > 100 MB en 1 heure
- Ou nombre de téléchargements > 1000 en 1 heure

**Requête** :

```
event_type = "data_export"
GROUP BY user
HAVING sum(bytes_exported) > 100000000 OR count(*) > 1000
TIMEFRAME 1 hour
```

**Implémentation Elasticsearch** :

```json
{
  "rule_type": "threshold",
  "threshold": {
    "field": "user.keyword",
    "value": 1
  },
  "query": "event_type:data_export",
  "aggregations": {
    "total_bytes": {
      "sum": {
        "field": "bytes_exported"
      }
    }
  },
  "conditions": {
    "total_bytes": {
      "gte": 100000000
    }
  },
  "timeframe": "1h"
}
```

**Sévérité** : CRITICAL
**Action** :

- [ ] Suspendre compte immédiatement
- [ ] Notifier CISO/DPO
- [ ] Investigation forensique
- [ ] Vérifier si données sensibles (PII, secrets)

---

### RULE-DATA-002 : Accès à données sensibles hors heures

**Description** : Détecte un accès à des données sensibles en dehors des heures de travail

**Indicateurs** :

- `event_type = "sensitive_data_access"`
- Timestamp hors heures (20h-8h, weekends)

**Requête** :

```
event_type = "sensitive_data_access"
WHERE hour(timestamp) NOT BETWEEN 8 AND 20
OR day_of_week(timestamp) IN (0, 6)  # Dimanche, Samedi
```

**Implémentation Splunk** :

```spl
index=security event_type="sensitive_data_access"
| eval hour=tonumber(strftime(_time, "%H"))
| eval day=tonumber(strftime(_time, "%w"))
| where (hour < 8 OR hour > 20) OR (day=0 OR day=6)
```

**Sévérité** : MEDIUM
**Action** :

- [ ] Notification security team
- [ ] Logger pour investigation
- [ ] Demander justification à l'utilisateur

---

## 5. Règles d'activité suspecte

### RULE-SUSP-001 : Mouvement latéral

**Description** : Détecte un utilisateur se connectant à de multiples systèmes en peu de temps

**Indicateurs** :

- ≥ 5 connexions réussies à des hosts différents
- En moins de 10 minutes

**Requête** :

```
event_type = "authentication_success"
GROUP BY user
HAVING count(DISTINCT host) >= 5
TIMEFRAME 10 minutes
```

**Sévérité** : HIGH
**Action** :

- [ ] Alerter SOC immédiatement
- [ ] Investigation : compte compromis ?
- [ ] Vérifier les commandes exécutées sur chaque host
- [ ] Isoler les hosts si compromission confirmée

---

### RULE-SUSP-002 : Exécution de commandes privilégiées

**Description** : Détecte l'exécution de commandes dangereuses

**Indicateurs** :

- Commandes : `rm -rf`, `dd if=`, `curl | bash`, `chmod 777`, etc.
- Par utilisateur non-admin

**Requête** :

```
event_type = "command_executed"
WHERE command MATCHES_REGEX /rm\s+-rf|dd\s+if=|curl.*\|.*bash|chmod\s+777/
AND user.role != "admin"
```

**Sévérité** : CRITICAL
**Action** :

- [ ] Bloquer utilisateur immédiatement
- [ ] Investigation forensique
- [ ] Vérifier intégrité système

---

### RULE-SUSP-003 : Création de compte admin

**Description** : Détecte la création d'un nouveau compte avec privilèges admin

**Indicateurs** :

- `event_type = "user_created"`
- `role = "admin"` ou `privileges` contient "admin"

**Requête** :

```
event_type = "user_created"
WHERE role = "admin" OR privileges LIKE "%admin%"
```

**Sévérité** : HIGH
**Action** :

- [ ] Notification CISO/Security team
- [ ] Vérifier légitimité de la création
- [ ] Demander validation à 2 personnes (dual control)
- [ ] Logger qui a créé le compte

---

## 6. Règles de conformité

### RULE-COMP-001 : Accès non loggé

**Description** : Détecte un endpoint sensible qui ne génère pas de logs d'audit

**Indicateurs** :

- Endpoint sensible (ex: `/api/users`, `/admin/settings`)
- Pas d'événement `audit_log` correspondant

**Requête** :

```
# Rechercher les endpoints avec trafic mais sans logs
index=access_logs
NOT [search index=security event_type="audit_log"]
| regex path="^/(api/users|admin)"
```

**Sévérité** : MEDIUM
**Action** :

- [ ] Notifier équipe dev
- [ ] Implémenter logging manquant
- [ ] Ticket de conformité

---

### RULE-COMP-002 : Logs non chiffrés transmis

**Description** : Détecte des logs envoyés en clair (non TLS)

**Indicateurs** :

- Logs envoyés via HTTP (non HTTPS)
- Syslog non chiffré

**Requête** :

```
# Vérifier les connexions sortantes du log shipper
source=firewall dest_port=514 OR dest_port=80
WHERE src IN (list_of_log_servers)
```

**Sévérité** : MEDIUM
**Action** :

- [ ] Migrer vers TLS immédiatement
- [ ] Bloquer le trafic non chiffré

---

## 7. Configuration des actions

### Action 1 : Notification Slack

```json
{
  "action_type": "webhook",
  "webhook_url": "[EXAMPLE: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX]",
  "message": {
    "text": "🚨 Security Alert: {{rule_name}}",
    "attachments": [
      {
        "color": "danger",
        "fields": [
          {"title": "User", "value": "{{user}}", "short": true},
          {"title": "IP", "value": "{{source_ip}}", "short": true},
          {"title": "Severity", "value": "{{severity}}", "short": true},
          {"title": "Time", "value": "{{@timestamp}}", "short": true}
        ]
      }
    ]
  }
}
```

---

### Action 2 : Email

```yaml
action_type: email
to:
  - security@example.com
  - soc@example.com
subject: "[{{severity}}] Security Alert: {{rule_name}}"
body: |
  A security event has been detected:

  Rule: {{rule_name}}
  Severity: {{severity}}
  User: {{user}}
  Source IP: {{source_ip}}
  Timestamp: {{@timestamp}}

  Details: {{event_details}}

  Action required: {{recommended_action}}
```

---

### Action 3 : Bloquer IP (via API firewall)

```bash
#!/bin/bash
# block_ip.sh

IP=$1
DURATION=1800  # 30 minutes

# Appeler l'API du firewall
curl -X POST https://firewall.example.com/api/block \
  -H "Authorization: Bearer $FIREWALL_TOKEN" \
  -d "{\"ip\": \"$IP\", \"duration\": $DURATION, \"reason\": \"Security alert\"}"

# Logger l'action
logger "Blocked IP $IP for $DURATION seconds due to security alert"
```

---

### Action 4 : Créer ticket incident (Jira/ServiceNow)

```python
# create_incident.py
import requests

def create_incident(rule_name, severity, details):
    jira_url = "https://jira.example.com/rest/api/2/issue"

    payload = {
        "fields": {
            "project": {"key": "SEC"},
            "summary": f"[{severity}] {rule_name}",
            "description": details,
            "issuetype": {"name": "Security Incident"},
            "priority": {"name": severity}
        }
    }

    response = requests.post(
        jira_url,
        json=payload,
        auth=("security-bot", "token")
    )

    return response.json()
```

---

## 8. Tuning et maintenance

### Revue mensuelle des règles

- [ ] Analyser le taux de faux positifs par règle
- [ ] Ajuster les seuils si nécessaire
- [ ] Désactiver les règles non pertinentes
- [ ] Ajouter de nouvelles règles basées sur les incidents récents

### Métriques à suivre

| Métrique | Cible |
|----------|-------|
| Taux de faux positifs | < 10% |
| Temps de réponse moyen | < 30 minutes |
| Couverture MITRE ATT&CK | > 80% des techniques |
| Règles actives | Au moins 1 par catégorie |

---

## 9. Checklist de validation

- [ ] Au moins 3 règles d'authentification actives
- [ ] Au moins 2 règles d'autorisation actives
- [ ] Au moins 3 règles de détection d'intrusion actives
- [ ] Au moins 1 règle de détection de données actives
- [ ] Actions configurées (Slack, Email, Bloquer IP)
- [ ] Playbooks de réponse documentés
- [ ] Équipe SOC/SecOps formée aux alertes
- [ ] Tuning initial effectué (2 semaines de test)

---

## Ressources

- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [Sigma Rules Repository](https://github.com/SigmaHQ/sigma)
- [Elastic Detection Rules](https://github.com/elastic/detection-rules)
- [Splunk Security Content](https://github.com/splunk/security_content)

---

**Prochaine étape** : Intégrer un SIEM avec [siem-selection-guide.md](siem-selection-guide.md)
