#!/bin/bash

function generate_ca_intermediate() {
  if ! test -e "${ca_intermediate_dir}"; then
    mkdir -p "${ca_intermediate_dir}" \
      || fail $ERR_MKDIR "Failed to create directory:  ${ca_intermediate_dir}"
    inform "Created directory:  ${ca_intermediate_dir}"
  else
    debug "Directory exists:  ${ca_intermediate_dir}"
  fi

  if ! test -e "${ca_intermediate_newcerts}"; then
    mkdir -p "${ca_intermediate_newcerts}" \
      || fail $ERR_MKDIR "Failed to create directory:  ${ca_intermediate_newcerts}"
    inform "Created directory:  ${ca_intermediate_newcerts}"
  else
    debug "Directory exists:  ${ca_intermediate_newcerts}"
  fi

  if ! test -e "${ca_intermediate_sensitive_dir}"; then
    mkdir -p "${ca_intermediate_sensitive_dir}" \
      || fail $ERR_MKDIR "Failed to create directory:  ${ca_intermediate_sensitive_dir}"
    inform "Created directory:  ${ca_intermediate_sensitive_dir}"
  else
    debug "Directory exists:  ${ca_intermediate_sensitive_dir}"
  fi

  if ! test -e "${ca_intermediate_conf}"; then
    cp "${ca_intermediate_conf_template}" "${ca_intermediate_conf}" \
      || fail $ERR_CONF "Failed to create conf:  ${ca_intermediate_conf}"

    sed -i 's/DOMAIN/'${domain}'/' "${ca_intermediate_conf}" \
      || fail $ERR_CONF "Failed to inject domain name:  ${domain}"
    debug "Injected domain name:  ${1}"
    sed -i 's#CA_DIR#'${certificate_authority}'#' "${ca_intermediate_conf}" \
      || fail $ERR_CONF "Failed to inject certificate authority directory:  ${certificate_authority}"
    debug "Injected certificate authority directory:  ${certificate_authority}"
    sed -i 's#CA_SDIR#'${sensitive}'#' "${ca_intermediate_conf}" \
      || fail $ERR_CONF "Failed to inject sensitive certificate authority directory:  ${sensitive}"
    debug "Injected certificate sensitive authority directory:  ${sensitive}"
    inform "Generated conf:  ${ca_intermediate_conf}"
    remove_stale "${depend_on_ca_intermediate_conf[@]}"
  else
    debug "Conf exists:  ${ca_intermediate_conf}"
  fi

  if ! test -e "${ca_intermediate_key}"; then
    rm -f "${ca_intermediate_dir}/index.txt"{,.attr} \
      || fail $ERR_GENRSA "Failed to remove stale index files."
    touch "${ca_intermediate_dir}/index.txt"{,.attr} \
      || fail $ERR_GENRSA "Failed to create index files."
    echo 1000 > "${ca_intermediate_dir}/serial" \
      || fail $ERR_GENRSA "Failed to create 'serial'."
    rm -f "${ca_intermediate_dir}/serial.old" \
      || fail $ERR_GENRSA "Failed to remove stale 'serial.old'."
    echo 1000 > "${ca_intermediate_dir}/crlnumber" \
      || fail $ERR_GENRSA "Failed to create 'crlnumber'."
    { pass show "${ca_intermediate_key_pass_path}"; yes; } \
      | openssl genrsa -passout stdin -aes256 -out "${ca_intermediate_key}" 4096 \
      || fail $ERR_GENRSA "Failed to generate CA intermediate key:  ${ca_intermediate_key}"
    inform "Generated key:  ${ca_intermediate_key}"
    remove_stale "${depend_on_ca_intermediate_key[@]}"
  else
    debug "Key exists:  ${ca_intermediate_key}"
  fi

  if ! test -e "${ca_intermediate_csr}"; then
    { pass show "${ca_intermediate_key_pass_path}"; yes; } \
      | openssl req -passin stdin -config "${ca_intermediate_conf}" -new -sha256 -key "${ca_intermediate_key}" -out "${ca_intermediate_csr}" \
      || fail $ERR_CSR "Failed to generate CSR:  ${ca_intermediate_csr}"
    inform "Generated CSR:  ${ca_intermediate_csr}"
    remove_stale "${depend_on_ca_intermediate_csr[@]}"
  else
    debug "CSR exists:  ${ca_intermediate_csr}"
  fi

  if ! test -e "${ca_intermediate_cert}"; then
    { pass show "${ca_root_key_pass_path}"; yes; } \
      | openssl ca -passin stdin -config "${ca_root_conf}" -extensions v3_intermediate_ca -days $(( 365 * 10 )) -notext -md sha256 -in "${ca_intermediate_csr}" -out "${ca_intermediate_cert}" \
      || fail $ERR_CERT "Failed to generate certificate:  ${ca_intermediate_cert}"
    inform "Generated certificate:  ${ca_intermediate_cert}"
    remove_stale "${depend_on_ca_intermediate_cert[@]}"
  else
    debug "Certificate exists:  ${ca_intermediate_cert}"
  fi

  if ! test -e "${ca_intermediate_cert_der}"; then
    yes | openssl x509 -outform der -in $ca_intermediate_cert -out $ca_intermediate_cert_der \
      || fail $ERR_CERT "Failed to generate certificate:  ${ca_intermediate_cert_der}"
    inform "Generated certificate:  ${ca_intermediate_cert_der}"
  else
    debug "Certificate exists:  ${ca_intermediate_cert_der}"
  fi

  if ! test -e "${ca_intermediate_crl}"; then
    { pass show "${ca_intermediate_key_pass_path}"; yes; } \
      | openssl ca -passin stdin -config "${ca_intermediate_conf}" -gencrl -crldays "${crldays}" -out "${ca_intermediate_crl}" \
      || fail $ERR_CERT "Failed to generate revocation list:  ${ca_intermediate_crl}"
    inform "Generated revocation list:  ${ca_intermediate_crl}"
    remove_stale "${depend_on_ca_intermediate_crl[@]}"
  else
    debug "Revocation list exists:  ${ca_intermediate_crl}"
  fi

  if ! test -e "${ca_intermediate_crl_der}"; then
    yes | openssl crl -in  "${ca_intermediate_crl}" -outform der -out "${ca_intermediate_crl_der}" \
      || fail $ERR_CERT "Failed to generate DER encoded revocation list:  ${ca_intermediate_crl_der}"
    inform "Generated DER encoded revocation list:  ${ca_intermediate_crl_der}"
    remove_stale "${depend_on_ca_intermediate_crl_der[@]}"
  else
    debug "DER encoded revocation list exists:  ${ca_intermediate_crl}"
  fi
}
