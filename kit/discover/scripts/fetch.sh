#!/usr/bin/env bash
# Download resources for /osk-discover
set -euo pipefail

GITHUB_RAW="https://raw.githubusercontent.com/Scttpr/OpenSecKit/main"
DIR=".osk/kit/discover"

[[ -d "$DIR/templates" ]] && { echo "Already fetched. Use rm -rf $DIR to re-fetch."; exit 0; }

cat << 'EOF'

   ___  ____  _  __   ____  _
  / _ \/ ___|| |/ /  |  _ \(_)___  ___ _____   _____ _ __
 | | | \___ \| ' /   | | | | / __|/ __/ _ \ \ / / _ \ '__|
 | |_| |___) | . \   | |_| | \__ \ (_| (_) \ V /  __/ |
  \___/|____/|_|\_\  |____/|_|___/\___\___/ \_/ \___|_|

EOF
echo "Fetching resources..."

# Templates (data)
for f in index business product architecture data actors boundaries integrations controls tooling team operations gaps glossary supply_chain user-journeys; do
    mkdir -p "$DIR/templates/data"
    curl -sf "$GITHUB_RAW/kit/discover/templates/data/${f}.yaml.tera" -o "$DIR/templates/data/${f}.yaml.tera"
done
echo "  ✓ templates/data"

# Templates (outputs)
for f in architecture developer onboarding operations product security; do
    mkdir -p "$DIR/templates/outputs"
    curl -sf "$GITHUB_RAW/kit/discover/templates/outputs/${f}.md.tera" -o "$DIR/templates/outputs/${f}.md.tera"
done
echo "  ✓ templates/outputs"

# Prompts
for f in discover 01-product-context 02-architecture 03-domain-model 04-ecosystem 05-operations 06-synthesis; do
    mkdir -p "$DIR/prompts"
    curl -sf "$GITHUB_RAW/kit/discover/prompts/${f}.md" -o "$DIR/prompts/${f}.md"
done
echo "  ✓ prompts"

# Schema
mkdir -p "$DIR/schemas"
curl -sf "$GITHUB_RAW/kit/discover/schemas/workflow-state.yaml" -o "$DIR/schemas/workflow-state.yaml"
echo "  ✓ schemas"

echo "Done! Resources in $DIR/"
