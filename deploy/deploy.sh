#!/bin/bash
set -v
#env
#bash deploy/install_puppet.sh
#echo "Running deploy/deploy.pp..."
#puppet apply deploy/deploy.pp

# https://github.com/sciurus/r10k-git-hook

umask 0022
while read oldrev newrev refname; do
    if [[ $refname =~ 'refs/heads/' ]]; then
        branch=$(git rev-parse --symbolic --abbrev-ref $refname)
        files=$(git diff-tree -r --name-only --no-commit-id ${oldrev}..${newrev})
        if [[ $files =~ 'Puppetfile' ]]; then
            echo "r10k updating $branch environment and modules"
            /usr/local/bin/r10k deploy environment $branch -p
        else
            echo "r10k updating $branch environment"
            /usr/local/bin/r10k deploy environment $branch
        fi
    else
        echo "r10k skipping $refname"
    fi
done


