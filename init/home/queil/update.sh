#!/bin/bash
set -e

cd ./.upd
git pull
cp ./init$HOME -R /home/

chmod +x $HOME/add-vscode-extensions.sh

echo "Update OK"
