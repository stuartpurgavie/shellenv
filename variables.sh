#!/usr/bin/env bash
# User Environment Variables

# PATH Updates
# Brew can install things here so we want to ensure that it's in the PATH
export PATH="/usr/local/sbin:$PATH"
# GNU getopt builtin - needs highest precedence to override MacOS-provided binaries
export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"
# User controlled binary folder - takes lowest precedence
export PATH="$PATH:${HOME}/bin"
export PATH="${PATH}:${HOME}/go/bin"
# PIP Utilities
export PATH="${PATH}:${HOME}/.local/bin"

export EDITOR='vim'

export UPALL_CMD="lupall"

if [[ "${OSTYPE}" = darwin* ]]; then
  #AWS_ACCESS_KEY_ID=$(security find-generic-password -a "${USER}" -s aws_dou_terraform_training_access -w)
  #AWS_SECRET_ACCESS_KEY=$(security find-generic-password -a "${USER}" -s aws_dou_terraform_training_secret -w)
  #AWS_SESSION_TOKEN=$(security find-generic-password -a "${USER}" -s aws_dou_terraform_training_session -w)
  #export AWS_ACCESS_KEY_ID
  #export AWS_SECRET_ACCESS_KEY
  #export AWS_SESSION_TOKEN

  ## Python Vault Onboarding Script
  #GL_TKN=$(security find-generic-password -a "${USER}" -s tmo_gitlab_access_key -w)
  #export GL_TKN
  export UPALL_CMD="burp"
fi

# Tools
export WATCH_INTERVAL="5"
export LESS="--RAW-CONTROL-CHARS --quit-if-one-screen --no-init"
export GOPATH="${HOME}/go"
export VAULT_LICENSE="${SHELLENV}/vault.hclic"
# Rust Tools
export PATH="${PATH}:/${HOME}/.cargo/bin"

# Games
export POE_FILTER="/mnt/linux_programs/SteamLibrary/steamapps/compatdata/238960/pfx/drive_c/users/steamuser/Documents/My Games/Path of Exile"
export FF7R_USER="${HOME}/.steam/root/steamapps/compatdata/1462040/pfx/drive_c/users/steamuser/Documents/My Games/FINAL FANTASY VII REMAKE"
export FF7R_APP="${HOME}/.local/share/Steam/steamapps/common/FINAL FANTASY VII REMAKE/End/Binaries/Win64"
export FF7R_MOD="${HOME}/.local/share/Steam/steamapps/common/FINAL FANTASY VII REMAKE/End/Content/Paks/~mods"
export SATIS_SAVES="${HOME}/.steam/root/steamapps/compatdata/526870/pfx/drive_c/users/steamuser/AppData/Local/FactoryGame/Saved/SaveGames/76561198063842308"

# Linux
export EDITOR="vim"
export SYSTEMD_EDITOR="vim"

# Docker
export POD_DOCKER_HOST=unix:///run/user/${UID}/podman/podman.sock
export ARRFOLDER="${HOME}/repos/default/containers/sonarr"
