#!/bin/bash -x 
# 
# This is just a wrapper for the filewatcher gem
#  (https://github.com/thomasfl/filewatcher)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GPG_TTY=$(tty)
export GPG_TTY
filewatcher '**/*.py **/*.sh **/*.html' "bash $DIR/runtests.sh
