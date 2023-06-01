#!/bin/bash

function generate_host() {
  if ! test -e "${host_dir}"; then
    mkdir -p "${host_dir}" \
      || fail $ERR_MKDIR "Failed to create directory:  ${host_dir}"
    inform "Created directory:  ${host_dir}"
  else
    debug "Directory exists:  ${host_dir}"
  fi

  if ! test -e "${sensitive-host_dir}"; then
    mkdir -p "${sensitive-host_dir}" \
      || fail $ERR_MKDIR "Failed to create directory:  ${sensitive-host_dir}"
    inform "Created directory:  ${sensitive-host_dir}"
  else
    debug "Directory exists:  ${sensitive-host_dir}"
  fi

  generate_conf "${host_conf}" "${host_conf_template}" "${@}"

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
}
