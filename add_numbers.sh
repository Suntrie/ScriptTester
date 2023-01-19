#!/usr/bin/env bash

add_even_numbers() {
    local SUM=0
    local i=0

    for x in $*
    do
       if [ $((i%2)) -eq 0  ]
       then
          SUM=$((SUM+x))
       fi
       ((i++))
    done

    echo $SUM
}

add_even_numbers $*