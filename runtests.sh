#!/bin/bash -x
# 
# The object of this is to
#  - format all source files with https://github.com/google/yapf
#  - quickly run all specified tests when a file changes
#  - push the code to some staging environment and run FT against it
#  - create a new git commit if all of the tests are passing :white_check_mark:
# 
# In general, while working on the project, I use http://entrproject.org/ to run the tests passively while I make changes. From this working directory, I can run:
# 
# $ ag -l | entr -d bash "$DIR/runtests.sh"
# 
# This will watch for any file modifications in the project, and re-run the tests (and possibly commit the code) when they occur (wow such TDD)
# 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_CHAPTER_LINK="https://www.obeythetestinggoat.com/book/chapter_outside_in.html"
COMMIT_MSG="Automated commit from passing tests. Now on $CURRENT_CHAPTER_LINK"

# startPyVenv() {
#     source "$DIR/venv/bin/activate"
# }

fail() {
    printf "\033[31mNot passing tests... :(\033[0m\n"
    exit 1
}

testSuperlists() {
	source "$DIR"/.env
	cd "$DIR/django" || fail
    printf "\033[32mRunning unit tests...\033[0m\n"
    time python manage.py test lists accounts || fail
    printf "\033[32mRunning QUnit javascript tests...\033[0m\n"
    time phantomjs lists/static/tests/runner.js lists/static/tests/tests.html || fail
    printf "\033[32mRunning local webdriver tests...\033[0m\n"
    time python manage.py test --failfast --parallel=8 functional_tests || fail
}

formatCode() {
    cd "$DIR/django" || fail
    printf "\033[32mApplying yapf...\033[0m\n"
    python -m yapf -i -r ./superlists
    python -m yapf -i -r ./lists
    python -m yapf -i -r ./functional_tests
}

branchOff() {
    cd "$DIR" || fail
    time git checkout dev
    time git add .
    time git status
    time git commit -m "$COMMIT_MSG" && git push mirror dev
}

fullTest() {
    cd "$DIR" || fail
    time ansible-playbook -i ansible_inventory deploy_superlists.yml || fail
    export STAGING_SERVER=superlists-staging.peppyhare.uk
    cd "$DIR/django" || fail
    printf "\033[32mRunning full FTs against live server...\033[0m\n"
    time python manage.py test --keepdb --failfast --parallel=8 functional_tests
}

commitCode() {
    printf "\033[32mCommitting changes to the master branch\033[0m\n\n"
    git stash | grep -q "No local changes"
    no_stash=$?
    git checkout master
    git pull mirror dev
    git push mirror master
    git checkout dev
    if [ $no_stash -gt 0 ]; then
        git stash pop
    fi
}

printf "\n\033[32m$(date) :  Testing out new changes now :)\033[0m\n"
testSuperlists || fail
formatCode
branchOff
fullTest || fail
commitCode
printf "\033[32mEverything's looking good :)\033[0m\n\n"