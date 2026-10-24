variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the resource group"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Key Vault."
  type        = string

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be either \"standard\" or \"premium\"."
  }
}

variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
}

variable "agw_kv_identity_name" {
  description = "Name of the managed identity that Application Gateway uses to read the TLS certificate from Key Vault."
  type        = string
}

variable "acme_registration_email" {
  description = "The email address for ACME registration."
  type        = string
}

variable "common_name" {
  description = "The common name for the certificate."
  type        = string
}

variable "certificate_name" {
  description = "Name of the certificate object stored in Key Vault (cert-tm-dev-eus)."
  type        = string
}

variable "dns_zone_name" {
  description = "Public DNS zone used for the ACME DNS-01 challenge, created in the dns module."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
}

variable "certificate_officer_principal_ids" {
  description = "Principals that may write certificates to Key Vault, keyed by a stable name. Fixed list so the assignment doesn't change with whoever runs Terraform."
  type        = map(string)
}
