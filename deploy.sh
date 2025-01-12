#!/bin/bash

if [ -z "$1" ]; then
    read -p "Enter your commit message: " commit_msg
else
    commit_msg="$1"
fi

echo "Your commit message is: $commit_msg"

read -p "Are you sure? (yes/no): " confirmation

function confirm() {
    case "$1" in
        yes|y|Yes|Y) return 0 ;;
        *) return 1 ;;
    esac
}

if confirm "$confirmation"; then
    git add . &&
    git commit -m "$commit_msg" &&
    git push &&
    git checkout deployment &&
    git rebase master &&
    npm run hexo -- clean &&
    npm run hexo -- deploy --generate &&
    git checkout master
else
    echo "Deploy aborted."
fi
