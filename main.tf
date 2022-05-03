provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
}

resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address   = var.registration_email
}

# resource "tls_cert_request" "req" {
#   private_key_pem = tls_private_key.cert_private_key.private_key_pem
#   dns_names       = [var.dns_name]

#   subject {
#     common_name = var.dns_name
#     country = "US"
#   }
# }

resource "acme_certificate" "certificate" {
  account_key_pem         = acme_registration.reg.account_key_pem
#   certificate_request_pem = tls_cert_request.req.cert_request_pem
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