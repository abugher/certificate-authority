#!/bin/bash


function generate_ca_root() {
  if ! test -e "${ca_root_dir}"; then
    mkdir -p "${ca_root_dir}" \
      || fail $ERR_MKDIR "Failed to create directory:  ${ca_root_dir}"
    inform "Created directory:  ${ca_root_dir}"
  else
    debug "Directory exists:  ${ca_root_dir}"
  fi

  if ! test -e "${ca_root_newcerts}"; then
    mkdir -p "${ca_root_newcerts}" \
      || fail $ERR_MKDIR "Failed to create directory:  ${ca_root_newcerts}"
    inform "Created directory:  ${ca_root_newcerts}"
  else
    debug "Directory exists:  ${ca_root_newcerts}"
  fi

  if ! test -e "${sensitive}"; then
    fail $ERR_PREREQ "Failed to find sensitive directory:  ${sensitive}"
  else
    debug "Directory exists:  ${sensitive}"
  fi

  if ! test -e "${ca_root_sensitive_dir}"; then
    mkdir -p "${ca_root_sensitive_dir}" \
      || fail $ERR_MKDIR "Failed to create directory:  ${ca_root_sensitive_dir}"
    inform "Created directory:  ${ca_root_sensitive_dir}"
  else
    debug "Directory exists:  ${ca_root_sensitive_dir}"
  fi

  generate_conf "${ca_root_conf}" "${ca_root_conf_template}"

  if ! test -e "${ca_root_key}"; then
    rm -f "${ca_root_dir}/index.txt"{,.attr} \
      || fail $ERR_GENRSA "Failed to remove stale index files."
    touch "${ca_root_dir}/index.txt"{,.attr} \
      || fail $ERR_GENRSA "Failed to create index files."
    echo 1000 > "${ca_root_dir}/serial" \
      || fail $ERR_GENRSA "Failed to create 'serial'."
    rm -f "${ca_root_dir}/serial.old" \
      || fail $ERR_GENRSA "Failed to remove stale 'serial.old'."
    echo 1000 > "${ca_root_dir}/crlnumber" \
      || fail $ERR_GENRSA "Failed to create 'crlnumber'."

    { pass show "${ca_root_key_pass_path}"; yes; } \
      | openssl genrsa -passout stdin -aes256 -out "${ca_root_key}" 4096 \
      || fail $ERR_GENRSA "Failed to generate CA root key:  ${ca_root_key}"
    inform "Generated key:  ${ca_root_key}"
    remove_stale "${depend_on_ca_root_key[@]}"
  else
    debug "Key exists:  ${ca_root_key}"
  fi

  if ! test -e "${ca_root_cert}"; then
    { pass show "${ca_root_key_pass_path}"; yes; } \
      | openssl req -passin stdin -config "${ca_root_conf}" -key "${ca_root_key}" -new -x509 -days $(( 365 * 10 )) -sha256 -extensions v3_ca -out "${ca_root_cert}" \
      || fail $ERR_CERT "Failed to generate certificate:  ${ca_root_cert}"
    inform "Generated certificate:  ${ca_root_cert}"
    remove_stale "${depend_on_ca_root_cert[@]}"
  else
    debug "Certificate exists:  ${ca_root_cert}"
  fi

  if ! test -e "${ca_root_cert_der}"; then
    openssl x509 -outform der -in $ca_root_cert -out $ca_root_cert_der \
      || fail $ERR_CERT "Failed to generate certificate:  ${ca_root_cert_der}"
    inform "Generated certificate:  ${ca_root_cert_der}"
  else
    debug "Certificate exists:  ${ca_root_cert_der}"
  fi

  if ! test -e "${ca_root_crl}"; then
    { pass show "${ca_root_key_pass_path}"; yes; } \
      | openssl ca -passin stdin -config "${ca_root_conf}" -gencrl -crldays "${crldays}" -out "${ca_root_crl}" \
      || fail $ERR_CERT "Failed to generate revocation list:  ${ca_root_crl}"
    inform "Generated revocation list:  ${ca_root_crl}"
    remove_stale "${depend_on_ca_root_crl[@]}"
  else
    debug "Revocation list exists:  ${ca_root_crl}"
  fi

  if ! test -e "${ca_root_crl_der}"; then
    yes | openssl crl -in  "${ca_root_crl}" -outform der -out "${ca_root_crl_der}" \
      || fail $ERR_CERT "Failed to generate DER encoded revocation list:  ${ca_root_crl_der}"
    inform "Generated DER encoded revocation list:  ${ca_root_crl_der}"
    remove_stale "${depend_on_ca_root_crl_der[@]}"
  else
    debug "DER encoded revocation list exists:  ${ca_root_crl_der}"
  fi
}
