#!/bin/bash

DIR="/usr/opm"

# Function to install
install() {
    echo "Installing: $file"

    file=$(realpath "$file")


    if [ ! -f "$file" ]; then
	echo "$file not found"
	exit 1
    fi
    
    if [ ! -d "$DIR" ]; then
	mkdir "$DIR"
    fi

    cd $DIR
    
    cp $file $DIR
    tar --same-owner --preserve-permissions -xvf $(basename "$file")

    cd $DIR/$(basename $file .opm)
    echo "$(basename $file .opm)"

    source config.sh

    mkdir "$DIR/Packages/$ALIAS"

    cp pkgfiles "$DIR/Packages/$ALIAS"
    cp config.sh "$DIR/Packages/$ALIAS"

    # Delete config.sh
    rm config.sh
    rm pkgfiles

    
    
    
    cp -R ./* /

    cd ../
    rm $(basename "$file")
    rm -rf $(basename $file .opm)
    

    echo "Installed $NAME"
}

# Function to uninstall
uninstall() {
    echo "Uninstalling: $file"
    
    # Check if the directory exists
    if [ -d "$DIR/Packages/$file" ]; then
        cd "$DIR/Packages/$file" || exit 1

        # Read pkgfiles and delete files listed in it
        while IFS= read -r line; do
            if [ -f "$line" ]; then
                rm "$line"
                echo "Deleted: $line"
            else
                echo "File not found: $line"
            fi
        done < pkgfiles

        # Return to the original directory
        cd "$DIR/Packages" || exit 1

        # Remove the directory
        rm -rf "$file"
        echo "Deleted directory: $DIR/$file"

        echo "Uninstall complete for $file"
    else
        echo "Directory not found: $DIR/Packages/$file"
    fi
}

# Check for the correct number of arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [install|uninstall] <file>/<name>"
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
