#!/bin/bash

DIR="/usr/opm"


list_packages() {
    echo "Listing contents of $DIR/Packages:"
    
    if [ -d "$DIR/Packages" ]; then
        ls "$DIR/Packages"
    else
        echo "Directory not found: $DIR/Packages"
    fi
}


# Function to install
install_local() {
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

    if [ "$(type -t PRE_INSTALL)" = 'function' ]; then
        PRE_INSTALL
    fi
    
    
    cp -R ./* /

    cd ../
    rm $(basename "$file")
    rm -rf $(basename $file .opm)

    if [ "$(type -t PRE_INSTALL)" = 'function' ]; then
        POST_INSTALL
    fi
    

    echo "Installed $NAME"
}

install_web() {
    echo "Installing package $file through web"

    echo "Checking if wget is installed."

    if ! command -v wget &> /dev/null; then
        echo "Error: wget is not installed. Please install wget."
        exit 1
    fi

    echo "Wget check complete, continuing installation."


}

# Function to uninstall
uninstall() {
    echo "Uninstalling: $file"
    
    # Check if the directory exists
    if [ -d "$DIR/Packages/$file" ]; then
        cd "$DIR/Packages/$file" || exit 1

	while IFS= read -r line; do
	    if [ -e "$line" ]; then
	        if [ -d "$line" ]; then
	            rm -r "$line"
	            echo "Deleted directory: $line"
	        elif [ -f "$line" ]; then
	            rm "$line"
	            echo "Deleted file: $line"
	        else
	            echo "Unknown type: $line"
	        fi
	    else
	        echo "Not found: $line"
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
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [list|install|uninstall] [file]/[package_name]"
    exit 1
fi

# Read the option
option=$1

# Case statement for options
case $option in
    list)
        if [ "$#" -ne 1 ]; then
            echo "Usage: $0 list"
            exit 1
        fi
        list_packages
        ;;
    install)
        if [ "$#" -ne 2 ]; then
            echo "Usage: $0 install <file>/<name>"
            exit 1
        fi
        file=$2

        # Check if the file ends with ".opm"
        if [[ "$file" == *.opm ]]; then
            install_local
        else
            install_web
        fi
        ;;
    uninstall)
        if [ "$#" -ne 2 ]; then
            echo "Usage: $0 uninstall <file>/<name>"
            exit 1
        fi
        file=$2
        uninstall
        ;;
    *)
        echo "Invalid option: $option. Please use 'list', 'install', or 'uninstall'."
        exit 1
        ;;
esac
