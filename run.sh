#!/bin/bash
set -euo pipefail

PROJECT_DIR="/home/vagrant/final-practice"
DIR_PATH="https://github.com/shubhroses/final-practice.git"

echo ""
echo "1. Ensure Vagrant is up and running"
vagrant up --provide=qemu

echo ""
echo "2. Pull / Clone from git"
vagrant ssh -c "
    if [ -d ${PROJECT_DIR} ]; then
        cd ${PROJECT_DIR} && git pull origin main
    else
        git clone ${DIR_PATH} ${PROJECT_DIR}
    fi
"
