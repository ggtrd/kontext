#!/bin/bash



# MIT License

# Copyright (c) 2025 Geoffrey Gontard

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




# Menu selectable with keyboard arrows
# Usage: menu <description> <selected choice> <list of choice>
menu() {
    local prompt="$1"
    local outvar="$2"
    shift
    shift

    local options=("$@") cur=0 count=${#options[@]} index=0
    local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes

    echo $prompt

    while true; do
        # list all options (option list is zero-based)
        index=0
        for o in "${options[@]}"; do
            if [ "$index" == "$cur" ]; then
                echo -e " >\e[7m$o\e[0m" # mark & highlight the current option
            else
                echo "  $o"
            fi
            ((index++))
        done
        read -s -n3 key               # wait for user to key in arrows or ENTER
        if [[ $key == $esc[A ]]; then # up arrow
            ((cur--))
            ((cur < 0)) && ((cur = 0))
        elif [[ $key == $esc[B ]]; then # down arrow
            ((cur++))
            ((cur >= count)) && ((cur = count - 1))
        elif [[ $key == "" ]]; then # nothing, i.e the read delimiter - ENTER
            break
        fi
        echo -en "\e[${count}A" # go up to the beginning to re-render
    done
    # export the selection to the requested output variable
    printf -v $outvar "${options[$cur]}"
}





# Create kubernetes context selectionnable menu
i=0
for context in "$(kubectl config get-contexts -o name)"; do
    selections[$i]=$context
    i=$(($i + 1))
done
menu "Contexts list:" selected_choice "${selections[@]}"


# Set kurbernetes context from selected list
kubectl config use-context $selected_choice




exit