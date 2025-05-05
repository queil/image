#!/bin/bash
set -e

cd ./.upd
git pull

cp ./init$HOME -R /home/

# vscode-server update

export SERVER_BIN_DIR="$HOME/.vscode-server/bin"
export VSCODE_EXTRACTED_PATH="/tmp/vscode"
export VSCODE_TAR_GZ="/tmp/vscode-server-linux-x64.tar.gz"

mkdir -p $SERVER_BIN_DIR
mkdir -p $VSCODE_EXTRACTED_PATH

curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o $VSCODE_TAR_GZ

tar -zxvf $VSCODE_TAR_GZ -C $VSCODE_EXTRACTED_PATH --strip 1
export VSCODE_GIT_HASH=$(cat "$VSCODE_EXTRACTED_PATH/product.json" | jq -r .commit)
echo "VSCODE_GIT_HASH: $VSCODE_GIT_HASH"

export CURRENT_VER_DIR="$SERVER_BIN_DIR/$VSCODE_GIT_HASH"
ls $CURRENT_VER_DIR > /dev/null 2>&1 && rm $VSCODE_EXTRACTED_PATH -rf || mv "$VSCODE_EXTRACTED_PATH" "$CURRENT_VER_DIR"
touch $CURRENT_VER_DIR/0
rm $VSCODE_TAR_GZ

ln -sf $CURRENT_VER_DIR/bin/code-server $HOME/.local/bin/code-server

echo "Update OK"
