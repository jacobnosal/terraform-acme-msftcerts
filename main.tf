provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "tlsconvert" {}

# Create the private key
# Create the tls cert -> save to pfx
# Use private key from that cert to create a csr
# create that cert -> save pem as .cer
resource "tls_private_key" "reg_private_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address   = var.registration_email
}

# Create the TLS certificate and save as .pfx
resource "acme_certificate" "certificate" {
  account_key_pem    = acme_registration.reg.account_key_pem
  common_name        = var.dns_name
  min_days_remaining = 30

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_CLIENT_ID       = var.azure_client_id
      AZURE_CLIENT_SECRET   = var.azure_client_secret
      AZURE_ENVIRONMENT     = "public"
      AZURE_RESOURCE_GROUP  = var.azure_resource_group
      AZURE_SUBSCRIPTION_ID = var.azure_subscription_id
      AZURE_TENANT_ID       = var.azure_tenant_id
      AZURE_ZONE_NAME       = var.azure_zone_name
    }
  }
}

resource "local_file" "pfx" {
  filename = "./keys/${var.dns_name}.pfx"
  content  = acme_certificate.certificate.certificate_p12
}

# Trusted Root Certificate
# Create the csr with TLS cert private key, save as .cer
resource "tls_cert_request" "req" {
  private_key_pem = acme_certificate.certificate.private_key_pem
  dns_names       = [var.dns_name]

  subject {
    common_name = var.dns_name
  }
}

resource "acme_certificate" "trusted_root_certificate" {
  account_key_pem         = acme_registration.reg.account_key_pem
  certificate_request_pem = tls_cert_request.req.cert_request_pem
  min_days_remaining      = 30

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_CLIENT_ID       = var.azure_client_id
      AZURE_CLIENT_SECRET   = var.azure_client_secret
      AZURE_ENVIRONMENT     = "public"
      AZURE_RESOURCE_GROUP  = var.azure_resource_group
      AZURE_SUBSCRIPTION_ID = var.azure_subscription_id
      AZURE_TENANT_ID       = var.azure_tenant_id
      AZURE_ZONE_NAME       = var.azure_zone_name
    }
  }
}

resource "local_file" "trusted_root_cert" {
  filename = "./keys/${var.dns_name}.trusted_root_cert.cer"
  content  = acme_certificate.trusted_root_certificate.certificate_pem
}

# data "tlsconvert_rsa_private_key" "unencrypted_rsa_private_key" {
#   input_format = "PKCS#1"
#   input_pem    = acme_certificate.certificate.private_key_pem

#   output_format = "PKCS#8"
# }

# data "tls_certificate" "example" {
#   url = "https://registry.terraform.io"
# }