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
