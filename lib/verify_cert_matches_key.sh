#!/bin/bash


function verify_cert_matches_key() {
  diff -q <(
    openssl x509 -noout -modulus -in "${host_cert}"
  ) <(
    openssl rsa -noout -modulus -in "${host_key}"
  ) >/dev/null \
    || {
      debug "Cert file:  ${host_cert}"
      debug "Key file:   ${host_key}"
      fail $ERR_VERIFY "Cert does not match key."
    }
}
