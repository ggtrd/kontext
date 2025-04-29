#!/bin/sh




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
    prompt="$1"
    outvar="$2"
    shift
    shift

    options="$@"
    options="$options exit" # Add "exit" as an option
    cur=0
    count=$(set -- $options; echo $#) # Count options
    index=0
    esc=$(printf "\033")             # Cache ESC as printf is POSIX-compliant

    # Handle CTRL-C (SIGINT)
    cleanup() {
        printf "\nMenu canceled by user.\n"
        stty sane # Restore terminal settings
        exit 1
    }
    trap cleanup INT

    echo "$prompt"

    while true; do
        # list all options (option list is zero-based)
        index=0
        for o in $options; do
            if [ "$index" = "$cur" ]; then
                if [ "$o" = "exit" ]; then
                    # Highlight "exit" in red background and inverted text when selected
                    printf " >\033[41;7m%s\033[0m\n" "$o"
                else
                    # Highlight current selection with inverted text
                    printf " >\033[7m%s\033[0m\n" "$o"
                fi
            else
                if [ "$o" = "exit" ]; then
                    # Display "exit" in red background when not selected
                    printf "  \033[41m%s\033[0m\n" "$o"
                else
                    # Display normal text for other options
                    echo "  $o"
                fi
            fi
            index=$((index + 1))
        done

        # Wait for user input
        key=""
        read_key() {
            # Read single keypress or sequence
            old_stty=$(stty -g) # Save current terminal settings
            stty raw -echo      # Set terminal to raw mode
            key=$(dd bs=1 count=1 2>/dev/null) # Read a single character
            stty "$old_stty"    # Restore terminal settings
        }

        read_key

        if [ "$key" = "$esc" ]; then
            # Handle arrow keys (multi-character sequences)
            read_key
            if [ "$key" = "[" ]; then
                read_key
                if [ "$key" = "A" ]; then # up arrow
                    cur=$((cur - 1))
                    [ "$cur" -lt 0 ] && cur=0
                elif [ "$key" = "B" ]; then # down arrow
                    cur=$((cur + 1))
                    [ "$cur" -ge "$count" ] && cur=$((count - 1))
                fi
            fi
        elif [ "$key" = "" ] || [ "$key" = "$(printf '\r')" ]; then # ENTER
            if [ "$cur" -eq $((count - 1)) ]; then
                # If "exit" is selected, exit the menu
                cleanup
            else
                break
            fi
        fi
        printf "\033[%sA" "$count" # go up to the beginning to re-render
    done

    # Export the selection to the requested output variable
    eval "$outvar=\$(echo $options | cut -d' ' -f$((cur + 1)))"

    # Reset the trap for SIGINT
    trap - INT
}




# Create kubernetes context selectable menu
contexts=$(kubectl config get-contexts -o name)
menu "Contexts list:" selected_choice $contexts




# Set Kubernetes context from selected list
kubectl config use-context "$selected_choice"




exit