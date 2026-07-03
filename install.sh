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



# Stop script if missing dependency
required_commands="curl git"
for command in $required_commands; do
    if [ -z "$(command -v $command)" ]; then
        echo "error: required command not found: $command"
        exit
    fi
done



REPO='ggtrd/kontext'

REPO_URL="https://github.com/$REPO"
MAIN_NAME="$(echo $REPO | cut -d/ -f2)"

LATEST_TAG="$(git ls-remote --tags $REPO_URL | sed 's|.*tags/\(.*\)|\1|' | tail -n 1)"
ARTIFACT_URL="https://github.com/$REPO/archive/refs/tags/$LATEST_TAG.zip"

INSTALL_DIR="$HOME/.local/bin"
# CONFIG_DIR="$HOME/.config/$MAIN_NAME"
# VERSION_FILE="$CONFIG_DIR/$MAIN_NAME.version"



# Download $ARTIFACT_URL from release
# Usage: donwload_artifact
donwload_artifact() {
    local tmp_path="/tmp/$MAIN_NAME"
    local archive_path="$tmp_path.zip"

    # Clean /tmp before get new files
    rm -rf $tmp_path
    rm -rf $archive_path

    # Download and extract
    curl -L $ARTIFACT_URL > $archive_path
    unzip -d $tmp_path/ $archive_path
}



# Install given file (downloaded from $ARTIFACT_URL) to $PATH
# Usage: install_artifact <downloaded_zip_sub_path>
install_artifact() {
    local artifact_sub_path="$1"

    if [ ! -f "$artifact_sub_path" ]; then
        echo "error: missing artifact from $artifact_sub_path"
        return
    fi

    # Ensure dir exists
    mkdir -p $INSTALL_DIR

    # Install the artifact
    cp $artifact_sub_path "$INSTALL_DIR/$MAIN_NAME"
}



donwload_artifact                                                           # https://github.com/ggtrd/kontext/archive/refs/tags/tag.zip -> download + extract to /tmp/kontext/
install_artifact "/tmp/$MAIN_NAME/$MAIN_NAME-$LATEST_TAG/$MAIN_NAME.sh"     # /tmp/kontext/kontext-tag/kontext.sh -> copy to $HOME/.bin/local/kontext.sh



# Simple log message
echo ''
if [ "$(command -v $MAIN_NAME)" ]; then
    echo "sucessfully installed $MAIN_NAME !"
else
    echo "error: $MAIN_NAME not installed"
fi



exit
