#!/usr/bin/env bash
# Download resources for /osk-comply rgpd
set -euo pipefail

GITHUB_RAW="https://raw.githubusercontent.com/Scttpr/OpenSecKit/main"
DIR=".osk/kit/comply/frameworks/rgpd"

[[ -d "$DIR/knowledge" ]] && { echo "Already fetched. Use rm -rf $DIR to re-fetch."; exit 0; }

cat << 'EOF'

   ___  ____  _  __    ____  ____ ____  ____
  / _ \/ ___|| |/ /   |  _ \/ ___|  _ \|  _ \
 | | | \___ \| ' /    | |_) | |  _| |_) | | | |
 | |_| |___) | . \    |  _ <| |_| |  __/| |_| |
  \___/|____/|_|\_\   |_| \_\\____|_|   |____/

EOF
echo "Fetching RGPD resources..."

# Framework
mkdir -p "$DIR"
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/framework.yaml" -o "$DIR/framework.yaml"
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/prompt.md" -o "$DIR/prompt.md"
echo "  ✓ framework"

# Knowledge - core
mkdir -p "$DIR/knowledge/core"
for f in registre-traitements guide-securite guide-sous-traitant aipd-liste-obligatoire aipd-modeles breach-notification interet-legitime violations-donnees; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/knowledge/core/${f}.md" -o "$DIR/knowledge/core/${f}.md"
done
echo "  ✓ knowledge/core"

# Knowledge - reference
mkdir -p "$DIR/knowledge/reference"
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/knowledge/reference/rgpd-complet.md" -o "$DIR/knowledge/reference/rgpd-complet.md"
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/knowledge/reference/adequacy-list.yaml" -o "$DIR/knowledge/reference/adequacy-list.yaml"
for f in edpb-droit-acces edpb-breach-examples sccs-2021; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/knowledge/reference/${f}.md" -o "$DIR/knowledge/reference/${f}.md"
done
echo "  ✓ knowledge/reference"

# Knowledge - optional
mkdir -p "$DIR/knowledge/optional"
for f in cookies-guidelines guide-dpo; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/knowledge/optional/${f}.md" -o "$DIR/knowledge/optional/${f}.md"
done
echo "  ✓ knowledge/optional"

# Knowledge - other
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/knowledge/_manifest.yaml" -o "$DIR/knowledge/_manifest.yaml"
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/knowledge/french_law_78-17_1978_complete.md" -o "$DIR/knowledge/french_law.md"

# Schemas
mkdir -p "$DIR/schemas"
for f in workflow-state processing-inventory aipd gaps-analysis assessment-extension treatment; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/schemas/${f}.yaml" -o "$DIR/schemas/${f}.yaml"
done
echo "  ✓ schemas"

# Templates
mkdir -p "$DIR/templates/core" "$DIR/templates/procedures" "$DIR/templates/contracts" "$DIR/templates/public"
for f in registre-traitement aipd lia mesures-securite; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/templates/core/${f}.md.tera" -o "$DIR/templates/core/${f}.md.tera"
done
for f in droits-personnes violation-donnees; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/templates/procedures/${f}.md.tera" -o "$DIR/templates/procedures/${f}.md.tera"
done
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/templates/contracts/clause-sous-traitant.md.tera" -o "$DIR/templates/contracts/clause-sous-traitant.md.tera"
curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/templates/public/politique-confidentialite.md.tera" -o "$DIR/templates/public/politique-confidentialite.md.tera"
for f in assessment-summary export-report gap-report sub-processor-register; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/templates/${f}.md.tera" -o "$DIR/templates/${f}.md.tera"
done
echo "  ✓ templates"

# Prompts
mkdir -p "$DIR/prompts"
for f in 01-inventory 02-aipd 03-assess 04-gaps 05-generate; do
    curl -sf "$GITHUB_RAW/kit/comply/frameworks/rgpd/prompts/${f}.md" -o "$DIR/prompts/${f}.md"
done
echo "  ✓ prompts"

echo "Done! Resources in $DIR/"
