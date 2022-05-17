output "cert_domain" {
  value = acme_certificate.certificate.certificate_domain
}

output "certificate_pem" {
  value = acme_certificate.certificate.certificate_pem
}

output "issuer_pem" {
  value = acme_certificate.certificate.issuer_pem
}

output "fullchain_pem" {
  value = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
}

output "pfx" {
  value     = acme_certificate.certificate.certificate_p12
  sensitive = true
}

output "pfx_password" {
  value     = acme_certificate.certificate.certificate_p12_password
  sensitive = true
}

output "test" {
  value = chomp(trimspace(trimprefix(element(split("-----END CERTIFICATE-----", "${acme_certificate.certificate.issuer_pem}"), 0), "-----BEGIN CERTIFICATE-----")))
}

output "cert" {
  value = data.tls_certificate.example
}