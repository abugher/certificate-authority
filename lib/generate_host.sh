#!/bin/bash

function generate_host() {
  if ! test 'yes' = "${ca_only}"; then
    if ! test -e "${host_dir}"; then
      mkdir -p "${host_dir}" \
        || fail $ERR_MKDIR "Failed to create directory:  ${host_dir}"
      inform "Created directory:  ${host_dir}"
    else
      debug "Directory exists:  ${host_dir}"
    fi

    if ! test -e "${sensitive_host_dir}"; then
      mkdir -p "${sensitive_host_dir}" \
        || fail $ERR_MKDIR "Failed to create directory:  ${sensitive_host_dir}"
      inform "Created directory:  ${sensitive_host_dir}"
    else
      debug "Directory exists:  ${sensitive_host_dir}"
    fi

    if ! test -e "${host_conf}"; then
      cp "${host_conf_template}" "${host_conf}" \
        || fail $ERR_CONF "Failed to create conf:  ${host_conf}"

      sed -i 's/DOMAIN/'${domain}'/' "${host_conf}" \
        || fail $ERR_CONF "Failed to inject domain name:  ${domain}"
      debug "Injected domain name:  ${1}"

      sed -i 's/COMMON_NAME/'${1}'/' "${host_conf}" \
        || fail $ERR_CONF "Failed to inject common name:  ${1}"
      debug "Injected common name:  ${1}"

      sed -i 's#CA_DIR#'${certificate_authority}'#' "${host_conf}" \
        || fail $ERR_CONF "Failed to inject certificate authority directory:  ${certificate_authority}"
      debug "Injected certificate authority directory:  ${certificate_authority}"

      sed -i 's#CA_SDIR#'${sensitive}'#' "${host_conf}" \
        || fail $ERR_CONF "Failed to inject sensitive certificate authority directory:  ${sensitive}"
      debug "Injected certificate sensitive authority directory:  ${sensitive}"

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
      inform "Generated conf:  ${host_conf}"
      remove_stale "${depend_on_host_conf[@]}"
    else
      debug "Conf exists:  ${host_conf}"
    fi

    if ! test -e "${host_key}"; then
        openssl genrsa -out "${host_key}" 4096 \
        || fail $ERR_GENRSA "Failed to generate host key:  ${host_key}"
      inform "Generated host key:  ${host_key}"
      remove_stale "${depend_on_host_key[@]}"
    else
      debug "Key exists:  ${host_key}"
    fi

    if ! test -e "${host_csr}"; then
      openssl req -config "${host_conf}" -key "${host_key}" -new -sha256 -out "${host_csr}" \
        || fail $ERR_CSR "Failed to generate CSR:  ${host_csr}"
      inform "Generated CSR:  ${host_csr}"
      remove_stale "${depend_on_host_csr[@]}"
    else
      debug "CSR exists:  ${host_csr}"
    fi

    if ! test -e "${host_cert}"; then
      { pass show "${ca_intermediate_key_pass_path}"; yes; } \
        | openssl ca --passin stdin -config "${ca_intermediate_conf}" -extensions v3_req -days $(( 365 * 10 )) -notext -md sha256 -in "${host_csr}" -out "${host_cert}" \
        || fail $ERR_CERT "Failed to generate certificate:  ${host_cert}"
      inform "Generated certificate:  ${host_cert}"
      remove_stale "${depend_on_host_cert[@]}"
    else
      debug "Certificate exists:  ${host_cert}"
    fi

    if ! test -e "${cert_chain}"; then
      cat "${host_cert}" "${ca_intermediate_cert}" "${ca_root_cert}" > "${cert_chain}" \
        || fail $ERR_CHAIN "Failed to create certificate chain:  ${cert_chain}"
      inform "Created certificate chain:  ${cert_chain}"
      remove_stale "${depend_on_cert_chain[@]}"
    else
      debug "Certificate chain exists:  ${cert_chain}"
    fi

    if ! test -e "${host_crl}"; then
      { pass show "${ca_intermediate_key_pass_path}"; yes; } \
        | openssl ca -passin stdin -config "${host_conf}" -gencrl -crldays "${crldays}" -out "${host_crl}" \
        || fail $ERR_CERT "Failed to generate revocation list:  ${host_crl}"
      inform "Generated revocation list:  ${host_crl}"
      remove_stale "${depend_on_host_crl[@]}"
    else
      debug "Revocation list exists:  ${host_crl}"
    fi

    if ! test -e "${host_crl_der}"; then
      openssl crl -in  "${host_crl}" -outform der -out "${host_crl_der}" \
        || fail $ERR_CERT "Failed to generate DER encoded revocation list:  ${ca_host_crl_der}"
      inform "Generated DER encoded revocation list:  ${host_crl_der}"
      remove_stale "${depend_on_host_crl_der[@]}"
    else
      debug "DER encoded revocation list exists:  ${host_crl}"
    fi
  fi
}
