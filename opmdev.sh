#!/bin/bash

DIR="/usr/opm"

# Function to install
install() {
    echo "Installing: $file"
    if [ ! -f "$file" ]; then
	echo "$file not found"
	exit 1
    fi
    
    if [ ! -d "$DIR" ]; then
	mkdir "$DIR"
    fi

    cp $file $DIR
    tar -xvf $(basename "$file")

    cd $DIR/$(basename $file .opm)
    echo "$(basename $file .opm)"

    source config.sh

    # Delete config.sh
    rm config.sh

    
    
    
    cp -R ./* /

    echo "Installed $NAME"
}

# Function to uninstall
uninstall() {
    echo "Uninstalling: $file"
    # Add your uninstallation logic here
}

# Check for the correct number of arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [install|uninstall] <file>"
    exit 1
fi

# Read the option and file
option=$1
file=$2

# Case statement for options
case $option in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo "Invalid option: $option. Please use 'install' or 'uninstall'."
        exit 1
        ;;
esac

# Print the variable
echo "File: $file"
