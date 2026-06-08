# Kontext

Quickly manage Kubernetes contexts.

<div align="center">
	<img height="480px" alt="demo gif" src=".github/media/demo.gif">
	<br>
</div>

<br>

[kubectl](https://kubernetes.io/docs/reference/kubectl/) must be installed.

Kontext is POSIX compliant.

## Usage
* `switch` current the context from selectable menu
    ```
    kontext
    ```
    ```
    kontext -f <kubeconfig_file>
    ```

* `delete` a context and its associated cluster/user
    ```
    kontext -d <context_name>
    ```

* display help
    ```
    kontext --help
    ```

## Installation
### Install on current user
* Bash
    ```
    KONTEXT_CLI="/home/$USER/.kube/kontext.sh" \
        && curl https://raw.githubusercontent.com/ggtrd/kontext/refs/heads/main/kontext.sh -o $KONTEXT_CLI \
        && chmod +x $KONTEXT_CLI \
        && echo "alias kontext='$KONTEXT_CLI'" >> /home/$USER/.bashrc \
        && source /home/$USER/.bashrc
    ```
* Fish
    ```
    set -g KONTEXT_CLI "/home/$USER/.kube/kontext.sh" \
        && curl https://raw.githubusercontent.com/ggtrd/kontext/refs/heads/main/kontext.sh -o $KONTEXT_CLI \
        && chmod +x $KONTEXT_CLI \
        && echo "alias kontext '$KONTEXT_CLI'" >> /home/$USER/.config/fish/config.fish \
        && source /home/$USER/.config/fish/config.fish
    ```

### Use as a simple script
```
./kontext.sh
```


# License
This project is licensed under the MIT License. See the [LICENSE](https://github.com/ggtrd/kontext/blob/main/LICENSE.md) file for details.
