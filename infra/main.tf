# The resource group is created once, outside the main stack (see the README), so a destroy
# of this stack never removes the group or the public DNS zone inside it
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

module "networking" {
  source = "./modules/networking"

  resource_group_name         = data.azurerm_resource_group.rg.name
  location                    = var.location
  tags                        = var.tags
  vnet_name                   = var.vnet_name
  vnet_address_space          = var.vnet_address_space
  appgw_subnet_name           = var.appgw_subnet_name
  appgw_subnet_address_prefix = var.appgw_subnet_address_prefix
  aks_subnet_name             = var.aks_subnet_name
  aks_subnet_address_prefix   = var.aks_subnet_address_prefix
  agw_public_ip_name          = var.agw_public_ip_name
  natgw_public_ip_name        = var.natgw_public_ip_name
  nsg_agw_name                = var.nsg_agw_name
  nsg_aks_name                = var.nsg_aks_name
  nat_gateway_name            = var.nat_gateway_name
}

module "key_vault" {
  source = "./modules/key-vault"

  resource_group_name               = data.azurerm_resource_group.rg.name
  location                          = var.location
  tags                              = var.tags
  sku_name                          = var.key_vault_sku_name
  key_vault_name                    = var.key_vault_name
  agw_kv_identity_name              = var.agw_kv_identity_name
  acme_registration_email           = var.acme_registration_email
  common_name                       = var.common_name
  certificate_name                  = var.certificate_name
  certificate_officer_principal_ids = var.certificate_officer_principal_ids

  # wired from dns
  dns_zone_name = module.dns.public_zone_name
}

module "aks" {
  source = "./modules/aks"

  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = var.location
  tags                          = var.tags
  azure_container_registry_name = var.azure_container_registry_name
  azure_container_registry_sku  = var.azure_container_registry_sku
  log_analytics_workspace_name  = var.log_analytics_workspace_name
  log_analytics_workspace_sku   = var.log_analytics_workspace_sku
  aks_cluster_name              = var.aks_cluster_name
  aks_node_resource_group_name  = var.aks_node_resource_group_name
  aks_identity_name             = var.aks_identity_name
  aks_node_vm_size              = var.aks_node_vm_size
  aks_node_count                = var.aks_node_count
  aks_pod_cidr                  = var.aks_pod_cidr
  aks_service_cidr              = var.aks_service_cidr
  aks_dns_service_ip            = var.aks_dns_service_ip
  aks_diagnostic_setting_name   = var.aks_diagnostic_setting_name

  # wired from networking
  aks_subnet_id = module.networking.aks_subnet_id
}

module "app_gateway" {
  source = "./modules/app-gateway"

  resource_group_name            = data.azurerm_resource_group.rg.name
  location                       = var.location
  tags                           = var.tags
  app_gateway_name               = var.app_gateway_name
  app_gateway_sku_name           = var.app_gateway_sku_name
  app_gateway_sku_tier           = var.app_gateway_sku_tier
  autoscale_configuration        = var.autoscale_configuration
  gateway_ip_configuration_name  = var.gateway_ip_configuration_name
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  frontend_port_name             = var.frontend_port_name
  backend_pool_name              = var.backend_pool_name
  backend_http_settings_name     = var.backend_http_settings_name
  backend_ip_address             = var.app_backend_ip
  probe_name                     = var.probe_name
  probe_host                     = var.common_name
  https_listener_name            = var.https_listener_name
  ssl_certificate_name           = var.ssl_certificate_name
  routing_rule_name              = var.routing_rule_name
  http_frontend_port_name        = var.http_frontend_port_name
  http_listener_name             = var.http_listener_name
  redirect_configuration_name    = var.redirect_configuration_name
  http_routing_rule_name         = var.http_routing_rule_name
  diagnostic_setting_name        = var.app_gateway_diagnostic_setting_name

  # wired from networking
  appgw_subnet_id  = module.networking.appgw_subnet_id
  agw_public_ip_id = module.networking.agw_public_ip_id

  # wired from key-vault
  agw_kv_identity_id    = module.key_vault.agw_kv_identity_id
  certificate_secret_id = module.key_vault.certificate_secret_id

  # wired from aks
  log_analytics_workspace_id = module.aks.log_analytics_workspace_id
}

module "dns" {
  source = "./modules/dns"

  resource_group_name = data.azurerm_resource_group.rg.name
  dns_zone_name       = var.dns_zone_name
  tags                = var.tags
  tm_record_name      = var.tm_record_name
  public_record_ttl   = var.public_record_ttl

  # wired from networking
  agw_public_ip_address = module.networking.agw_public_ip_address
}
