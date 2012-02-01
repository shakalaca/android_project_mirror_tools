#!/bin/sh

REPO_PATH=/home/source/aosp.repo
GITWEB_PATH=/home/source/aosp

cd $REPO_PATH
find . -name "\.repo" -prune -o -name "\.git" -prune -o -name "*.git" -print | sed 's/^.\{2\}//g' > $GITWEB_PATH/project.list
