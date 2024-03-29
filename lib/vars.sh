#!/bin/bash

sensitive="${certificate_authority}/../sensitive-certificate-authority"

if grep -q . <<< "${1}"; then
  host="${1}"
  ca_only='no'
else
  ca_only='yes'
fi

domain='neuronpointer.net'
prefix="${0}:  "
crldays=365

ca_root_dir=${certificate_authority}/ca/root
ca_root_newcerts=${ca_root_dir}/newcerts
ca_root_sensitive_dir=${sensitive}/ca/root
ca_root_conf_template=${certificate_authority}/conf/ca_root_conf_template
ca_root_conf=${ca_root_dir}/conf
ca_root_key=${ca_root_sensitive_dir}/key.pem
ca_root_key_pass_path="${USER}/ca/root_passphrase"
ca_root_cert=${ca_root_dir}/cert.pem
ca_root_cert_der=${ca_root_dir}/cert.cer
ca_root_crl=${ca_root_dir}/crl.pem
ca_root_crl_der=${ca_root_dir}/crl.der

ca_intermediate_dir=${certificate_authority}/ca/intermediate
ca_intermediate_newcerts=${ca_intermediate_dir}/newcerts
ca_intermediate_sensitive_dir=${sensitive}/ca/intermediate
ca_intermediate_conf_template=${certificate_authority}/conf/ca_intermediate_conf_template
ca_intermediate_conf=${ca_intermediate_dir}/conf
ca_intermediate_key=${ca_intermediate_sensitive_dir}/key.pem
ca_intermediate_key_pass_path="${USER}/ca/intermediate_passphrase"
ca_intermediate_csr=${ca_intermediate_dir}/csr.pem
ca_intermediate_cert=${ca_intermediate_dir}/cert.pem
ca_intermediate_cert_der=${ca_intermediate_dir}/cert.cer
ca_intermediate_crl=${ca_intermediate_dir}/crl.pem
ca_intermediate_crl_der=${ca_intermediate_dir}/crl.der

if test 'no' == "${ca_only}"; then
  host_dir=${certificate_authority}/hosts/${host}
  sensitive_host_dir=${sensitive}/hosts/${host}
  host_conf_template=${certificate_authority}/conf/host_conf_template
  host_conf=${host_dir}/conf
  host_key=${sensitive_host_dir}/key.pem
  host_csr=${host_dir}/csr.pem
  host_cert=${host_dir}/cert.pem
  cert_chain=${host_dir}/chain.pem
  host_crl=${host_dir}/crl.pem
  host_crl_der=${host_dir}/crl.der
fi
