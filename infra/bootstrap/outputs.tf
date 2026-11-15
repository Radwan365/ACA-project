output "state_resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "state_storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "state_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "AZURE_CLIENT_ID" {
  value = azurerm_user_assigned_identity.github.client_id
}

output "AZURE_TENANT_ID" {
  value = data.azurerm_client_config.current.tenant_id
}

output "AZURE_SUBSCRIPTION_ID" {
  value = data.azurerm_subscription.current.subscription_id
}

output "github_identity_principal_id" {
  description = "Object ID of the GitHub Actions identity. Goes into certificate_officer_principal_ids in infra/terraform.tfvars."
  value       = azurerm_user_assigned_identity.github.principal_id
}

output "deployer_principal_id" {
  description = "Object ID of whoever ran the bootstrap. Goes into certificate_officer_principal_ids in infra/terraform.tfvars."
  value       = data.azurerm_client_config.current.object_id
}
