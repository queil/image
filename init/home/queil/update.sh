#!/bin/bash
set -e

cd ./.upd
git pull

cp ./init$HOME -R /home/

echo "Update OK"
