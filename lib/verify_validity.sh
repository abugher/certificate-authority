#!/bin/bash

function verify_validity() {
  if ! test '2' = "${#}"; then
    fail $ERR_USAGE "Specify a certificate file and a CRL file to validate."
  fi
  cert="${1}"
  crl="${2}"
  openssl verify \
    -crl_check_all \
    -trusted "${ca_root_cert}" -CRLfile "${ca_root_crl}" \
    -untrusted "${ca_intermediate_cert}" -CRLfile "${ca_intermediate_crl}" \
    -CRLfile "${crl}" \
    "${cert}" \
    >/dev/null \
    || fail $ERR_CERT "Failed to verify certificate validity:  ${cert}"
}
