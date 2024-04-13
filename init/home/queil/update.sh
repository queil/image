cd $(git rev-parse --show-toplevel)
git pull

export VSCODE_TAR_GZ=/tmp/vscode-server-linux-x64.tar.gz

curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o $VSCODE_TAR_GZ && \
    tar -zxvf $VSCODE_TAR_GZ -C /tmp && \
    export VSCODE_GIT_HASH=$(cat /tmp/vscode/product.json | jq -r .commit) && \
    export BIN_DIR=.vscode-server/bin/$VSCODE_GIT_HASH && \
    mkdir -p $BIN_DIR && \
    tar -zxvf /tmp/vscode-server-linux-x64.tar.gz -C $BIN_DIR --strip 1 && \
    touch $BIN_DIR/0 && \
    rm $VSCODE_TAR_GZ

cp ./init$HOME -R /home/

ln -s $BIN_DIR/bin/code-server $HOME/.local/bin/code-server
