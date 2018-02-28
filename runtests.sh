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
EC2_VENV="/home/ubuntu/GitHub/python-tdd-book/venv"

ssh_ec2_cmd() {
    ssh ubuntu@superlists.peppyhare.uk
}

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
    python manage.py test lists accounts || fail
    printf "\033[32mRunning QUnit javascript tests...\033[0m\n"
    phantomjs lists/static/tests/runner.js lists/static/tests/tests.html || fail
}

formatCode() {
    cd "$DIR/django" || fail
    printf "\033[32mApplying yapf...\033[0m\n"
    python -m yapf -i -p -r ./superlists ./lists ./functional_tests
}

branchOff() {
    cd "$DIR" || fail
    printf "\033[32mPushing changes to dev branch...\033[0m\n"
    git checkout dev
    git commit -am "$COMMIT_MSG" && git push mirror dev
}

fullTest() {
    cd "$DIR" || fail
    ssh ubuntu@superlists.peppyhare.uk "/bin/bash -l /home/ubuntu/GitHub/python-tdd-book/runtests.remote.sh" || fail
    export STAGING_SERVER=superlists-staging.peppyhare.uk
    python "$DIR/django/manage.py" test --keepdb --failfast --parallel=8 -v functional_tests || fail
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
time testSuperlists || fail
time formatCode
time branchOff
time fullTest || fail
time commitCode
printf "\033[32mEverything's looking good :)\033[0m\n\n"
sleep 1