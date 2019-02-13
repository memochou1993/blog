#!/bin/bash

echo "Enter your commit message:"

read message

echo "Your commit message is:"

echo ${message}

echo "Are you sure?"

read confirm

for option in "Yes" "yes" "Y" "y"
do
    if [ ${confirm} == ${option} ]
    then
        hexo deploy --generate && git add . && git commit -m "${message}" && git push
    fi
done
