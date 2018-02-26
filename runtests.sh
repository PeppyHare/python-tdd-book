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
CURRENT_CHAPTER_LINK="https://www.obeythetestinggoat.com/book/chapter_server_side_debugging.html"

# startPyVenv() {
#     source "$DIR/venv/bin/activate"
# }

testSuperlists() {
	source "$DIR"/.env
	cd "$DIR/django" || exit 1
    python manage.py test lists \
    && python manage.py test accounts \
    && phantomjs lists/static/tests/runner.js lists/static/tests/tests.html \
    && python manage.py test --failfast functional_tests
}

formatCode() {
    cd "$DIR/django" || exit 1
    printf "\033[32mApplying yapf...\033[0m\n"
    python -m yapf -i -r ./superlists
    python -m yapf -i -r ./lists
    python -m yapf -i -r ./functional_tests
}

branchOff() {
    cd "$DIR" || exit 1
    git checkout dev
    git add .
    git status
    git commit -m "Automated commit from passing tests. Now on $CURRENT_CHAPTER_LINK" && git push origin dev
}

fullTest() {
    cd "$DIR" || exit 1
    ansible-playbook -i ansible_inventory deploy_superlists.yml
    export STAGING_SERVER=superlists-staging.peppyhare.uk
    cd "$DIR/django" || exit 1
    python manage.py test --failfast functional_tests
}

commitCode() {
    printf "\033[32mCommitting changes to the master branch\033[0m\n\n"
    git checkout master
    git pull origin dev
    git push origin master
    git checkout dev
}

fail() {
    printf "\033[31mNot passing tests... :(\033[0m\n"
    exit 1
}

success() {
    printf "\033[32mEverything's looking good :)\033[0m\n\n"
    return 0
}

echo ""
printf "\033[32m$(date) :  Testing out new changes now :)\033[0m\n"
testSuperlists || fail
formatCode
branchOff
fullTest || fail
commitCode
success