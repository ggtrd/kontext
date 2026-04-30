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


# Create selectable menu list
# Usage: menu "item1 item2 item3 etc..."
menu() {
    local option_exit="exit"
    local options="$1 $option_exit"
    local current=1
    local total="$(echo $options | wc -w)"

    # Keyboard keys
    local ARROW_UP="$(printf '\033[A')"
    local ARROW_DOWN="$(printf '\033[B')"

    # Print menu with selectables options
    # Usage: print_menu
    print_menu() {
        # Colors
        local NO_FORMAT='\033[0m'
        local BG_EXIT='\033[48;5;203m'
        local FG_EXIT='\033[38;5;232m'
        local BG_EXIT_SELECTED='\033[48;5;160m'
        local BG_SELECTED='\033[48;5;63m'
        local FG_SELECTED='\033[38;5;15m'

        i=1
        for option in $options; do
            if [ "$option" = "$option_exit" ]; then
                if [ "$i" -eq "$current" ]; then
                    printf " > $BG_EXIT_SELECTED$FG_SELECTED %s $NO_FORMAT\n" "$option"
                else
                    printf "   $BG_EXIT$FG_EXIT %s $NO_FORMAT\n" "$option"
                fi
            else
                if [ "$i" -eq "$current" ]; then
                    printf " > $BG_SELECTED$FG_SELECTED %s $NO_FORMAT\n" "$option"
                else
                    printf "   $BG_RED$FG_BLACK %s $NO_FORMAT\n" "$option"
                fi
            fi
            i=$((i + 1))
        done
    }

    # Display a first time the menu
    print_menu

    # Ensure terminal is in right mode
    stty -echo -icanon

    # Enable CTRL+C
    trap 'stty echo icanon; printf "\033[?25h"; exit' INT TERM EXIT

    # Hide terminal cursor
    printf "\033[?25l"

    # Start the program
    while true; do
        # Read keyboards entries
        local key="$(dd bs=3 count=1 2>/dev/null)"
        case "$key" in
            "$ARROW_UP")    [ "$current" -gt 1 ] && current=$((current - 1)) ;;
            "$ARROW_DOWN")  [ "$current" -lt "$total" ] && current=$((current + 1)) ;;
            "")             break ;;
        esac

        # Ensure the list is well-displayed in good shape
        printf "\033[%dA" "$total"
        print_menu
    done

    # Restore terminal
    stty echo icanon

    # Enable back terminal cursor
    printf "\033[?25h"

    SELECTED_CHOICE="$(echo $options | cut -d ' ' -f $current)"
    if [ "$SELECTED_CHOICE" = "$option_exit" ]; then
        echo "exited"
        exit
    else
        echo "selected: $SELECTED_CHOICE"
    fi
}


# Look for the right kubeconfig to use
# Usages: get_kubeconfig_best_path <kubeconfig_given_path>
get_kubeconfig_best_path() {
    local kubeconfig_given_path="$1"

    # Try to get kubeconfig from arguments (file path)
    if [ -f "$kubeconfig_given_path" ]; then
        local path="$kubeconfig_given_path"

    # Try to get kubeconfig from env var $KUBECONFIG
    elif [ -f "$KUBECONFIG" ]; then
        local path="$KUBECONFIG"

    # Try to get kubeconfig from $HOME/.kube/config
    elif [ -f "$HOME/.kube/config" ]; then
        local path="$HOME/.kube/config"
    fi

    echo $path
}


# Extract contexts names from a kubeconfig yaml file
# Usages:
#   - get_contexts
#   - get_contexts <kubeconfig_path>
get_contexts() {
    local kubeconfig_path="$(get_kubeconfig_best_path $1)"

    # Try to get kubeconfig from path
    if [ -f "$kubeconfig_path" ]; then
        cat "$kubeconfig_path" | grep -A99 contexts: | grep -B99 context: | grep 'name:' | sed 's|.*:||' | sed 's| ||'

    # Fallback on kubectl
    else
        kubectl config get-contexts -o name
    fi
}


# Set current context
# Usages:
#   - use_context
#   - use_context <kubeconfig_path>
use_context() {
    local kubeconfig_path="$(get_kubeconfig_best_path $1)"

    if [ -f "$kubeconfig_path" ]; then
        kubectl --kubeconfig ""$kubeconfig_path"" config use-context "$SELECTED_CHOICE"
    else
        kubectl config use-context "$SELECTED_CHOICE"
    fi
}


# Offers differents options from args
case "$1" in
  -h|--help|help)
    echo ''
    echo " Quickly select Kubernetes context"
    echo " usages:"
    echo "  $0                                       Select kube contexts from default kubeconfig file"
    echo "  $0 <kubeconfig_file_path>                Same as -f, --file"
    echo "  $0 -f, --file <kubeconfig_file_path>     Select kube contexts from given kubeconfig file"
    echo "  $0 -h, --help                            Display this message"
    echo ''
    ;;

  -f|--file|file)
    contexts="$(get_contexts $2)"
    menu "$(echo $contexts)"
    use_context $2
    ;;

#   '')
#     contexts="$(get_contexts)"
#     menu "$(echo $contexts)"
#     use_context
#     ;;

  *)
    contexts="$(get_contexts $@)"
    menu "$(echo $contexts)"
    use_context $@
    ;;
esac


exit
