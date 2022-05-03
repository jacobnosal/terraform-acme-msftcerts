provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "tlsconvert" {}

resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
}

# resource "tls_private_key" "cert_private_key" {
#   algorithm = "RSA"
# }

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address   = var.registration_email
}

resource "acme_certificate" "certificate" {
  account_key_pem         = acme_registration.reg.account_key_pem
  common_name = var.dns_name
  min_days_remaining = 30

  dns_challenge {
    provider = "azure"

    config = {
        AZURE_CLIENT_ID = var.azure_client_id
        AZURE_CLIENT_SECRET = var.azure_client_secret
        AZURE_ENVIRONMENT = "public"
        AZURE_RESOURCE_GROUP = var.azure_resource_group
        AZURE_SUBSCRIPTION_ID = var.azure_subscription_id
        AZURE_TENANT_ID = var.azure_tenant_id
        AZURE_ZONE_NAME = var.azure_zone_name
    }
  }
}

data "tlsconvert_rsa_private_key" "unencrypted_rsa_private_key" {
  input_format = "PKCS#1"
  input_pem    = acme_certificate.certificate.private_key_pem

  output_format = "PKCS#8"
}

resource "local_file" "pfx" {
  filename       = "./keys/${var.dns_name}.pfx"
  content        = acme_certificate.certificate.certificate_p12
}

resource "local_file" "trusted_root_cert" {
  filename = "./keys/${var.dns_name}.trusted_root_cert.cer"
  # I think this issuer_pem needs to be pulled apart for the root ca?
  content = "${acme_certificate.certificate.issuer_pem}" #${data.tlsconvert_rsa_private_key.unencrypted_rsa_private_key.output_pem}"
}