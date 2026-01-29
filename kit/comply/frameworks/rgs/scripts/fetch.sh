#!/usr/bin/env bash
# Download resources for /osk-comply rgs
set -euo pipefail

GITHUB_RAW="https://raw.githubusercontent.com/Scttpr/openseckit/main"
DIR=".osk/kit/comply/frameworks/rgs"

[[ -d "$DIR/knowledge" ]] && { echo "Already fetched. Use rm -rf $DIR to re-fetch."; exit 0; }

cat << 'EOF'

   ___  ____  _  __   ____   ____ ____
  / _ \/ ___|| |/ /  |  _ \ / ___/ ___|
 | | | \___ \| ' /   | |_) | |  _\___ \
 | |_| |___) | . \   |  _ <| |_| |___) |
  \___/|____/|_|\_\  |_| \_\\____|____/

EOF
echo "Fetching RGS resources..."

# Framework
mkdir -p "$DIR"
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgs/framework.yaml" -o "$DIR/framework.yaml"
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgs/prompt.md" -o "$DIR/prompt.md"
echo "  ✓ framework"

# Knowledge
mkdir -p "$DIR/knowledge"
for f in _manifest rgs-v2-document-principal rgs-v2-annexe-a1-certificats-electroniques rgs-v2-annexe-a2-politique-certification-personne rgs-v2-annexe-a3-politique-certification-services-applicatifs rgs-v2-annexe-a3-errata rgs-v2-annexe-a4-profils-certificats-algorithmes rgs-v2-annexe-a5-politique-horodatage rgs-v2-annexe-b1-mecanismes-cryptographiques rgs-v2-annexe-b2-gestion-cles rgs-v2-annexe-b3-authentification rgs-v2-annexe-c-audit-prestataires guide-hygiene-informatique guide-homologation-securite ebios-risk-manager; do
    ext=$([[ "$f" == "_manifest" ]] && echo "yaml" || echo "md")
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgs/knowledge/${f}.${ext}" -o "$DIR/knowledge/${f}.${ext}" 2>/dev/null || true
done
echo "  ✓ knowledge"

# Schemas
mkdir -p "$DIR/schemas"
for f in workflow-state level-assessment ebios-rm gaps-analysis assessment-extension tool-certifications; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgs/schemas/${f}.yaml" -o "$DIR/schemas/${f}.yaml"
done
echo "  ✓ schemas"

# Templates
mkdir -p "$DIR/templates"
for f in assessment-summary export-dossier system-perimeter homologation-checklist; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgs/templates/${f}.md.j2" -o "$DIR/templates/${f}.md.j2"
done
echo "  ✓ templates"

# Prompts
mkdir -p "$DIR/prompts"
for f in 01-level-assessment 02-ebios-rm 03-assess 04-gaps 05-dossier; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgs/prompts/${f}.md" -o "$DIR/prompts/${f}.md"
done
echo "  ✓ prompts"

echo "Done! Resources in $DIR/"
