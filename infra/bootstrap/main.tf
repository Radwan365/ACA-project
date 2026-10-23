resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location
  lifecycle { prevent_destroy = true }
}

resource "azurerm_storage_account" "tfstate" {
  name                              = var.storage_account_name
  resource_group_name               = azurerm_resource_group.tfstate.name
  location                          = azurerm_resource_group.tfstate.location
  account_tier                      = "Standard"
  account_replication_type          = var.replication_type
  min_tls_version                   = "TLS1_2"
  shared_access_key_enabled         = false
  allow_nested_items_to_be_public   = false
  infrastructure_encryption_enabled = true # can only be set when the account is first created

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = var.retention_days
    }

    container_delete_retention_policy {
      days = var.retention_days
    }
  }

  lifecycle { prevent_destroy = true }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"

  lifecycle { prevent_destroy = true }
}
