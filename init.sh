#!/usr/bin/env bash
set -euo pipefail

GITHUB_RAW="https://raw.githubusercontent.com/Scttpr/openseckit/main"
OSK_DIR=".osk"
CLAUDE_DIR=".claude/commands"

cat << 'EOF'

   ___                   ____            _  ___ _
  / _ \ _ __   ___ _ __ / ___|  ___  ___| |/ (_) |_
 | | | | '_ \ / _ \ '_ \\___ \ / _ \/ __| ' /| | __|
 | |_| | |_) |  __/ | | |___) |  __/ (__| . \| | |_
  \___/| .__/ \___|_| |_|____/ \___|\___|_|\_\_|\__|
       |_|

EOF
echo "Initializing..."

mkdir -p "$OSK_DIR" "$CLAUDE_DIR"

commands=(
    "kit/discover/prompts/discover.md:osk-discover.md"
    "kit/comply/prompts/comply.md:osk-comply.md"
    "kit/comply/prompts/list.md:osk-comply-list.md"
    "kit/comply/prompts/status.md:osk-comply-status.md"
    "kit/secure/prompts/osk-secure-specify.md:osk-secure-specify.md"
    "kit/secure/prompts/osk-secure-clarify.md:osk-secure-clarify.md"
    "kit/secure/prompts/osk-secure-plan.md:osk-secure-plan.md"
    "kit/secure/prompts/osk-secure-tasks.md:osk-secure-tasks.md"
    "kit/secure/prompts/osk-secure-implement.md:osk-secure-implement.md"
)

for entry in "${commands[@]}"; do
    src="${entry%%:*}"
    dst="${entry##*:}"
    curl -sf "$GITHUB_RAW/$src" -o "$CLAUDE_DIR/$dst" && echo "  ✓ $dst"
done

echo ""
echo "Done!"
echo ""

echo "Run claude then /osk-discover to start."
