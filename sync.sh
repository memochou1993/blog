#!/bin/bash

echo "Enter your commit message:"

read input[1]

echo "Your commit message is:"

echo ${input[1]}

echo "Are you sure?"

read input[2]

function confirm()
{
    for option in "Yes" "yes" "Y" "y"
    do
        [[ $1 == ${option} ]] && confirm=true || confirm=false
    done
}

confirm ${input[2]}

if [ ${confirm} == true ]
then
    git add . && \
    git commit -m "${input[1]}" && \
    git push && \
    hexo clean && \
    hexo deploy --generate
fi
