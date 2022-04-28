#!/usr/bin/env bash
# User Defined Aliases

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
alias burp='brew update && brew outdated && brew outdated --cask && brew upgrade && brew upgrade --cask && brew cleanup'
alias sburp='sudo brew update && sudo brew outdated && sudo brew outdated --cask && sudo brew upgrade && sudo brew upgrade --cask && sudo brew cleanup'

# Environment
alias sz='source ~/.zshrc'
alias cpv='rsync -ah --info=progress2'
alias lt='gls --human-readable --size -1 -S -alh --classify'

# Security
alias gened='ssh-keygen -t ed25519 -a 100'
alias genrsa='ssh-keygen -t rsa -b 4096 -o -a 100'

# Overrides
alias l='exa -lahg'
