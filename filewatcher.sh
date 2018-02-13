#!/bin/bash -x 
# 
# This is just a wrapper for the filewatcher gem
#  (https://github.com/thomasfl/filewatcher)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

filewatcher '**/*.py **/*.sh **/templates/*.html' "bash $DIR/runtests.sh"