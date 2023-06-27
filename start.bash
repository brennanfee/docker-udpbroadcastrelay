#!/usr/bin/env bash
# Author: Brennan Fee
# License: MIT License

# Bash strict mode
([[ -n ${ZSH_EVAL_CONTEXT:-} && ${ZSH_EVAL_CONTEXT:-} =~ :file$ ]] \
  || [[ -n ${BASH_VERSION:-} ]] && (return 0 2> /dev/null)) && SOURCED=true || SOURCED=false
if ! ${SOURCED}; then
  set -o errexit  # same as set -e
  set -o nounset  # same as set -u
  set -o errtrace # same as set -E
  set -o pipefail
  set -o posix
  #set -o xtrace # same as set -x, turn on for debugging

  shopt -s inherit_errexit
  shopt -s extdebug
  IFS=$(printf '\n\t')
fi
# END Bash strict mode

function main() {
  local app="udpbroadcastrelay"
  echo "${app}: Starting up - $(date --rfc-3339=seconds)"
  echo "${app}: Path: ${PATH}"
  echo "${app}: Network interfaces - "
  ip a | grep -i "state up" | awk '{print $2 }'

  # Check for yq
  if [[ ! -x /usr/bin/yq ]]; then
    echo "${app}: ERROR - yq utility is not installed but required."
    exit 1
  fi

  # Check for data folder (should be a mapped volume)
  if [[ ! -d /data ]]; then
    echo "${app}: ERROR - /data folder or volume not mapped.  Did you map a volume?"
    exit 2
  fi

  # Check for our config file
  if [[ ! -f /data/${app}.yml ]]; then
    echo "${app} ERROR - ${app}.yml configuration file not found in /data folder."
    exit 3
  fi

  local index=0
  local flags=""
  while true; do
    local flags_next
    local next=$((index + 1))

    flags=$(/usr/bin/yq ".Listeners[${index}].Flags" /data/${app}.yml)
    flags_next=$(/usr/bin/yq ".Listeners[${next}].Flags" /data/${app}.yml)

    if [[ "${flags}" == "null" ]]; then
      echo "${app}: ERROR - Configuration error, flags read were blank."
      exit 4
    fi

    # Unwrap the flags, they come wrapped in quotes for some reason
    flags=$(sed -e 's/^"//' -e 's/"$//' <<< "${flags}")

    if [[ "${flags_next}" == "null" ]]; then
      # This is the last iteration, break out of the loop
      break
    else
      # Run the item and fork it to background
      echo "${app}: Flags for listener #${index} - ${flags}"
      echo "${app}: Starting listener #${index} - $(date --rfc-3339=seconds)"
      /srv/udpbroadcastrelay -f ${flags}
    fi

    index=${next}
  done

  # Now run the last item, but DO NOT fork
  echo "${app}: Flags for final listener #${index} - ${flags}"
  echo "${app}: Starting final listener #${index} - $(date --rfc-3339=seconds)"
  /srv/udpbroadcastrelay ${flags}
}

main "$@"
