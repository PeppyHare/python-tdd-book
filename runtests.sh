#!/bin/bash -x
# 
# The object of this is to
#  - format all source files with https://github.com/google/yapf
#  - quickly run all specified tests when a file changes
#  - create a new git commit if all of the tests are passing :white_check_mark:
# 
# In general, while working on the project, I use https://github.com/cespare/reflex to run the tests passively while I make changes. From this working directory, I can run:
# 
# $ reflex bash runtests.sh
# 
# This will watch for any file modifications in the project, and re-run the tests (and possibly commit the code) when they occur (wow such TDD)
# 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_CHAPTER_LINK="https://www.obeythetestinggoat.com/book/chapter_outside_in.html"

# startPyVenv() {
#     source "$DIR/venv/bin/activate"
# }

testSuperlists() {
    python3.6 manage.py test lists \
    && python3.6 manage.py test accounts \
    && phantomjs lists/static/tests/runner.js lists/static/tests/tests.html \
    && python3.6 manage.py test functional_tests
}

formatCode() {
	cd "$DIR" || exit
	printf "\033[32mApplying yapf...\033[0m\n"
    python3.6 -m yapf -i -r ./superlists
    python3.6 -m yapf -i -r ./lists
    python3.6 -m yapf -i -r ./functional_tests

}

commitCode() {
	cd "$DIR" || exit
	git add .
	git status
	git commit -m "Automated commit from passing tests. Now on $CURRENT_CHAPTER_LINK" && git push
	printf "\033[32mEverything's looking good :)\033[0m\n\n"
	return 0 # just in case nothing to commit
}

echo ""
echo "$(date) :  Testing out new changes now :)"

testSuperlists
STATUS=$?
sleep 1
if [[ $STATUS == "0" ]]; then
    printf "\033[32mPassing tests!\033[0m\n"
    formatCode
	commitCode
else
	printf "\033[31mNot passing tests... :(\033[0m\n"
fi
