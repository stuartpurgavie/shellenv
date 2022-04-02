# User Environment Variables

# PATH Updates
# Brew can install things here so we want to ensure that it's in the PATH
export PATH="/usr/local/sbin:$PATH"
# GNU getopt builtin - needs highest precedence to override MacOS-provided binaries
export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"
# User controlled binary folder - takes lowest precedence
export PATH="$PATH:/Users/stuartpurgavie/bin"

export EDITOR='vim'

if [[ "${OSTYPE}" = darwin* ]]; then
  export AWS_ACCESS_KEY_ID="$(security find-generic-password -a ${USER} -s aws_dou_terraform_training_access -w)"
  export AWS_SECRET_ACCESS_KEY="$(security find-generic-password -a ${USER} -s aws_dou_terraform_training_secret -w)"
  export AWS_SESSION_TOKEN="$(security find-generic-password -a ${USER} -s aws_dou_terraform_training_session -w)"

  # Python Vault Onboarding Script
  export GL_TKN="$(security find-generic-password -a ${USER} -s tmo_gitlab_access_key -w)"

fi
# Tools
export LESS="--RAW-CONTROL-CHARS --quit-if-one-screen --no-init"

