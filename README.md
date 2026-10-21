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
* `switch` the current context from selectable menu
    ```
    kontext
    ```
    ```
    kontext -f <kubeconfig_file>
    ```

* `add` a context to your existing kubeconfig
    ```
    kontext -a <new_context_file_path>
    ```

* `delete` a context and its associated cluster/user
    ```
    kontext -d <context_name>
    ```

* `search` a context while browsing list with `:` or `/`
    > More or less like the [k9s](https://k9scli.io/) search field
    ```
    kontext
    ```
    * either press `:` or `/` to start searching for a context
    * press `esc` to leave

* display help
    ```
    kontext --help
    ```

## Installation
### Install on current user
```
curl -s https://raw.githubusercontent.com/ggtrd/kontext/main/install.sh | sh
```


### Use as a simple script
```
./kontext.sh
```

## Customization
| Environment variables                   | Type      | Default
| ---                                     | ---       | ---
| `KONTEXT_PAGINATION_BUFFER`             | number    | `20`
| `KONTEXT_DISABLE_UPDATE_NOTIFICATION`   | boolean   | `false`

<br>

# License
This project is licensed under the MIT License. See the [LICENSE](https://github.com/ggtrd/kontext/blob/main/LICENSE.md) file for details.
