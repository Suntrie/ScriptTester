#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit
fi

function download_voyna_i_mir() {
    #https://avidreaders.ru/download/voyna-i-mir-tom-1.html?f=txt is an html page
    echo 'Downloading `voyna_i_mir`...'
    curl 'https://www.litres.ru/gettrial/?art=49592199&format=txt&lfrom=159481197' -o voyna_i_mir.zip
    ERROR=$?
    if [ $ERROR != 0 ]; then
        >&2 echo "Error: $ERROR"
    else
        echo 'Successfully downloaded'
    fi;
}

function unpack_voyna_i_mir(){
    unzip voyna_i_mir.zip
    iconv -f WINDOWS-1251 -t UTF-8 59495692.txt > voyna_i_mir.txt
}

#Based on https://unix.stackexchange.com/questions/41479/find-n-most-frequent-words-in-a-file
function count_word_frequency() {
   #Reminder: print "Length: ", length($i) >> "success12.file" to log data
   #"князь" // "говорил" - зависит от >=5
   gawk '
       BEGIN { FS="[^а-яА-Я]+" } {

           for (i=1; i<=NF; i++) {
                word = tolower($i);
                if (length($i) >= 5){
                    words[word]++;
               }
           }
       }
       END {
           for (w in words)
                printf("%3d %s\n", words[w], w)
       } ' | sort -rn | head -5
}


function print_stat(){
    local number=0
    local i=0
    for elem in $FREQ; do
        if [ $((i%2)) -eq 0  ]; then
            number=$elem
        else
            echo $elem $number
        fi
        ((i++))
    done
}

function freq_keys_contains(){
    local number=0
    for elem in $FREQ; do
        if [ $((i%2)) = 1  ]; then
            if [ $elem = $1 ]; then
                echo found
                return 0
            fi
        fi
        ((i++))
    done
    echo not_found
}

function collect_stat(){
    local SITES_TO_COLLECT_STAT==()

    if [ $(freq_keys_contains "князь") = "found" ]; then
       SITES_TO_COLLECT_STAT+=('https://ya.ru')
    fi
    if [ $(freq_keys_contains "говорил") = "not_found" ]; then
        SITES_TO_COLLECT_STAT+=('https://google.coom')
    fi

    SITES_TO_COLLECT_STAT+=("$1")

    for idx in ${!SITES_TO_COLLECT_STAT[@]}; do
      curl -w '%{json}\n' ${SITES_TO_COLLECT_STAT[$idx]}
    done
}

function download_file(){
    if [ "$1" != "" ]; then
        local TARGET_DIR=$2
        local DIR=$(find . -type d -maxdepth 1 -name "$TARGET_DIR")
        if [ "$DIR" = '' ]; then
            mkdir $TARGET_DIR
            echo "Directory $TARGET_DIR was created"
        fi
        local NAME_WITH_ADD=${1##*/}
        local NAME=${NAME_WITH_ADD%\?*}
        (cd $TARGET_DIR; curl "$1" -o "$NAME"; )
        echo "$(pwd)/$TARGET_DIR/$NAME"
    fi
}

function show_downloaded_file_stat(){
    local LS_PARAMS=$(ls -lh $1 | awk '{print $3, $4, $1, $5}')
    local FULL_PATH=$1
    local REL_PATH="./$2/$3"
    local STAT_DESCRIPTION="${LS_PARAMS} ${FULL_PATH} ${REL_PATH}"
    echo $STAT_DESCRIPTION
}

download_voyna_i_mir - uncomment to download
unpack_voyna_i_mir
FREQ="$(cat voyna_i_mir.txt | count_word_frequency)"
print_stat $FREQ

collect_stat $1

TARGET_DIR=download
DOWNLOADED_FILE="$(download_file $2 $TARGET_DIR)"
show_downloaded_file_stat $DOWNLOADED_FILE $TARGET_DIR $2


