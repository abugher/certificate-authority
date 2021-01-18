#!/bin/bash


function generate_conf() {
  if test '2' -gt "${#}"; then
    debug "Received ${#} arguments."
    i=0
    for arg in "${@}"; do
      i="$(( i + 1 ))"
      debug "arg${i}:  ${arg}"
    done
    fail $ERR_USAGE "Specify one configuration file and one template, then short hostnames."
  fi
  conf="${1}"
  shift
  template="${2}"
  shift

  if ! test -e "${conf}"; then
    cp "${template}" "${conf}" \
      || fail $ERR_CONF "Failed to create conf:  ${conf}"
    sed -i 's/DOMAIN/'${domain}'/' "${conf}" \
      || fail $ERR_CONF "Failed to inject domain name:  ${domain}"
    debug "Injected domain name:  ${1}"
    sed -i 's#CA_DIR#'${certificate_authority}'#' "${conf}" \
      || fail $ERR_CONF "Failed to inject certificate authority directory:  ${certificate_authority}"
    debug "Injected certificate authority directory:  ${certificate_authority}"
    sed -i 's#CA_SDIR#'${sensitive}'#' "${conf}" \
      || fail $ERR_CONF "Failed to inject sensitive certificate authority directory:  ${sensitive}"
    debug "Injected certificate sensitive authority directory:  ${sensitive}"

    if test 'no' = "${ca_only}"; then
      n=1
      for shortname in "${@}"; do
        if echo "${shortname}" | grep -q '\.'; then
          fail $ERR_CONF "No dots in short names."
        fi
        echo -e "DNS.${n}                   = ${shortname}.${domain}" \
          >> "${host_conf}" \
          || fail $ERR_CONF "Failed to append configuration for short name:  ${shortname}"
        debug "Appended short name:  ${shortname}"
        let n++
        if echo "${shortname}" | grep -q '^dmz$'; then
          echo -e "DNS.${n}                   = ${domain}" \
            >> "${host_conf}" \
            || fail $ERR_CONF "Failed to append configuration for root domain name:  ${domain}"
          debug "Appended root domain name:  ${domain}"
          let n++
        fi
      done
    fi
    inform "Generated conf:  ${conf}"
    remove_stale "${depend_on_conf[@]}"
  else
    debug "Conf exists:  ${conf}"
  fi
}
