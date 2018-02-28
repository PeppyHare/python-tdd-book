#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR"/venv/bin/activate

printf "\033[32mUpdating source from git...\033[0m\n"
pwd
ls -la
cd "$DIR" || exit 1
git pull mirror dev

printf "\033[32mRunning Ansible deployment of new source...\033[0m\n"
python --version
ansible-playbook -i 'localhost,' -c local "$DIR/deploy_superlists.yml"
