#!/bin/bash -x

touch 'a.testfile'
git add .
git commit -m "Dummy commit"
rm 'a.testfile'
git add .
git commit -m "Dummy commit"
git push origin dev