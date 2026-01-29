#!/usr/bin/env bash
# Download resources for /osk-secure-* commands
set -euo pipefail

GITHUB_RAW="https://raw.githubusercontent.com/Scttpr/OpenSecKit/main"
DIR=".osk/kit/secure"

[[ -d "$DIR/knowledge" ]] && { echo "Already fetched. Use rm -rf $DIR to re-fetch."; exit 0; }

cat << 'EOF'

   ___  ____  _  __   ____
  / _ \/ ___|| |/ /  / ___|  ___  ___ _   _ _ __ ___
 | | | \___ \| ' /   \___ \ / _ \/ __| | | | '__/ _ \
 | |_| |___) | . \    ___) |  __/ (__| |_| | | |  __/
  \___/|____/|_|\_\  |____/ \___|\___|\__,_|_|  \___|

EOF
echo "Fetching resources..."

# Prompts
mkdir -p "$DIR/prompts"
for f in osk-secure-specify osk-secure-clarify osk-secure-plan osk-secure-tasks osk-secure-implement; do
    curl -sf "$GITHUB_RAW/kit/secure/prompts/${f}.md" -o "$DIR/prompts/${f}.md"
done
echo "  ✓ prompts"

# Schemas
mkdir -p "$DIR/schemas"
for f in security-spec risks; do
    curl -sf "$GITHUB_RAW/kit/secure/schemas/${f}.yaml" -o "$DIR/schemas/${f}.yaml"
done
echo "  ✓ schemas"

# Templates
mkdir -p "$DIR/templates/outputs" "$DIR/templates/data"
for f in security-spec security-plan security-tests risks; do
    curl -sf "$GITHUB_RAW/kit/secure/templates/outputs/${f}.md.tera" -o "$DIR/templates/outputs/${f}.md.tera"
done
curl -sf "$GITHUB_RAW/kit/secure/templates/data/risks.yaml.tera" -o "$DIR/templates/data/risks.yaml.tera"
echo "  ✓ templates"

# Principles
curl -sf "$GITHUB_RAW/kit/secure/principles.yaml" -o "$DIR/principles.yaml"
echo "  ✓ principles"

# Knowledge - 7 principles
principles=(
    "I-threat-modeling:stride-guide dfd-guide attack-trees-guide"
    "II-risk-analysis:scoring-methodology register-guide"
    "III-security-design:asvs-guide authentication-guide authorization-guide encryption-guide"
    "IV-security-testing:sast-guide dast-guide sca-guide regression-tests-guide"
    "V-secrets-management:vault-guide detection-guide rotation-guide"
    "VI-audit-logging:logging-strategy centralization-guide siem-integration alert-rules-guide"
    "VII-patch-management:dependency-scanning-guide prioritization-guide sla-guide emergency-procedure"
)
for entry in "${principles[@]}"; do
    dir="${entry%%:*}"
    files="${entry##*:}"
    mkdir -p "$DIR/knowledge/principles/$dir"
    for f in $files; do
        curl -sf "$GITHUB_RAW/kit/secure/knowledge/principles/$dir/${f}.md" -o "$DIR/knowledge/principles/$dir/${f}.md"
    done
done
echo "  ✓ knowledge (7 principles)"

# Libraries
mkdir -p "$DIR/knowledge/mappings" "$DIR/knowledge/libraries/controls" "$DIR/knowledge/libraries/threats"
curl -sf "$GITHUB_RAW/kit/secure/knowledge/mappings/asvs-component-mapping.yaml" -o "$DIR/knowledge/mappings/asvs-component-mapping.yaml"
curl -sf "$GITHUB_RAW/kit/secure/knowledge/libraries/controls/secure-defaults.yaml" -o "$DIR/knowledge/libraries/controls/secure-defaults.yaml"
for f in stride-common.md web-threats.yaml api-threats.yaml auth-threats.yaml data-threats.yaml; do
    curl -sf "$GITHUB_RAW/kit/secure/knowledge/libraries/threats/$f" -o "$DIR/knowledge/libraries/threats/$f"
done
echo "  ✓ libraries"

echo "Done! Resources in $DIR/"
