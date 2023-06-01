# Links

If you want to trust this CA, trust these certs:

<a href='https://raw.githubusercontent.com/abugher/certificate-authority/master/ca/root/cert.cer'>CA root cert</a>

<a href='https://raw.githubusercontent.com/abugher/certificate-authority/master/ca/intermediate/cert.cer'>CA intermediate cert</a>

# Concept

This is a TLS/SSL host certificate factory.  The scripts present here should hide the complexity and arcana of certificate authority management.

# Usage

  `generate [hostname ...]`

  `revoke <hostname>`

  `verify <hostname>`

Run generate to generate SSL material.  Specify all short names for a host, starting with the most canonical, and the short name combined with a fixed domain will be provisioned.  At least one short name must be specified.  This will generate a certificate, certificate chain, and certificate revocation list.

If 'dmz' is specified as a short name, the root domain name will be added as a valid name for the host, in addition to the subdomain 'dmz'.

If no host key is present, one will be generated, and all dependent files will be regenerated.  If CA material is missing, or there is no CA material, the CA material will be regenerated, and all dependent material will be regenerated, but other hosts will not be automatically regenerated.

Run generate with no arguments to only generate CA material.

revoke takes one short hostname, which must be the first shortname specified when the target certificate was generated.  This certificate will be revoked, and the CRL will be updated.  The CRL can then be pushed to the web via ansible.  The location of the CRL is specified in the cert, so any client using it should have opportunity to discover it has been revoked.

verify takes one short hostname, which must be the firt shortname specified when the target certificate was generated.  This certificate will be verified against the current CA material and revocation lists.  If the certificate or any CA material has been revoked, or if the CRL has expired, or if the signature chain is not complete (perhaps because a CA key has been replaced), verification will fail.

# Planned Improvement

Sensitive material is all shovelled into private repos (not on github), but it would probably be better to generate the secret material on each host, leave it there, then retrieve and publish only the public material.

There is a script to verify a single host, but top-to-bottom verification is a missing feature.  The verify script could be used by the generate script to automatically detect and regenerate any stale material during CA or host material generation.  It may also be nice to have a script to verify host keys, regenerate stale ones, and then deploy them to their hosts.

Certificate revocation lists are generated with an expiration date.  It could be beneficial to set up a dedicated certificate authority server to actively update and publish those, to avoid warnings/errors about expired CRL's.

Some or all of this could possibly work better as a make file, considering the long chains of dependencies and automatic ordered generation of material.
