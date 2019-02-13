#!/bin/bash

echo 'Enter your commit message:'

read input

npm run build -- ${input} && git push