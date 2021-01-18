#!/bin/bash


function verify_cert_matches_key() {
  if ! test '2' = "${#}"; then
    fail $ERR_USAGE "Specify a cert and a key to verify matching."
  fi
  cert="${1}"
  key="${2}"
  diff -q <(
    openssl x509 -noout -modulus -in "${cert}" \
      || fail $ERR_CERT "Failed to read modulus from cert:  ${cert}"
  ) <(
    openssl rsa -passin stdin -noout -modulus -in "${key}" \
      || fail $ERR_KEY "Failed to read modulus from key:  ${key}"
  ) >/dev/null \
    || fail $ERR_VERIFY "Cert does not match key."
}
