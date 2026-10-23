output "agw_kv_identity_id" {
  description = "ID of the managed identity App Gateway uses to read the TLS certificate from Key Vault."
  value       = azurerm_user_assigned_identity.agw_kv_identity.id

  # App Gateway must not be created until this identity can read Key Vault secrets
  depends_on = [time_sleep.rbac_propagation]
}

output "certificate_secret_id" {
  description = "Versionless secret ID of the TLS certificate, so App Gateway always picks up the latest renewal."
  value       = azurerm_key_vault_certificate.certificate.versionless_secret_id
}
