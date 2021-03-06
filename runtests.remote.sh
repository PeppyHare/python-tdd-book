#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR"/venv/bin/activate

fail() {
	printf "\033[31Not passing tests... :(\033[0m\n"
	exit 1
}

printf "\033[32mUpdating source from git...\033[0m\n"
cd "$DIR" || fail
git pull --force mirror dev || fail
git status

printf "\033[32mRunning Ansible deployment of new source...\033[0m\n"
time ansible-playbook -i 'localhost,' -c local --extra-vars "ansible_python_interpreter=$DIR/venv/bin/python" "$DIR/deploy_superlists.yml" || fail
