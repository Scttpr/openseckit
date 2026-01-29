---
title: "Guide de scan de dépendances (SCA - Software Composition Analysis)"
constitutional_principle: "IV - Security Testing"
ssdlc_phase: "implementation"
difficulty: "beginner"
estimated_time: "1-2 hours"
tags: ["sca", "dependencies", "npm-audit", "snyk", "dependabot", "supply-chain"]
---

# Guide de scan de dépendances (SCA - Software Composition Analysis)

## Objectif

Détecter et corriger les vulnérabilités dans les dépendances tierces (libraries, frameworks, packages) utilisées par votre projet.

**Principe** : La plupart du code moderne provient de dépendances tierces. Une seule vulnérabilité critique dans une dépendance peut compromettre toute l'application.

---

## Contexte

**Problème** : Log4Shell (CVE-2021-44228), 10/10 CVSS, a affecté des millions d'applications utilisant la bibliothèque Log4j.

**Solution** : Scanner automatiquement les dépendances, recevoir des alertes, et patcher rapidement.

---

## Prérequis

- [ ] Fichier de dépendances présent (`package.json`, `requirements.txt`, `pom.xml`, `go.mod`, etc.)
- [ ] Accès au gestionnaire de packages (npm, pip, maven, go)
- [ ] Pipeline CI/CD configuré
- [ ] (Optionnel) Compte GitHub/GitLab pour Dependabot/Dependency Scanning

---

## Étape 1 : Choisir l'outil SCA

### Option A : Outils natifs (gratuits)

| Langage | Outil natif | Commande |
|---------|-------------|----------|
| Node.js | npm audit | `npm audit` |
| Python | pip-audit | `pip-audit` |
| Java | OWASP Dependency-Check | `dependency-check.sh` |
| Go | govulncheck | `govulncheck ./...` |
| Ruby | bundler-audit | `bundle audit` |
| PHP | composer audit | `composer audit` |
| .NET | dotnet list package | `dotnet list package --vulnerable` |

**Avantages** : Gratuit, intégré, pas de compte externe
**Inconvénients** : Limité à un langage, pas de fix automatique

---

### Option B : Dependabot (GitHub - gratuit)

**Avantages** :

- Gratuit pour tous les repos GitHub
- Pull requests automatiques de mise à jour
- Détection continue
- Multi-langage

**Inconvénients** :

- GitHub uniquement
- Pas de prioritisation avancée

**Quand choisir** : Projets hébergés sur GitHub

---

### Option C : Snyk (freemium)

**Avantages** :

- Gratuit pour projets open source
- Multi-plateforme (GitHub, GitLab, Bitbucket)
- Priorisation intelligente (reachability analysis)
- Fix automatiques
- Base de données exhaustive

**Inconvénients** :

- Payant au-delà de 200 tests/mois pour projets privés
- Nécessite un compte

**Quand choisir** : Projets privés avec budget, besoin de priorisation avancée

---

### Option D : OWASP Dependency-Check (gratuit, multi-langage)

**Avantages** :

- Gratuit et open source
- Multi-langage (Java, .NET, Node, Python, Ruby)
- Intégration CI/CD facile
- Base CVE/NVD complète

**Inconvénients** :

- Plus lent que les alternatives SaaS
- Pas de fix automatique

**Quand choisir** : Multi-langage, on-premise, pas de SaaS

---

## Étape 2 : Scanner avec les outils natifs

### Node.js - npm audit

```bash
# Scanner les vulnérabilités
npm audit

# Output JSON pour parsing
npm audit --json > audit-report.json

# Corriger automatiquement (non-breaking changes)
npm audit fix

# Corriger avec breaking changes (attention !)
npm audit fix --force

# Voir les détails d'une vulnérabilité
npm audit --verbose
```

**Interpréter les résultats** :

```
┌───────────────┬──────────────────────────────────────────────────────────────┐
│ high          │ Prototype Pollution in lodash                                │
├───────────────┼──────────────────────────────────────────────────────────────┤
│ Package       │ lodash                                                       │
├───────────────┼──────────────────────────────────────────────────────────────┤
│ Patched in    │ >=4.17.21                                                    │
├───────────────┼──────────────────────────────────────────────────────────────┤
│ Dependency of │ express                                                      │
├───────────────┼──────────────────────────────────────────────────────────────┤
│ Path          │ express > body-parser > lodash                               │
├───────────────┼──────────────────────────────────────────────────────────────┤
│ More info     │ https://npmjs.com/advisories/1673                            │
└───────────────┴──────────────────────────────────────────────────────────────┘
```

**Actions** :

1. Vérifier si la vulnérabilité est exploitable dans votre contexte
2. Mettre à jour la dépendance directe (`npm update express`)
3. Si dépendance transitive non patchable : ajouter un override dans `package.json`

```json
{
  "overrides": {
    "lodash": "^4.17.21"
  }
}
```

---

### Python - pip-audit

```bash
# Installer pip-audit
pip install pip-audit

# Scanner
pip-audit

# Output JSON
pip-audit --format json > audit-report.json

# Scanner un requirements.txt spécifique
pip-audit -r requirements.txt

# Fixer automatiquement (génère requirements.txt mis à jour)
pip-audit --fix
```

**Exemple de sortie** :

```
Found 2 known vulnerabilities in 1 package
Name    Version ID             Fix Versions
------- ------- -------------- ------------
Django  2.2.0   PYSEC-2021-439 3.2.13,3.1.14,2.2.28
Django  2.2.0   CVE-2022-28346 3.2.13,3.1.14,2.2.28
```

**Action** :

```bash
pip install --upgrade Django==2.2.28
pip freeze > requirements.txt
```

---

### Java - OWASP Dependency-Check

```bash
# Télécharger
wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip
unzip dependency-check-8.4.0-release.zip

# Scanner un projet Maven
./dependency-check/bin/dependency-check.sh \
  --project "Mon Projet" \
  --scan ./target \
  --format ALL \
  --out ./reports

# Voir le rapport HTML
open reports/dependency-check-report.html
```

**Intégration Maven** :

```xml
<plugin>
  <groupId>org.owasp</groupId>
  <artifactId>dependency-check-maven</artifactId>
  <version>8.4.0</version>
  <executions>
    <execution>
      <goals>
        <goal>check</goal>
      </goals>
    </execution>
  </executions>
  <configuration>
    <failBuildOnCVSS>7</failBuildOnCVSS>
  </configuration>
</plugin>
```

---

### Go - govulncheck

```bash
# Installer
go install golang.org/x/vuln/cmd/govulncheck@latest

# Scanner
govulncheck ./...

# Output JSON
govulncheck -json ./... > vulns.json
```

**Exemple de sortie** :

```
Vulnerability #1: GO-2023-1234
  Denial of Service in net/http
  More info: https://pkg.go.dev/vuln/GO-2023-1234
  Module: stdlib
  Found in: go@1.19.0
  Fixed in: go@1.19.5
  Call stacks in your code:
    main.go:42:15: main.handleRequest calls http.ListenAndServe
```

**Action** :

```bash
go get -u golang.org/x/net
go mod tidy
```

---

## Étape 3 : Configurer Dependabot (GitHub)

### Créer `.github/dependabot.yml`

```yaml
version: 2
updates:
  # Node.js dependencies
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
      time: "03:00"
    open-pull-requests-limit: 5
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
      - "security"
    # Grouper les mises à jour mineures
    groups:
      minor-updates:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"

  # Python dependencies
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 3

  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"

  # Docker
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
```

**Configuration avancée** :

```yaml
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    # Ignorer certaines dépendances
    ignore:
      - dependency-name: "aws-sdk"
        update-types: ["version-update:semver-major"]
    # Préfixe de branche
    target-branch: "develop"
    # Commit message prefix
    commit-message:
      prefix: "chore(deps)"
      include: "scope"
```

---

## Étape 4 : Configurer Snyk

### Installation locale

```bash
# Installer Snyk CLI
npm install -g snyk

# Authentifier
snyk auth

# Scanner
snyk test

# Monitorer le projet (envoie les résultats au dashboard Snyk)
snyk monitor
```

### Intégration GitHub

1. **Installer Snyk GitHub App** : <https://github.com/apps/snyk-io>
2. **Sélectionner les repos** à monitorer
3. **Configurer les alertes** dans Snyk dashboard

### Intégration CI/CD

**GitHub Actions** :

```yaml
name: Snyk Security Scan

on:
  pull_request:
  push:
    branches: [main, develop]

jobs:
  snyk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Snyk to check for vulnerabilities
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

      - name: Upload Snyk report
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: snyk.sarif
```

**GitLab CI** :

```yaml
snyk-scan:
  stage: security
  image: snyk/snyk:node
  script:
    - snyk test --severity-threshold=high --json > snyk-report.json
  artifacts:
    reports:
      dependency_scanning: snyk-report.json
  allow_failure: false
```

---

## Étape 5 : Intégration en CI/CD

### GitHub Actions - Multi-langage

```yaml
name: Dependency Security Scan

on:
  pull_request:
  push:
    branches: [main]
  schedule:
    - cron: '0 3 * * *'  # Tous les jours à 3h

jobs:
  npm-audit:
    runs-on: ubuntu-latest
    if: hashFiles('package-lock.json') != ''
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install dependencies
        run: npm ci

      - name: Run npm audit
        run: |
          npm audit --audit-level=moderate --json > npm-audit.json
          cat npm-audit.json
        continue-on-error: true

      - name: Check for HIGH vulnerabilities
        run: |
          HIGH=$(jq '.metadata.vulnerabilities.high' npm-audit.json)
          CRITICAL=$(jq '.metadata.vulnerabilities.critical' npm-audit.json)
          if [ "$HIGH" -gt 0 ] || [ "$CRITICAL" -gt 0 ]; then
            echo "❌ $CRITICAL critical, $HIGH high vulnerabilities found"
            exit 1
          fi

  pip-audit:
    runs-on: ubuntu-latest
    if: hashFiles('requirements.txt') != ''
    steps:
      - uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install pip-audit
        run: pip install pip-audit

      - name: Run pip-audit
        run: pip-audit -r requirements.txt --format json > pip-audit.json

      - name: Check for vulnerabilities
        run: |
          VULNS=$(jq '.dependencies | length' pip-audit.json)
          if [ "$VULNS" -gt 0 ]; then
            echo "❌ $VULNS vulnerabilities found"
            cat pip-audit.json
            exit 1
          fi

  dependency-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run OWASP Dependency-Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'mon-projet'
          path: '.'
          format: 'ALL'
          args: >
            --enableRetired
            --failOnCVSS 7

      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: dependency-check-report
          path: reports/
```

---

### GitLab CI - Dependency Scanning (natif)

```yaml
include:
  - template: Security/Dependency-Scanning.gitlab-ci.yml

dependency_scanning:
  stage: security
  variables:
    DS_EXCLUDED_PATHS: "spec,test,tmp"
    DS_ANALYZER_IMAGE_TAG: "latest"
  artifacts:
    reports:
      dependency_scanning: gl-dependency-scanning-report.json
```

---

## Étape 6 : Prioriser les vulnérabilités

### Matrice de criticité

| CVSS Score | Niveau | SLA Correction | Action |
|------------|--------|----------------|--------|
| 9.0 - 10.0 | Critique | 24-48h | Patch immédiat, hotfix production |
| 7.0 - 8.9 | Élevé | 7 jours | Patch prioritaire |
| 4.0 - 6.9 | Moyen | 30 jours | Planifier dans sprint |
| 0.1 - 3.9 | Faible | 90 jours | Backlog |

### Facteurs de priorisation

**Au-delà du CVSS, considérer** :

1. **Exploitabilité** : Exploit public disponible ? (EPSS score)
2. **Reachability** : Code vulnérable réellement utilisé ?
3. **Exposition** : Endpoint public ou interne ?
4. **Données** : Données sensibles accessibles ?

**Exemple d'analyse** :

```
Vulnérabilité : Prototype Pollution in lodash (CVSS 7.4)
- EPSS : 0.02% (pas d'exploit connu)
- Reachability : Code vulnérable non appelé dans notre app
- Exposition : Backend uniquement
→ Priorité : Moyenne (peut attendre 30 jours)
```

---

## Étape 7 : Corriger les vulnérabilités

### Stratégie 1 : Mise à jour simple

```bash
# Node.js
npm update lodash

# Python
pip install --upgrade django

# Java (Maven)
mvn versions:use-latest-releases

# Go
go get -u github.com/gin-gonic/gin
```

---

### Stratégie 2 : Résolution de conflits

**Problème** : Dépendance A nécessite lodash v3.x, dépendance B nécessite lodash v4.x

**Solution Node.js (npm >= 8.3)** :

```json
{
  "overrides": {
    "lodash": "^4.17.21"
  }
}
```

**Solution Python (poetry)** :

```toml
[tool.poetry.dependencies]
django = "^4.0"

[tool.poetry.overrides]
urllib3 = "^2.0"
```

---

### Stratégie 3 : Patches temporaires (si aucune version fixée)

**Node.js - patch-package** :

```bash
# Installer patch-package
npm install --save-dev patch-package

# Modifier node_modules/vulnerable-package/index.js manuellement

# Générer le patch
npx patch-package vulnerable-package

# Le patch sera automatiquement appliqué à chaque npm install
```

**Python - monkeypatch** :

```python
# workarounds/vulnerable_lib_patch.py
import vulnerable_lib

# Corriger la fonction vulnérable
def safe_function(input):
    # Version sécurisée
    return sanitize(input)

vulnerable_lib.vulnerable_function = safe_function
```

---

### Stratégie 4 : Remplacement de dépendance

**Si pas de fix disponible, remplacer par une alternative** :

```
moment.js (deprecated) → day.js ou date-fns
request (deprecated) → axios ou node-fetch
lodash → native ES6+ methods
```

---

## Étape 8 : Monitoring continu

### Dashboard centralisé

**Snyk Dashboard** :

- Vue consolidée de tous les projets
- Tendances des vulnérabilités
- Alertes Slack/email

**GitHub Security Tab** :

- Dependabot alerts
- Code scanning results
- Secret scanning

**OWASP Dependency-Track** (self-hosted) :

```bash
# Déployer avec Docker
docker run -d \
  -p 8080:8080 \
  --name dependency-track \
  -v /var/lib/dependency-track:/data \
  dependencytrack/dependency-track
```

---

### Alertes automatiques

**Slack webhook** :

```yaml
# .github/workflows/dependency-alerts.yml
name: Dependency Alerts

on:
  schedule:
    - cron: '0 9 * * MON'  # Tous les lundis à 9h

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run npm audit
        id: audit
        run: |
          npm audit --json > audit.json
          echo "::set-output name=critical::$(jq '.metadata.vulnerabilities.critical' audit.json)"

      - name: Send Slack notification
        if: steps.audit.outputs.critical > 0
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "🚨 ${{ steps.audit.outputs.critical }} critical vulnerabilities detected in dependencies"
            }
```

---

## Étape 9 : Politique de gestion des dépendances

### Règles à documenter

**Créer `DEPENDENCY-POLICY.md`** :

```markdown
# Politique de gestion des dépendances

## Règles d'ajout de dépendances

- [ ] Vérifier le nombre de téléchargements (npm/PyPI)
- [ ] Vérifier la date de dernière release (< 6 mois)
- [ ] Vérifier le nombre de mainteneurs (> 2)
- [ ] Vérifier l'absence de vulnérabilités connues
- [ ] Justifier l'ajout (pas de réinvention de roues)

## SLA de correction

- **Critique** : 48h
- **Élevé** : 7 jours
- **Moyen** : 30 jours
- **Faible** : 90 jours

## Process de revue

- PR Dependabot : auto-merge si tests passent (minor/patch)
- PR Dependabot : revue manuelle (major)
- Nouvelle dépendance : approbation security champion
```

---

## Checklist de validation

- [ ] Scan de dépendances configuré en CI/CD
- [ ] Dependabot/Snyk activé et configuré
- [ ] Alertes automatiques configurées (Slack/email)
- [ ] SLA de correction documentés et respectés
- [ ] Pas de vulnérabilités CRITICAL en production
- [ ] Dashboard de monitoring accessible
- [ ] Équipe formée au process de correction
- [ ] Politique de dépendances documentée

---

## Métriques de succès

- **Mean Time To Remediate (MTTR)** : < 7 jours pour HIGH
- **Taux de vulnérabilités critiques** : 0 en production
- **Couverture** : 100% des dépendances scannées
- **Freshness** : 80% des dépendances < 6 mois
- **Auto-merge rate** : > 80% des PR Dependabot auto-mergées

---

## Dépannage

### "Too many vulnerabilities" - scan bloqué

**Solution** :

1. Prioriser : ne bloquer que sur CRITICAL/HIGH
2. Créer un plan de remédiation sur 30 jours
3. Ajouter des exceptions temporaires

```yaml
# .github/workflows/audit.yml
- name: Audit with exceptions
  run: npm audit --audit-level=critical
```

### Dépendance transitive non patchable

**Solution** :

1. Vérifier si override/resolution possible
2. Ouvrir une issue sur le package parent
3. Envisager un fork temporaire
4. Documenter le risque accepté

### Faux positifs

**Solution** :

```bash
# Créer .snyk pour ignorer
cat > .snyk << EOF
version: v1.22.1
ignore:
  SNYK-JS-LODASH-1234567:
    - lodash:
        reason: 'Not exploitable in our context'
        expires: '2025-12-31'
EOF
```

---

## Ressources

- [npm audit Documentation](https://docs.npmjs.com/cli/v9/commands/npm-audit)
- [Snyk Documentation](https://docs.snyk.io/)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [NVD Database](https://nvd.nist.gov/)

---

**Prochaine étape** : Créer des tests de régression sécurité avec [security-regression-tests-template.md](security-regression-tests-template.md)
