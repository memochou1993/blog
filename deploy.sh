#!/bin/bash

if [ -z "$1" ]; then
    read -p "Enter your commit message: " commit_msg
else
    commit_msg="$1"
fi

echo "Your commit message is: $commit_msg"

read -p "Are you sure you want to proceed? (yes/no): " confirmation

function confirm() {
    case "$1" in
        yes|y|Yes|Y) return 0 ;;
        *) return 1 ;;
    esac
}

if ! confirm "$confirmation"; then
    echo "Deploy aborted."
    exit 0
fi

git add .

if [ -n "$(git status --porcelain)" ]; then
    git commit -m "$commit_msg"
else
    echo "No changes to commit."
fi

git push origin master

git checkout deployment

git fetch origin
git rebase origin/master || {
    echo "Rebase encountered conflicts. Please resolve manually."
    exit 1
}

npm run hexo -- clean
npm run hexo -- deploy --generate

git checkout master

echo "Deployment completed successfully."
