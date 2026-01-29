#!/usr/bin/env bash
set -euo pipefail

OUTPUT="${1:-context.txt}"

git rev-parse --is-inside-work-tree &>/dev/null || { echo "Error: Not a git repository"; exit 1; }

cat << 'EOF'

   ___  ____  _  __   ___                       _
  / _ \/ ___|| |/ /  |_ _|_ __   __ _  ___  ___| |_
 | | | \___ \| ' /    | || '_ \ / _` |/ _ \/ __| __|
 | |_| |___) | . \    | || | | | (_| |  __/\__ \ |_
  \___/|____/|_|\_\  |___|_| |_|\__, |\___||___/\__|
                                |___/

EOF
echo "Exporting to $OUTPUT..."

{
    echo "# Project Context - $(date -Iseconds)"
    echo ""
    git ls-files --cached --others --exclude-standard | while read -r file; do
        file "$file" 2>/dev/null | grep -q "binary" && continue
        [[ $(wc -c < "$file" 2>/dev/null || echo 0) -gt 102400 ]] && continue
        case "$file" in *.lock|*.min.js|*.min.css|*.map|*.svg|*.png|*.jpg|*.gif|*.ico|*.woff*|*.ttf|*.eot) continue ;; esac

        echo "=== $file ==="
        cat "$file" 2>/dev/null || true
        echo ""
    done
} > "$OUTPUT"

echo "Done! $(wc -l < "$OUTPUT") lines, $(du -h "$OUTPUT" | cut -f1)"
