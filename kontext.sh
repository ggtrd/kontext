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


# Keyboard keys
ARROW_UP="$(printf '\033[A')"
ARROW_DOWN="$(printf '\033[B')"

# Colors
NO_FORMAT='\033[0m'

BG_EXIT='\033[48;5;203m'
BG_EXIT_SELECTED='\033[48;5;160m'
BG_ORANGE='\033[48;5;208m'
BG_BLUE='\033[48;5;75m'

FG_ORANGE='\033[38;5;215m'
FG_BLACK='\033[38;5;232m'
FG_BLUE='\033[38;5;75m'

BG_SELECTED='\033[48;5;63m'
FG_SELECTED='\033[38;5;15m'


# Display log on the terminal
# Usage: display_log <severity> <message>
display_log() {
    local severity="$1"
    local message="$2"

    if [ "$severity" = 'warn' ]; then
        local severity_title="$BG_ORANGE$FG_BLACK WARN "
        local message_colors=" $FG_ORANGE"
    fi

    # if [ "$severity" = 'info' ]; then
    #     local severity_title="$BG_BLUE$FG_BLACK INFO "
    #     local message_colors=" $NO_FORMAT"
    # fi

    # will looks like the following, but with colors:
    #   WARN message
    #   INFO message
    printf "\n$severity_title$NO_FORMAT$message_colors$message$NO_FORMAT\n"
}


# Get the name of the CLI
# Usage: get_cli_name
get_cli_name() {
    echo "$0" | sed 's|.*/\(.*\)|\1|'
}


KUBECONFIG_FILE_HOME="$HOME/.kube/config"
if [ "$KUBECONFIG" = '~/.kube/config' ]; then
    display_log 'warn' "Current KUBECONFIG contains relative path '~/.kube/config' which can cause issues with kubectl. Unset KUBECONFIG or replace with absolute path $KUBECONFIG_FILE_HOME to avoid non-working contexts."
    KUBECONFIG="$KUBECONFIG_FILE_HOME"
fi


# Create selectable menu list
# Usage: menu "item1 item2 item3 etc..."
menu() {
    local option_exit="exit"
    local options="$1 $option_exit"
    local current=1
    local total="$(echo $options | wc -w)"

    # Print menu with selectables options
    # Usage: print_menu
    print_menu() {
        i=1
        for option in $options; do

            # exception for "exit" option
            if [ "$option" = "$option_exit" ]; then
                if [ "$i" -eq "$current" ]; then
                    printf " > $BG_EXIT_SELECTED$FG_SELECTED %s $NO_FORMAT\n" "$option"
                else
                    printf "   $BG_EXIT$FG_BLACK %s $NO_FORMAT\n" "$option"
                fi

            # standard display
            else
                if [ "$i" -eq "$current" ]; then
                    printf " > $BG_SELECTED$FG_SELECTED %s $NO_FORMAT\n" "$option"
                else
                    printf "   $NO_FORMAT %s $NO_FORMAT\n" "$option"
                fi

            fi
            i=$((i + 1))
        done
    }

    prepare_terminal() {
        # Ensure terminal is in right mode
        stty -echo -icanon

        # Hide terminal cursor
        printf "\033[?25l"
    }

    restore_terminal() {
        # Restore terminal
        stty echo icanon

        # Enable back terminal cursor
        printf "\033[?25h"
    }

    # Enable CTRL+C
    trap 'restore_terminal; exit' INT TERM EXIT

    prepare_terminal

    # Display a first time the menu
    print_menu

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

    restore_terminal

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
    # We don't test with -f because it can contains multiple files
    elif [ ! -z "$KUBECONFIG" ]; then
        local path="$KUBECONFIG"

    # Try to get kubeconfig from $KUBECONFIG_FILE_HOME
    elif [ -f "$KUBECONFIG_FILE_HOME" ]; then
        local path="$KUBECONFIG_FILE_HOME"

    fi

    echo $path
}


# Extract contexts names from a kubeconfig yaml file
# Usages:
#   - get_contexts
#   - get_contexts <kubeconfig_path>
get_contexts() {
    local kubeconfig_path="$1"

    # Try to get kubeconfig from path
    # Allow to read from file only if it's /home/$USER/.kube/config
    # - allow to browse the context quicker than with kubectl
    # - only for /home/$USER/.kube/config usage because kubectl might not be able to use the selected context depending on the local configuration
    if [ "$kubeconfig_path" = "$KUBECONFIG_FILE_HOME" ] && [ -f "$kubeconfig_path" ]; then
        awk '
            /^contexts:/ { in_section = 1; next }
            in_section && /^[a-zA-Z]/ { in_section = 0 }
            in_section && /name:/ {
                val = $2;
                gsub(/["'\'']/, "", val);
                print val
            }
        ' "$kubeconfig_path"

    # Fallback on kubectl
    else
        KUBECONFIG="$kubeconfig_path" kubectl config get-contexts -o name
    fi
}


# Set current context
# Usages:
#   - use_context
#   - use_context <kubeconfig_path>
use_context() {
    local kubeconfig_path="$1"

    # Trick to force kubectl write the context in the main file, even if it comes from another file
    # This is to avoid kubectl not find the kubeconfig file while the contexts have been listed and selected
    if [ -f "$KUBECONFIG_FILE_HOME" ]; then
        KUBECONFIG="$KUBECONFIG_FILE_HOME:$kubeconfig_path" kubectl config use-context "$SELECTED_CHOICE"

        # Display a warning in case of using a context from a --file kubeconfig
        if [ "$(echo $kubeconfig_path)" != "$(echo $KUBECONFIG_FILE_HOME)" ] && [ ! "$(echo $KUBECONFIG | grep $kubeconfig_path)" ]; then
            display_log 'warn' "Current context has switched to '$SELECTED_CHOICE', but the associated kubeconfig is not accessible by kubectl. You must add it to KUBECONFIG.\nCopy/paste the following line to add it:"
            echo "export KUBECONFIG="\$KUBECONFIG:$KUBECONFIG_FILE_HOME:$kubeconfig_path""
            echo ''
        fi

    else
        KUBECONFIG="$kubeconfig_path" kubectl config use-context "$SELECTED_CHOICE"
    fi
}


# Delete context and associated user & cluster in given kubeconfig file
# Usage: delete_context <context_name>
delete_context() {
    local context="$1"

    echo 'looking for context...'

    local context_json="$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$context')]}")"
    if [ -z "$context_json" ]; then
        echo "error: context '$context' not found"
        return
    fi

    get_cluster_from_context() {
        kubectl config view -o jsonpath="{.contexts[?(@.name=='$context')].context.cluster}"
    }

    get_user_from_context() {
        kubectl config view -o jsonpath="{.contexts[?(@.name=='$context')].context.user}"
    }

    local cluster="$(get_cluster_from_context)"
    local user="$(get_user_from_context)"

    printf '\ncontext found:\n'
    printf "  context: $FG_BLUE$context$NO_FORMAT\n"
    printf "  cluster: $FG_BLUE$cluster$NO_FORMAT\n"
    printf "  user:    $FG_BLUE$user$NO_FORMAT\n\n"

    read -p "delete context and its associated cluster/user ? [y/N] " confirmation
    if [ "$confirmation" = 'y' ]; then
        echo 'deleting...'
        kubectl config delete-cluster "$cluster"
        kubectl config delete-user "$user"
        kubectl config delete-context "$context"
    else
        echo 'aborted'
    fi
}


# Simple log message to display the selected kubeconfig file
# Usage:
#   - log_message_kubeconfig_source
#   - log_message_kubeconfig_source <kubeconfig_path>
log_message_kubeconfig_source() {
    local kubeconfig_path="$1"
    local log_message="    listing contexts from:"

    echo ''
    if [ ! -z "$KUBECONFIG" ]; then

        echo "$log_message $(printf "$FG_ORANGE%s$NO_FORMAT=$KUBECONFIG" 'KUBECONFIG')"

    elif [ ! -z "$kubeconfig_path" ]; then
        echo "$log_message $kubeconfig_path"

    else
        echo "$log_message <cannot display source>"
    fi
    echo ''
}


# Run the main menu & switch to selected context
# Usage: run_menu <kubeconfig_path>
run_menu() {
    local kubeconfig_path="$1"

    # Warn message in case of using --file/-f while KUBECONFIG exists
    if [ ! -z "$KUBECONFIG" ] && [ ! -z "$2" ]; then
        display_log 'warn' "KUBECONFIG env var is setted, the given kubeconfig path cannot be used"

        # Remove args because they contains kubeconfig path
        set --
    fi

    log_message_kubeconfig_source $kubeconfig_path

    contexts="$(get_contexts $kubeconfig_path)"
    menu "$(echo $contexts)"

    use_context $kubeconfig_path
}


# Offers differents options from args
case "$1" in
  -h|--help|help)
    echo ''
    echo " Quickly select Kubernetes context"
    echo " usages:"
    echo "  $(get_cli_name)                                       Select kube contexts from current kubeconfig."
    echo "  $(get_cli_name) <kubeconfig_file_path>                Same as -f, --file."
    echo "  $(get_cli_name) -f, --file <kubeconfig_file_path>     Select kube contexts from given kubeconfig file. Cannot works if KUBECONFIG env var exists."
    echo "  $(get_cli_name) -d, --delete <context>                Delete the given context and its associated cluster/user."
    echo "  $(get_cli_name) -h, --help                            Display this message."
    echo ''
    exit
    ;;

  -f|--file|file)
    kubeconfig_path="$(get_kubeconfig_best_path $2)"
    run_menu $kubeconfig_path
    ;;

  -d|--delete|delete)
    if [ -z "$2" ]; then
        echo 'error: missing context name\n--help for more informations'
        exit
    fi
    delete_context "$2"
    exit
    ;;

  '')
    kubeconfig_path="$(get_kubeconfig_best_path)"
    run_menu $kubeconfig_path
    ;;

  *)
    kubeconfig_path="$(get_kubeconfig_best_path $1)"
    run_menu $kubeconfig_path
    ;;
esac


exit
