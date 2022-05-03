# terraform-acme-msftcerts
<!-- output the trusted root certificate (.pem with private key in x.509), ssl certificate (.pfx), and client certs (haven't figured thsi out) needed for azure app gateway.

Still, the weak point in full chain TLS is that we don't verify the client cert presented. This could be mitigated by registering client certs (trusted_client_cert) here and distributing with apps. -->