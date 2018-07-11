# Links

If you want to trust this CA, trust these certs:

<a href='https://raw.githubusercontent.com/abugher/fleet/master/ssl/ca/root/cert.pem'>CA root cert</a>

<a href='https://raw.githubusercontent.com/abugher/fleet/master/ssl/ca/intermediate/cert.pem'>CA intermediate cert</a>

# Background

This is sort of a certificate factory.  Material from CSR to signed certificates are produced in a pipeline.  Sensitive material is all shovelled into one repo (not on github), but it would probably be better to generate the secret material on each host, leave it there, then retrieve and publish only the public material.

# Usage

  `generate [hostname] ...`

  `revoke <hostname>`

Run generate to generate SSL material.  Specify all short names for a host, starting with the most canonical, and both the short name and the short name combined with a fixed domain will be provisioned.  At least one short name must be specified.  This will generate a certificate, certificate chain, and certificate revocation list.

If 'dmz' is specified as a short name, the root domain name will be added as a valid name for the host, in addition to the subdomain 'dmz'.

If no host key is present, one will be generated, and all dependent files will be regenerated.  (The script may have a somewhat overzealous notion of "dependent" at the moment.)  If CA material is missing, or there is no CA material, the CA material will be regenerated, and all dependent material will be regenerated, but other hosts will not be automatically regenerated.

Run generate with no arguments to only generate CA material.

revoke takes one short hostname, which must be the first shortname specified when the target certificate was generated.  This certificate will be revoked, and the CRL will be updated.  The CRL can then be pushed to the web via ansible.  The location of the CRL is specified in the cert, so any client using it should have opportunity to discover it has been revoked.
