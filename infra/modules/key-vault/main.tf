data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {

  #checkov:skip=CKV_AZURE_42:Purge protection off by design so the vault can be torn down and rebuilt quickly
  #checkov:skip=CKV_AZURE_110:Purge protection off by design so the vault can be torn down and rebuilt quickly
  #checkov:skip=CKV_AZURE_189:GitHub runners and ACME DNS challenge reach the vault over the internet
  #checkov:skip=CKV_AZURE_109:Runner IPs change per run; firewall allow-list not practical
  #checkov:skip=CKV2_AZURE_32:No private endpoint; CI runners access the vault over the internet

  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  rbac_authorization_enabled = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7 # can only be set when the vault is first created

  tags = var.tags
}

resource "azurerm_user_assigned_identity" "agw_kv_identity" {
  name                = var.agw_kv_identity_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

resource "azurerm_role_assignment" "agw_kv_role_assignment" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.agw_kv_identity.principal_id
}

resource "azurerm_role_assignment" "deployer_certificates_officer" {
  for_each = var.certificate_officer_principal_ids

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = each.value
}

# RBAC assignments take a few minutes to propagate; wait before anything uses them
resource "time_sleep" "rbac_propagation" {
  create_duration = "120s"

  depends_on = [
    azurerm_role_assignment.agw_kv_role_assignment,
    azurerm_role_assignment.deployer_certificates_officer,
  ]
}

resource "tls_private_key" "acme_account_key" {
  algorithm = "RSA"
}

resource "acme_registration" "acme_registration" {
  account_key_pem = tls_private_key.acme_account_key.private_key_pem
  email_address   = var.acme_registration_email
}

# Only used to hand the PFX from ACME to Key Vault, so nothing outside this module needs it
resource "random_password" "certificate_p12_password" {
  length  = 32
  special = false
}

resource "acme_certificate" "certificate" {
  account_key_pem          = acme_registration.acme_registration.account_key_pem
  common_name              = var.common_name
  certificate_p12_password = random_password.certificate_p12_password.result

  dns_challenge {
    provider = "azuredns"
    config = {
      AZURE_RESOURCE_GROUP  = var.resource_group_name
      AZURE_ZONE_NAME       = var.dns_zone_name
      AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
      AZURE_AUTH_METHOD     = "cli"
    }
  }
}

resource "azurerm_key_vault_certificate" "certificate" {
  name         = var.certificate_name
  key_vault_id = azurerm_key_vault.kv.id

  certificate {
    contents = acme_certificate.certificate.certificate_p12
    password = random_password.certificate_p12_password.result
  }

  tags = var.tags

  depends_on = [time_sleep.rbac_propagation]
}
