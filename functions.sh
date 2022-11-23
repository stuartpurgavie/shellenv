#!/usr/bin/env bash
# User Defined Functions

source "${SHELLENV}/getopts_long.sh"

echoerr() { printf "%s\n" "$*" >&2; }

function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%dd' $D
  (( $H > 0 )) && printf '%dh' $H
  (( $M > 0 )) && printf '%dm' $M
  #(( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%ds\n' $S
}

# Vault Shorthand Functions
function svenv() {
    if [ $# -eq 0 ]; then
        echo "call with a single digit as an argument, like so:"
        echo "svenv 1"
        return 1
    fi
    case $1 in
        ''|*[!0-9]*) echo "not a number" ; return 1 ;;
        0) echo "Setting to local development" ; export VAULT_ADDR="http://127.0.0.1:8200" ;;
        1) echo "Setting to T-Mobile TST" ; export VAULT_ADDR="https://vault-tst.npe-services.t-mobile.com/" ;;
        2) echo "Setting to T-Mobile NPE" ; export VAULT_ADDR="https://vault-dev.npe-services.t-mobile.com/" ;;
        *) echo "not implemented" ; return 1 ;;
    esac

    return 0
}

function hv() {
    # Requires: git, jq, vault
    # Call like: hv sw local dev
    # Call like: hv log local dev
    # Updating the following hashtable enables the rest of the function.
    # The key in the hashtable should be two strings delimited by a hyphen
    # First string should be a "name" or "group" of some kind simply to group your instances
    # Second string is an environment within the group
    declare -A envs=(
        [local-dev]="http://127.0.0.1:8200"
        [lcl-dev]="http://127.0.0.1:8200"
        [tmo-tst]="https://vault-tst.npe-services.t-mobile.com"
        [tmo-dev]="https://vault-dev.npe-services.t-mobile.com"
        [tmo-npe]="https://vault.npe.t-mobile.com"
        [tmo-npeaws]="https://vault-dev.npe-services.t-mobile.com"
        [tmo-npepol]="https://vault.npe.pol.t-mobile.com"
        [tmo-prd]="https://vault.prod.t-mobile.com"
        [tmo-prdaws]="https://vault.prod-services.t-mobile.com"
        [tmo-prdpol]="https://vault.prod.pol.t-mobile.com"
        #[tmo-prd]=""
    )
    declare -a prefix=( $(for i in ${(k)envs}; do echo "${i}" | cut -d'-' -f1; done | sort -u) )
    declare -a suffix=( $(for i in ${(k)envs}; do echo "${i}" | cut -d'-' -f2; done | sort -u) )
    if [[ "${3:-}" == "" ]]; then echo "hv needs three arguments" && return 1; fi
    if [[ ! " ${prefix[*]} " =~ " ${2} " && "fmt" != "${1}" ]] ; then echo "name ${2} not implemented" && return 1; fi
    if [[ ! " ${suffix[*]} " =~ " ${3} " && "fmt" != "${1}" ]] ; then echo "env ${3} not implemented" && return 1; fi
    declare env="${2}-${3}"
    if [[ "${envs[${env}]:-}" == "" && "fmt" != "${1}" ]]; then
        echo "Need to configure ${env} in function definition" >&2 && return 1
    fi
    
    case $1 in
        sw)
            #export VAULT_TOKEN=$(security find-generic-password -a ${USER} -s vault_token_${2}_${3} -w)
            #if not exist; warn user to run `hv log ${2} ${3}` and continue
            #if exist; verify ttl of existing token, print ttl, extra warn message if less than 3600 remain
            echo "Switching to ${2} environment ${3}..."
            export VAULT_ADDR="${envs[${env}]}" && echo "Success! Set VAULT_ADDR to ${envs[${env}]}"
        ;;
        log)
            declare push="${VAULT_ADDR}"
            export VAULT_ADDR="${envs[${env}]}" && echo "Set VAULT_ADDR to ${envs[${env}]}"

            security find-generic-password -a ${USER} -s vault_token_${2}_${3}
            if [[ ${?} == 44 ]]; then
                #ensure correct env, login, set VAULT_TOKEN env var, add-generic-pw
                echo "Keychain not initialized, setting bogus value to start"
                security add-generic-password -a ${USER} -s vault_token_${2}_${3} -w "s.123456789012345678901234"
            fi
            declare keychain="$(security find-generic-password -a ${USER} -s vault_token_${2}_${3} -w)"
            export VAULT_TOKEN="${keychain}"
            declare resp=$(vault token lookup -format=json 2>&1)
            while [[ "$(echo ${resp} | grep 'Error making API request')" != "" || "$(echo ${resp} | grep 'Error looking up token')" != "" ]]; do
                echo "Token invalid; present new token" >&2
                while [[ -z "${secret:-}" || "${secret:-}" == "" ]]; do
                    IFS= read -rs "secret?Please enter Vault token: "
                done
                export VAULT_TOKEN="${secret}"
                declare resp=$(vault token lookup -format=json 2>&1)
            done

            declare -i ttl=`echo ${resp} | jq -r '.data.ttl' 2>&1`
            declare resp=$(vault token renew -format=json 2>&1)
            if [[ "$(echo ${resp} | jq -r '.warnings')" != "null" && "$(echo ${resp} | jq -r '.warnings[]')" =~ "exceeded the effective max_ttl" ]]; then
              echo "Vault token no longer renewable; after $(displaytime ${ttl}) you will need to reauthenticate"
            fi
            if [[ ${ttl} -lt $((60 * 60 * 24)) ]]; then echo "WARNINGToken TTL less than a day. Recommend hvtr &"; fi
            
            if [[ "${secret:-}" != "${keychain}" ]]; then
                security delete-generic-password -a ${USER} -s vault_token_${2}_${3}
                security add-generic-password -a ${USER} -s vault_token_${2}_${3} -w ${VAULT_TOKEN}
            fi
            #if exists; do vault token lookup on token, check ttl, prompt user to use existing or login new
            #if user prompt login new; delete current generic pw, follow 'if not exist' logic
            #if user prompt use existing; do nothing
            #security delete-generic-password -a ${USER} -s vault_token_${2}_${3}
            #security add-generic-password -a ${USER} -s vault_token_${2}_${3} -w ${VAULT_TOKEN}
            echo "Returning to original VAULT_ADDR..."
            export VAULT_ADDR="${push}"
        ;;
        fmt)
            echo "Recursive format requested..."
            if [[ ! "$(git rev-parse --is-inside-work-tree)" == "true" ]] ; then
                echo "Restricted to within a single repository" && return 1
            fi
            if [[ ! "${2}" == "ext" ]] ; then echo "Not Implemented - ${2} - use 'ext' instead" && return 1 ; fi
            if [[ ! "${3}" =~ '^\..*' ]] ; then echo "Third argument should be an extension prefixed with a dot" && return 1 ; fi
            declare -a files=("$(find . -type f -name \"*${3}\" | tr '\n' ' ')")
            for f in ${files[@]}; do vault policy fmt ${f} ; done
        ;;
        *)
            echo "Not Implemented: $1"
            return 1
        ;;
    esac
    return 0
}

# Alias Functions
function gpg() {
    if [[ $@ == "-K" ]]; then
        echo "Alias override: gpg --list-secret-keys --with-subkey-fingerprints --keyid-format long"
        command gpg --list-secret-keys --with-subkey-fingerprints --keyid-format long
    elif [[ $@ == "--gen-key" ]]; then
        echo "Alias override: gpg --expert --full-gen-key"
        command gpg --expert --full-gen-key
    else
        command gpg "$@"
    fi
}

function count() {
    if [[ $@ == "-r" ]]; then
        echo "Counting Files, including in subdirectories, excluding directories themselves"
        command find . -type f | wc -l
    else
        echo "Counting files and folders in current directory only (exclude '.' and '..' and subdirectories)"
        command ls -A1 | wc -l
    fi
}

function cl() {
    # Function 'cl' first 'c'hanges directory then 'l'ists the directory contents
    DIR="$*";
    # if no DIR given, go home
    if [ $# -lt 1 ]; then
        DIR=$HOME;
    fi;
    builtin cd "${DIR}" && \
    # use your preferred ls command
    if type l > /dev/null 2>&1 ; then
      l
    elif type exa > /dev/null 2>&1 ; then
      exa -lahg
    elif type gls > /dev/null 2>&1 ; then
      gls -alh --color=auto
    else
      ls -alh --colour=auto
    fi
}

function git() {
    typeset -A client
    case $1 in
        tmobile | tmo)
            client[jira]="TEQSE2"
            client[gpg]="FBD7E3FB7060FF348863BFE2C5E309D3047D6489"
            client[email]="stuart.purgavie1@t-mobile.com"
            client[ssh]="tmo"
        ;;
        digitalonus | dou)
            client[jira]="DEVON"
            client[gpg]="F38931F996ECE696B88FBEF4B54182833B82405B"
            client[email]="stuart.purgavie@digitalonus.com"
            client[ssh]="dou"
        ;;
        default | def)
            client[jira]="CLIP"
            client[gpg]="6AD861E9D496B34FB41EC558FCAA9A536B5B4387"
            client[email]="stuartpurgavie@uniqueservice.ca"
            client[ssh]="def"
        ;;
        *)
            command git "$@"
            return $?
        ;;
    esac
    case $2 in
        clone)
            client[uri]=$(echo "${3}" | sed -e "s/git@\(.*\)\.com:/git@\1.com-${client[ssh]}:/g")
            command git clone \
                --config user.jira="${client[jira]}"\
                --config user.signingkey="${client[gpg]}"\
                --config user.email="${client[email]}"\
                ${client[uri]} || return $?
            cd "$(basename "${3}" .git)" || return 1
            main=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
            command git config user.main "${main}"
            cd ..
        ;;
        config)
            command git config user.jira       ${client[jira]}  || return $?
            command git config user.email      ${client[email]} || return $?
            command git config user.signingkey ${client[gpg]}   || return $?
            main=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
            command git config user.main "${main}"
        ;;
        *)
            echoerr "subcommand not implemented"
            return 1
        ;;
    esac
    return 0
}

function hvfmt() {
    for f in $(find . -type f -name "*.acl" | tr '\n' ' '); do vault policy fmt "${f}" ; done
}

function htfmt() {
    terraform fmt -recursive
}

currentshell() {
    ps -o comm= -p $$
}

function hvtoken() {
    case $(currentshell) in
    zsh)
        IFS= read -rs "VAULT_TOKEN?Please enter client token: "
        printf "\n"
    ;;
    bash)
        IFS= read -rs -p "Please enter client token: " VAULT_TOKEN
        printf "\n"
    ;;
    *)
        echoerr "shell $(currentshell) not supported"
        return 1
    ;;
    esac
    export VAULT_TOKEN
}

function keybase_hack() {
    /opt/keybase/Keybase --disable-gpu-sandbox &
    keybase_pid=$!
}

function keybase_close() {
    kill -9 ${keybase_pid}
}

function find_hardlinks() {
    find "${1}" -xdev \! -type d -links +1 -printf '%6D %10i %p\n' |
      sort -n | uniq -w 42 --all-repeated=separate
}

function msch() {
    folders=("/mnt/Linux_Storage/SortedMedia/TVShows")
    for folder in ${folders[@]}; do
        sudo chown -R seraphic:mediaserver "${folder}"
        chmod -R 775 "${folder}"
    done
}
