#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR"/venv/bin/activate

fail() {
	printf "\033[31Not passing tests... :(\033[0m\n"
}

printf "\033[32mUpdating source from git...\033[0m\n"
cd "$DIR" || fail
git pull mirror dev || fail
git status

printf "\033[32mRunning Ansible deployment of new source...\033[0m\n"
time ansible-playbook -i 'localhost,' -c local --extra-vars "ansible_python_interpreter=$DIR/venv/bin/python" "$DIR/deploy_superlists.yml" || fail

printf "\033[32mRunning full FTs against live server...\033[0m\n"
export STAGING_SERVER=superlists-staging.peppyhare.uk
time python "$DIR/django/manage.py" test --keepdb --failfast --parallel=8 functional_tests || fail
