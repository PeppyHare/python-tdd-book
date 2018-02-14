#!/bin/bash -x 
# 
# This is just a wrapper for http://entrproject.org/
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GPG_TTY=$(tty)
export GPG_TTY

# Can also use `find` here if silversurfer not installed
ls -d * | entr -d bash "$DIR/runtests.sh"
