#!/bin/bash

process_diff_in_files() {
    IFS=$'\n'

    for line in $diff_in_files; do
        first=$(echo $line | awk '{print $(NF-1)}')
        second=$(echo $line | awk '{print $NF}')
        vimdiff $first $second
    done

    unset IFS
}

process_different_files() {
    echo "You are working on stage $inactive_stage"
    IFS=$'\n'

    for line in $different_files; do
        echo $line
        filepath=$(echo $line | sed 's/: /\//g' | awk '{print $3}')
        read -p "$filepath Copy/Remove/Ignore (c/r/i)? " action
        if [ "$action" == "c" ]; then
            current_file_main_catalog=$(echo $filepath | awk -F'/' '{print $1}')
            if [ "$current_file_main_catalog" == $folder1 ]; then
                destination=$(echo $filepath | sed "s/$folder1/$folder2/g")
            else
                destination=$(echo $filepath | sed "s/$folder2/$folder1/g")
            fi
            cp -r $filepath $destination
        elif [ "$action" == "r" ]; then
            rm -rf $filepath
        fi
    done

    unset IFS
}

if [ "$#" -ne 3 ]; then
    echo "Please pass both of the stages folders and inactive stage"
    exit 1
fi

folder1=$1
folder2=$2
inactive_stage=$3

if [ ! -d "$folder1" ]; then
    echo "The folder $folder1 does not exist"
    exit 1
fi

if [ ! -d "$folder2" ]; then
    echo "The folder $folder2 does not exist"
    exit 1
fi


if [ "$inactive_stage" != "a" ] && [ "$inactive_stage" != "b" ]; then
    echo "The inactive stage should be either a or b"
    exit 1
fi

skip="migrator"

diff_output=$(diff -r $folder1 $folder2)
different_files=$(echo "$diff_output" | grep "Only in" | grep -v "$skip")
diff_in_files=$(echo "$diff_output" | grep "diff" | grep -v "$skip")


process_diff_in_files
process_different_files

git status