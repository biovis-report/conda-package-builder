#!/bin/bash

set -o pipefail
set -e

show_help(){
cat << EOF
usage: $(echo $0) [-c <conda_dir>] [-u <username>]
       -c conda_dir: The root directory of conda building.
       -u username: Which account do you want to upload.
       -U upload: whether to upload?
EOF
}

while getopts ":hc:u:U" arg
do
    case "$arg" in
        "c")
            conda_dir="$OPTARG"
        ;;
        "u")
            username="$OPTARG"
        ;;
        "U")
            upload=true
        ;;
        "?")
            echo "Unkown option: $OPTARG"
            exit 1
        ;;
        ":")
            echo "No argument value for option $OPTARG"
        ;;
        "h")
            show_help
            exit 0
        ;;
        "*")
            echo "Unknown error while processing options"
            show_help
            exit 1
        ;;
    esac
done

if [ -z "$current_platform" ]; then
    os=`uname -s`
    if [ "$os" == 'Darwin' ]; then
        current_platform='osx-64'
        elif [ "$os" == 'Linux' ]; then
        current_platform='linux-64'
    fi
fi

if [ -z "$conda_dir" ];then
    echo "You must specify the -c argument."
    exit 1
fi

echo 'Convert packages...'

# convert package to other platforms
platforms=( osx-64 linux-64 win-64 )
dest_dir=$(dirname $conda_dir)

find "$conda_dir/$current_platform" -name *.tar.bz2 | grep "$pkg_name" | while read file
do
    echo "$file"
    # conda convert --platform all $file -o $HOME/conda-bld/
    for platform in "${platforms[@]}"
    do
        if [ "$platform" != "$current_platform" ];then
            conda convert --platform "$platform" "$file" -o "$conda_dir" || echo "Failed"
        fi
    done
done

conda index "$conda_dir"
echo "Building conda package done!"

if [ ! -z "$upload" ]; then
    echo "Uploading all packages to anaconda.org..."

    find "$conda_dir" -name *.tar.bz2 | while read file
    do
        echo "$file"
        if [ -z "$username" ];then
            anaconda upload "$file"
        else
            anaconda upload -u "$username" "$file" --skip
        fi
    done
fi

echo "Get all files from $conda_dir"