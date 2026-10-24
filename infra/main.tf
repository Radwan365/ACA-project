# Created by bootstrap/bootstrap.sh, deliberately kept outside Terraform
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
  aca_subnet_name             = var.aca_subnet_name
  aca_subnet_address_prefix   = var.aca_subnet_address_prefix
  agw_public_ip_name          = var.agw_public_ip_name
  natgw_public_ip_name        = var.natgw_public_ip_name
  nsg_agw_name                = var.nsg_agw_name
  nsg_cae_name                = var.nsg_cae_name
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

module "container_apps" {
  source = "./modules/container-apps"

  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = var.location
  tags                            = var.tags
  container_apps_name             = var.container_apps_name
  container_apps_image            = var.container_apps_image
  container_apps_environment_name = var.container_apps_environment_name
  azure_container_registry_name   = var.azure_container_registry_name
  azure_container_registry_sku    = var.azure_container_registry_sku
  log_analytics_workspace_name    = var.log_analytics_workspace_name
  log_analytics_workspace_sku     = var.log_analytics_workspace_sku
  target_port                     = var.target_port
  aca_acr_identity_name           = var.aca_acr_identity_name
  container_apps_cpu              = var.container_apps_cpu
  container_apps_memory           = var.container_apps_memory

  # wired from networking
  container_apps_subnet_id = module.networking.aca_subnet_id
}

module "app_gateway" {
  source = "./modules/app-gateway"

  resource_group_name            = data.azurerm_resource_group.rg.name
  location                       = var.location
  tags                           = var.tags
  app_gateway_name               = var.app_gateway_name
  app_gateway_sku_name           = var.app_gateway_sku_name
  autoscale_configuration        = var.autoscale_configuration
  gateway_ip_configuration_name  = var.gateway_ip_configuration_name
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  frontend_port_name             = var.frontend_port_name
  backend_pool_name              = var.backend_pool_name
  backend_http_settings_name     = var.backend_http_settings_name
  https_listener_name            = var.https_listener_name
  ssl_certificate_name           = var.ssl_certificate_name
  routing_rule_name              = var.routing_rule_name
  http_frontend_port_name        = var.http_frontend_port_name
  http_listener_name             = var.http_listener_name
  redirect_configuration_name    = var.redirect_configuration_name
  http_routing_rule_name         = var.http_routing_rule_name

  # wired from networking
  appgw_subnet_id  = module.networking.appgw_subnet_id
  agw_public_ip_id = module.networking.agw_public_ip_id

  # wired from key-vault
  agw_kv_identity_id    = module.key_vault.agw_kv_identity_id
  certificate_secret_id = module.key_vault.certificate_secret_id

  # wired from container-apps
  container_apps_fqdn = module.container_apps.container_apps_fqdn
}

module "dns" {
  source = "./modules/dns"

  resource_group_name = data.azurerm_resource_group.rg.name
  dns_zone_name       = var.dns_zone_name
  tags                = var.tags
  tm_record_name      = var.tm_record_name
  public_record_ttl   = var.public_record_ttl
  vnet_link_name      = var.vnet_link_name
  private_record_ttl  = var.private_record_ttl

  # wired from networking
  agw_public_ip_address = module.networking.agw_public_ip_address
  vnet_id               = module.networking.vnet_id

  # wired from container-apps
  aca_environment_default_domain = module.container_apps.default_domain
  aca_static_ip_address          = module.container_apps.static_ip_address
}
