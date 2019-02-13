#!/bin/bash

echo "Enter your commit message:"

read message

echo "Your commit message is:"

echo "${message}"

echo "Are you sure?"

read confirm

if [ "${confirm}" = "Y" ] || [ "${confirm}" = "y" ];
then
    hexo deploy --generate && git add . && git commit -m "${message}" && git push
fi
