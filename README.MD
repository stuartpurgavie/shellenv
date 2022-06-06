# ShellEnv

I use zsh fairly extensively for general use, and bash for scripting. These scripts are what I source in `~/.zshrc`,
some functions however are written to be compatible in bash, and I use shellcheck to try and keep things POSIX
except in those cases where I really don't want to be bothered to find the POSIX way of constructing an
associative array or other features that are readily available in bash or zsh.

## Personal Use

This is simply what I use in my environment. I make no claims that it will be appropriate for anyone else, nor
do I claim that these should be community standards. I simply have the repo public so that I can pull it to anywhere
without authentication.

## Source

```shell
# Execute from where you have cloned this repo
cat << EOF >> ~/.zshrc
export SHELLENV=$(pwd)
source "\${SHELLENV}/variables.sh"
source "\${SHELLENV}/aliases.sh"
source "\${SHELLENV}/helpers.sh"
source "\${SHELLENV}/functions.sh"
EOF

```
