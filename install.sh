#!/bin/sh

# MIT License

# Copyright (c) 2026 Geoffrey Gontard

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



# Simple script to manage program installation & updates
# script usage: export INSTALLER_SOURCE_FILE=<local/https sources> && ./install.sh


# Stop script if missing dependency
required_commands="curl git"
for command in $required_commands; do
    if [ -z "$(command -v $command)" ]; then
        echo "error: required command not found: $command"
        exit
    fi
done


SOURCE_FILE="$INSTALLER_SOURCE_FILE"
SOURCE_NAME="$(basename "$SOURCE_FILE")"
CMD_NAME="$(echo $SOURCE_NAME | cut -d'.' -f1)"

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/$CMD_NAME"
VERSION_FILE="$CONFIG_DIR/$CMD_NAME.version"

# Stop script if missing SOURCE_FILE
if [ -z "$SOURCE_FILE" ]; then
    echo "error: missing SOURCE_FILE"
    echo "$0 --help"
    exit
fi


# Create a structured version file (YAML based)
# Usage: create_version_file
create_version_file() {
    mkdir -p "$CONFIG_DIR"

    # Case https://raw.githubusercontent.com/$repo/refs/tags/$tag/FILE
    if [ "$(echo $SOURCE_FILE) | grep 'https://raw.githubusercontent.com'" ]; then
        local repo="$(echo $SOURCE_FILE | cut -d'/' -f4-5)"
        local tag="$(echo $SOURCE_FILE | cut -d'/' -f8)"

    # Case https://github.com/$repo/archive/refs/tags/$tag.zip
    elif [ "$(echo $SOURCE_FILE) | grep 'https://github.com'" ]; then
        local repo="$(echo $SOURCE_FILE | cut -d'/' -f4-5)"
        local tag="$(echo $SOURCE_FILE | cut -d'/' -f9)"

    ## Others cases
    # if [ "$(echo $SOURCE_FILE) | grep 'CASE_PLACEHOLDER'" ]; then
    #     local repo="$(echo $SOURCE_FILE | CASE_PLACEHOLDER)"
    #     local tag="$(echo $SOURCE_FILE | CASE_PLACEHOLDER)"

    else
        local repo='unknown'
        local tag='unknown'
    fi

    # Write the file
    echo "repo: $repo" > $VERSION_FILE
    echo "tag: $tag" >> $VERSION_FILE
}


# Install the program
# > create dedicated config folder
# > create .version file in the config folder
# > add executable to PATH
# Usage: install
install() {
    mkdir -p "$INSTALL_DIR"

    # Install the program
    # Detect if sources are local or HTTP/S
    if [ "$(echo $SOURCE_FILE | grep 'http' | grep '://')" ]; then
        curl -sk $SOURCE_FILE -o $INSTALL_DIR/$SOURCE_NAME
    else
        cp $SOURCE_FILE $INSTALL_DIR/$SOURCE_NAME
    fi

    mv $INSTALL_DIR/$SOURCE_NAME $INSTALL_DIR/$CMD_NAME

    chmod +x $INSTALL_DIR/$CMD_NAME
}


# # Check for updates of the program
# # Usage: check_updates_from_github
# check_updates_from_github() {
#     local repo="cat $VERSION_FILE | grep 'repo:' | cut -d' ' -f2"
#     local tag="cat $VERSION_FILE | grep 'tag:' | cut -d' ' -f2"
#     if [ -z "$repo" ] || [ -z "$tag" ]; then
#         echo "error: unknown repo or tag from $VERSION_FILE"
#         return
#     fi

#     local tag_available="$(git ls-remote --tags https://github.com/$repo.git | sed 's|.*/\(.*\)|\1|')"
#     if [ "$(echo $tag)" = "$(echo $tag_available)" ]; then
#         echo 'already up-to-date'
#     else
#         echo "found an update to version '$tag_available'"
#     fi
# }


install
create_version_file
# check_updates_from_github

exit
