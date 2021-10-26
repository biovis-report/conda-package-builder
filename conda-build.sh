#!/bin/bash
# change the package name to the existing PyPi package you would like to build

set -o pipefail
set -e

show_help(){
cat << EOF
usage: $(echo $0) [-m <mode>] [-p <pkg_name>] [-P <platform>] [-d <conda_dir>] [-b] [-V <pkg_version>]
       -m mode: Running mode, e.g. local, pypi, cran.
       -p pkg_name: package name.
       -V pkg_version: package version.
       -P platfrom: e.g. osx-64 linux-32 linux-64 win-32 win-64
       -d conda build directory: e.g. $HOME/miniconda3/conda-bld/osx-64
       -b enable download build file.
EOF
}

while getopts ":hbm:p:P:d:V:" arg
do
	case "$arg" in
		"m")
			mode="$OPTARG"
			;;
        "V")
            pkg_version="$OPTARG"
            ;;
        "b")
            enable_build_file='yes'
            ;;
		"p")
			pkg_name="$OPTARG"
			;;
        "P")
            platform="$platform"
            ;;
        "d")
            conda_dir="$conda_dir"
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

if [ -z "$pkg_name" ]; then
    echo "You must specify a package name using -p argument."
    exit 1
fi

if [ "$mode" == 'pypi' ] || [ "$mode" == 'local' ] || [ "$mode" == 'cran' ]; then
    mode=$mode
elif [ -z "$mode" ] && [ ! -d "$pkg_name" ]; then
    mode='pypi'
else
    mode='local'
fi

if [ -z "$platform" ]; then
    os=`uname -s`
    if [ "$os" == 'Darwin' ]; then
        platform='osx-64'
    elif [ "$os" == 'Linux' ]; then
        platform='linux-64'
    fi
fi

if [ -z "$conda_dir" ]; then
    conda_dir="$PWD/$platform"
fi

if [ "$mode" == 'pypi' ]; then
    echo "Download $pkg_name from pypi..."
    args=""

    if [ ! -z "$pkg_version" ]; then
        args=$(echo "$args --version $pkg_version")
    fi

    echo "Running conda skeleton pypi $args $pkg_name"
    eval "conda skeleton pypi $args $pkg_name"
elif [ "$mode" == 'cran' ]; then
    echo "Download $pkg_name from cran..."
    args=""

    if [ ! -z "$pkg_version" ]; then
        args=$(echo "$args --version $pkg_version")
    fi

    echo "Running conda skeleton cran $args $pkg_name"
    eval "conda skeleton cran $args $pkg_name"
fi

if [ -d "$pkg_name" ]; then
    recipe_dir="$pkg_name"
    cd "$recipe_dir"
else
    recipe_dir=$(pwd)
    cd "$recipe_dir"
fi

# adjust the Python versions you would like to build
echo "Building conda package ..."
printf "Mode: $mode \nPlatform: $platform \nConda: $conda_dir \nPackageName: $pkg_name\n\n"

if [ "$enable_build_file" == 'yes' ]; then
    if [ ! -f "build.sh" ]; then
        echo '$PYTHON -m pip install . --no-deps --ignore-installed -vv' > build.sh
    fi

    if [ ! -f "bld.bat" ]; then
        echo '%PYTHON% -m pip install . --no-deps --ignore-installed -vv; if errorlevel 1 exit 1' > bld.bat
    fi
fi

cd ../
array=( 3.6 3.7 3.8 3.9 3.10 )
# building conda packages
for i in "${array[@]}"
do
	conda build --python "$i" "$recipe_dir";
done

# convert package to other platforms
platforms=( osx-64 linux-64 win-64 )
dest_dir=$(dirname $conda_dir)

find "$conda_dir" -name *.tar.bz2 | grep "$pkg_name" | while read file
do
    echo "$file"
    #conda convert --platform all $file -o $HOME/conda-bld/
    for platform in "${platforms[@]}"
    do
       conda convert --platform "$platform" "$file" -o "$dest_dir"
    done    
done

echo "Building conda package done!"

echo "Get all files from $dest_dir"
