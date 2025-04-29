# Kontext

Quickly set a kubernetes context.


kubectl must be installed.

## Usage
Using as a simple script
```
./kontext.sh
```

Installing on the current user
```
file="/home/$USER/.kube/kontext.sh" \
&& curl https://raw.githubusercontent.com/ggtrd/kontext/refs/heads/main/kontext.sh -o $file \
&& chmod +x $file \
&& echo "alias kontext='$file'" >> /home/$USER/.bashrc
```
```
kontext
```