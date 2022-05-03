variable "registration_email" {
    description = "Email to register with ACME for this cert."
}

variable "dns_name" {
  description = "DNS name of the certificate subject."
}

variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_resource_group" {}
variable "azure_subscription_id" {}
variable "azure_tenant_id" {}
variable "azure_zone_name" {}