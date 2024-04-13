cd $(git rev-parse --show-toplevel)
git pull

export VSCODE_EXTRACTED_PATH="/tmp/vscode"
export VSCODE_TAR_GZ="/tmp/vscode-server-linux-x64.tar.gz"

curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o $VSCODE_TAR_GZ
tar -zxvf $VSCODE_TAR_GZ -C $VSCODE_EXTRACTED_PATH --strip 1
export VSCODE_GIT_HASH=$(cat "$VSCODE_EXTRACTED_PATH/product.json" | jq -r .commit)
echo "VSCODE_GIT_HASH: $VSCODE_GIT_HASH"
export BIN_DIR="$HOME/.vscode-server/bin/$VSCODE_GIT_HASH"
mkdir -p $BIN_DIR
#tar -zxvf $VSCODE_TAR_GZ -C $BIN_DIR --strip 1
touch $BIN_DIR/0
rm $VSCODE_TAR_GZ

cp ./init$HOME -R /home/

ln -s $BIN_DIR/bin/code-server $HOME/.local/bin/code-server
