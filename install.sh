#!/usr/bin/env bash
# Pasang template Claude → Codex → Claude ke sebuah project.
# Pakai: ./install.sh /path/ke/project [--force]
set -euo pipefail

src="$(cd "$(dirname "$0")/template" && pwd)"
dest="${1:?Pakai: ./install.sh /path/ke/project [--force]}"
force="${2:-}"
[ -d "$dest" ] || { echo "Folder tidak ada: $dest" >&2; exit 1; }

copy() {
  local rel="$1"
  if [ -e "$dest/$rel" ] && [ "$force" != "--force" ]; then
    echo "lewati  $rel (sudah ada; pakai --force untuk menimpa)"
  else
    mkdir -p "$dest/$(dirname "$rel")"
    cp "$src/$rel" "$dest/$rel"
    echo "salin   $rel"
  fi
}

copy AGENTS.md
copy .claude/CLAUDE.md
for f in TASK PLAN RESULT REVIEW; do copy ".agent/$f.md"; done

if [ -d "$dest/.git" ] && ! grep -qxF '.agent/' "$dest/.gitignore" 2>/dev/null; then
  echo ".agent/" >> "$dest/.gitignore"
  echo "tambah  .agent/ ke .gitignore"
fi

echo
echo "Selesai. Berikutnya: isi bagian <...> di $dest/AGENTS.md"
