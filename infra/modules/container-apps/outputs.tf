output "default_domain" {
  description = "The Container Apps environment's default domain, used as the private DNS zone name."
  value       = azurerm_container_app_environment.cae.default_domain
}

output "container_apps_fqdn" {
  description = "FQDN of the Container App, used as the App Gateway backend."
  value       = azurerm_container_app.app.ingress[0].fqdn
}

output "static_ip_address" {
  description = "The Container Apps environment's internal static IP."
  value       = azurerm_container_app_environment.cae.static_ip_address
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace. Used by the app-gateway module for its diagnostic setting."
  value       = azurerm_log_analytics_workspace.law.id
}

output "acr_login_server" {
  description = "Login server of the container registry, for example acrtmradwan.azurecr.io."
  value       = azurerm_container_registry.acr.login_server
}
