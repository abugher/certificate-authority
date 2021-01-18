#!/bin/bash

function verify_validity() {
  openssl verify \
    -crl_check_all \
    -trusted "${ca_root_cert}" -CRLfile "${ca_root_crl}" \
    -untrusted "${ca_intermediate_cert}" -CRLfile "${ca_intermediate_crl}" \
    -CRLfile "${host_crl}" \
    "${host_cert}" \
    >/dev/null \
    || fail $ERR_CERT "Failed to verify certificate:  ${host_cert}"
}
