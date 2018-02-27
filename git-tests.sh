#!/bin/bash -x

# Test with no SSH changes:

# touch 'a.testfile'
# git add .
# git commit -m "Dummy commit"
# rm 'a.testfile'
# git add .
# git commit -m "Dummy commit"
# git push origin dev

# Results in:
# 0.03user 0.15system 0:05.10elapsed 3%CPU (0avgtext+0avgdata 3244maxresident)k
# 0inputs+0outputs (0major+5099minor)pagefaults 0swaps

git pull