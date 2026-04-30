# Kontext

Quickly set a Kubernetes context.

[kubectl](https://kubernetes.io/fr/docs/reference/kubectl/) must be installed.

Kontext is POSIX compliant.

## Usage

### Use as a simple script
```
./kontext.sh
```
### Install on current user

* Bash
    ```
    file="/home/$USER/.kube/kontext.sh" \
    && curl https://raw.githubusercontent.com/ggtrd/kontext/refs/heads/main/kontext.sh -o $file \
    && chmod +x $file \
    && echo "alias kontext='$file'" >> /home/$USER/.bashrc
    ```
* Fish
    ```
    set -g KONTEXT_SCRIPT "/home/$USER/.kube/kontext.sh" \
        && curl https://raw.githubusercontent.com/ggtrd/kontext/refs/heads/main/kontext.sh -o $KONTEXT_SCRIPT \
        && chmod +x $KONTEXT_SCRIPT \
        && echo "alias kontext '$KONTEXT_SCRIPT'" >> /home/$USER/.config/fish/config.fish \
        && source /home/$USER/.config/fish/config.fish
    ```
* run
    ```
    kontext
    ```

# License
This project is licensed under the MIT License. See the [LICENSE](https://github.com/ggtrd/kontext/blob/main/LICENSE.md) file for details.
