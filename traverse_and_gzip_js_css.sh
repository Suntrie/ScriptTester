#!/usr/bin/env bash

#Based on directory tree traversal: https://stackoverflow.com/a/18897659
function traverse_and_gzip() {
for FILE in "$1"/*
do
    if [ ! -d "$FILE" ] ; then
        local EXTENSION=${FILE##*.}
        echo $EXTENSION
        if [ "$EXTENSION" = "js" ] || [ "$EXTENSION" = "css" ]; then
           echo "Gzipping file: $FILE"
           gzip -k "$FILE"
        fi
    else
        echo "Entering recursion with: ${FILE}"
        traverse_and_gzip "${FILE}"
    fi
done
}

if [ $# -eq 0 ]
  then
    DIR=.
  else
    DIR="$1"
fi

traverse_and_gzip $DIR