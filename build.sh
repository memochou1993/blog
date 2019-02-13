#!/bin/bash

echo "Enter your commit message:"

read input

hexo deploy --generate && git add . && git commit -m "${input}" && git push
