#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR"/venv/bin/activate

printf "\033[32mUpdating source from git...\033[0m\n"
cd "$DIR" || exit 1
git pull mirror dev
git status

printf "\033[32mRunning Ansible deployment of new source...\033[0m\n"
time ansible-playbook -i 'localhost,' -c local --extra-vars "ansible_python_interpreter=$DIR/venv/bin/python" -vvvvv "$DIR/deploy_superlists.yml"

printf "\033[32mRunning full FTs against live server...\033[0m\n"
export STAGING_SERVER=superlists-staging.peppyhare.uk
time python "$DIR/manage.py" test --keepdb --failfast --parallel=8 functional_tests
