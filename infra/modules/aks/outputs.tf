output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  description = "Login server of the container registry, for example acrtmradwan.azurecr.io."
  value       = azurerm_container_registry.acr.login_server
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace. Used by the app-gateway module for its diagnostic setting."
  value       = azurerm_log_analytics_workspace.law.id
}
