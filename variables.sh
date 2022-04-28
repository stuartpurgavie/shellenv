#!/usr/bin/env bash
# User Environment Variables

# PATH Updates
# Brew can install things here so we want to ensure that it's in the PATH
export PATH="/usr/local/sbin:$PATH"
# GNU getopt builtin - needs highest precedence to override MacOS-provided binaries
export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"
# User controlled binary folder - takes lowest precedence
export PATH="$PATH:/Users/stuartpurgavie/bin"
export PATH="$PATH:/home/seraphic/bin"

export EDITOR='vim'

if [[ "${OSTYPE}" = darwin* ]]; then
  AWS_ACCESS_KEY_ID=$(security find-generic-password -a "${USER}" -s aws_dou_terraform_training_access -w)
  AWS_SECRET_ACCESS_KEY=$(security find-generic-password -a "${USER}" -s aws_dou_terraform_training_secret -w)
  AWS_SESSION_TOKEN=$(security find-generic-password -a "${USER}" -s aws_dou_terraform_training_session -w)
  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_SESSION_TOKEN

  # Python Vault Onboarding Script
  GL_TKN=$(security find-generic-password -a "${USER}" -s tmo_gitlab_access_key -w)
  export GL_TKN

fi
# Tools
export LESS="--RAW-CONTROL-CHARS --quit-if-one-screen --no-init"

# Games
export POE_FILTER="${HOME}/.steam/root/steamapps/compatdata/238960/pfx/drive_c/users/steamuser/My Documents/My Games/Path of Exile"

