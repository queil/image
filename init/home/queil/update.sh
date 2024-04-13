cd $(git rev-parse --show-toplevel)
git pull

curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o /tmp/vscode-server-linux-x64.tar.gz && \
    tar -zxvf /tmp/vscode-server-linux-x64.tar.gz -C /tmp && \
    export VSCODE_GIT_HASH=$(cat /tmp/vscode/product.json | jq -r .commit) && \
    mkdir -p $HOME/.vscode-server/bin/$VSCODE_GIT_HASH && \
    tar -zxvf /tmp/vscode-server-linux-x64.tar.gz -C $HOME/.vscode-server/bin/$VSCODE_GIT_HASH --strip 1 && \
    touch $HOME/.vscode-server/bin/$VSCODE_GIT_HASH/0 && \
    rm /tmp/vscode-server-linux-x64.tar.gz

cp ./init/home/queil -R /home/
