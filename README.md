# Kontext

Quickly set a Kubernetes context.

[kubectl](https://kubernetes.io/fr/docs/reference/kubectl/) must be installed.

Kontext is POSIX compliant.

## Usage

### Using as a simple script
```
./kontext.sh
```
### Installing on the current user
```
file="/home/$USER/.kube/kontext.sh" \
&& curl https://raw.githubusercontent.com/ggtrd/kontext/refs/heads/main/kontext.sh -o $file \
&& chmod +x $file \
&& echo "alias kontext='$file'" >> /home/$USER/.bashrc
```
```
kontext
```
# License
This project is licensed under the MIT License. See the [LICENSE](https://github.com/ggtrd/kontext/blob/main/LICENSE.md) file for details.