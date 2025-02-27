#!/usr/bin/env bash
# User Defined Aliases
alias p10kup='printf "Updating powerlevel10k... " && git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull'

# BREW
alias brewp='brew pin'
alias brews='brew list -1'
alias brewsp='brew list --pinned'
alias bubo='brew update && brew outdated'
alias bubc='brew upgrade && brew cleanup'
alias bubu='bubo && bubc'
alias buf='brew upgrade --formula'
alias bcubo='brew update && brew outdated --cask'
alias bcubc='brew upgrade --cask && brew cleanup'
alias bcubu='bcubo && bcubc'
alias burp='bubo && brew outdated --cask && brew upgrade && brew upgrade --cask && brew cleanup && p10kup'
alias sburp='sudo brew update && sudo brew outdated && sudo brew outdated --cask && sudo brew upgrade && sudo brew upgrade --cask && sudo brew cleanup'
alias lupall='bubu && sudo dnf upgrade -y && sudo flatpak update -y && p10kup'
alias upall="\${UPALL_CMD}"

# Environment
alias szr='source ~/.zshrc'
alias cpv='rsync -ah --info=progress2'
alias lt='gls --human-readable --size -1 -S -alh --classify'

# Security
alias gened='ssh-keygen -t ed25519 -a 100'
alias genrsa='ssh-keygen -t rsa -b 4096 -o -a 100'

# Overrides
alias l='eza -ilahg'

# Applications
alias girens='flatpak run nl.g4d.Girens'

