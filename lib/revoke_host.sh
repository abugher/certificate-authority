#!/bin/bash


function revoke_host() {
  pass show "${ca_intermediate_key_pass_path}" \
    | openssl ca -passin stdin -config ${ca_intermediate_conf} -revoke ${host_cert} \
    || fail $ERR_CERT "Failed to revoke certificate:  ${host_cert}"
  pass show "${ca_intermediate_key_pass_path}" \
    | openssl ca -passin stdin -config ${ca_intermediate_conf} -gencrl -out ${ca_intermediate_crl} \
    || fail $ERR_CERT "Failed to regenerate CRL:  ${ca_intermediate_crl}"
}
