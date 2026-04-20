#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: $0 <extension-id> [extension-id ...]" >&2
  exit 1
fi

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable \
  -o "$TMP/server.tar.gz"
tar -xzf "$TMP/server.tar.gz" -C "$TMP" --strip 1

mkdir -p "$HOME/.vscode-server/extensions"

args=()
for ext in "$@"; do
  args+=(--install-extension "$ext")
done

"$TMP/bin/code-server" \
  --extensions-dir "$HOME/.vscode-server/extensions" \
  "${args[@]}"
