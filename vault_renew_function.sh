# Vault Token Renew Loop Function
# Recommend to call like: "hvtr &" AFTER you do normal auth & set VAULT_ADDR

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

function hvtr() {
  # Hashicorp Vault Token Renew
  # Check for presence of binaries in container
  # DO NOT USE WITH INITIAL ROOT TOKEN
  # Recommend to call like: "hvtr &"
  declare -a required_binaries=("vault" "jq")
  for bin in ${required_binaries[@]} ; do
    declare var=$( type ${bin} 2>&1 | grep --count --regexp="not found" )
    if [[ ${var} -ge 1 ]]; then
      echo "${bin} binary not available, terminating function" >&2
      return 10
    else
      #[[ ${v} -ge 1 ]] && echo "Binary ${bin} found!"
    fi
  done
  while true; do
    # First, Do a lookup-self using vault binary for validation and ttl
    declare resp=$(vault token lookup -format=json 2>&1)
    if [[ "$(echo ${resp} | grep 'Error making API request')" != "" ]]; then
      echo "No valid token in env; reauthenticate then call 'hvtr &' to start renewal loop" >&2
      return 1
      break
    fi
    declare -i ttl=$(echo ${resp} | jq -r '.data.ttl')
    if [[ "$(echo ${resp} | jq '.data.ttl')" == "0" ]]; then
      echo "TTL is 0 - this may be an initial root token - exiting" >&2
      return 2
      break
    fi
    declare resp=$(vault token renew -format=json 2>&1)
    if [[ "$(echo ${resp} | jq -r '.warnings')" != "null" ]]; then
      echo "Vault token no longer renewable; after $(displaytime ${ttl}) you will need to reauthenticate"
      break
    fi
    # Calculate 2/3 remaining TTL then sleep that long (next renew with 1/3 TTL remaining)
    declare -i num="${ttl}"; declare -i den=3; declare -i fac=2
    ((ans = ((num + (den / 2)) / den) * fac ))
    sleep ${ans}
  done
  return 0
}
