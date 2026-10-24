# --- shared ---
resource_group_name = "rg-tm-dev-eus"
location            = "eastus"

# --- networking ---
vnet_name                   = "vnet-tm-dev-eus"
vnet_address_space          = ["10.0.0.0/16"]
appgw_subnet_name           = "snet-agw-tm-dev-eus"
appgw_subnet_address_prefix = ["10.0.1.0/24"]
aca_subnet_name             = "snet-cae-tm-dev-eus"
aca_subnet_address_prefix   = ["10.0.0.0/24"]
agw_public_ip_name          = "pip-agw-tm-dev-eus"
natgw_public_ip_name        = "pip-ngw-tm-dev-eus"
nsg_agw_name                = "nsg-agw-tm-dev-eus"
nsg_cae_name                = "nsg-cae-tm-dev-eus"
nat_gateway_name            = "ngw-cae-tm-dev-eus"

# --- key-vault ---
key_vault_sku_name      = "standard"
key_vault_name          = "kv-tm-radwan-eus"
agw_kv_identity_name    = "id-agw-kv-tm-dev-eus"
acme_registration_email = "radwan201626@outlook.com" # CHANGE ME: Let's Encrypt registration email
common_name             = "tm.theradwan.com"
certificate_name        = "cert-tm-dev-eus"

# --- container-apps ---
container_apps_name             = "ca-tm-dev-eus"
container_apps_image            = "tm:ce3ca1a8dc02fcef92610c1995ed4bf7d7a54c9a"
container_apps_environment_name = "cae-tm-dev-eus"
azure_container_registry_name   = "acrtmradwan"
azure_container_registry_sku    = "Basic"
log_analytics_workspace_name    = "log-tm-dev-eus"
log_analytics_workspace_sku     = "PerGB2018"
target_port                     = 80
aca_acr_identity_name           = "id-aca-acr-tm-dev-eus"
container_apps_cpu              = 0.25
container_apps_memory           = "0.5Gi"

# --- app-gateway ---
app_gateway_name               = "agw-tm-dev-eus"
app_gateway_sku_name           = "Standard_v2"
gateway_ip_configuration_name  = "gwip-agw-tm-dev-eus"
frontend_ip_configuration_name = "feip-agw-tm-dev-eus"
frontend_port_name             = "feport-443"
backend_pool_name              = "bepool-ca-tm-dev-eus"
backend_http_settings_name     = "behttp-ca-tm-dev-eus"
https_listener_name            = "lstn-https-tm-dev-eus"
ssl_certificate_name           = "ssl-tm-dev-eus"
routing_rule_name              = "rule-tm-dev-eus"
http_frontend_port_name        = "feport-80"
http_listener_name             = "lstn-http-tm-dev-eus"
redirect_configuration_name    = "redir-https-tm-dev-eus"
http_routing_rule_name         = "rule-http-tm-dev-eus"
autoscale_configuration = {
  min_capacity = 0
  max_capacity = 2
}

# --- dns ---
dns_zone_name      = "theradwan.com"
tm_record_name     = "tm"
public_record_ttl  = 300
vnet_link_name     = "link-vnet-tm-dev-eus"
private_record_ttl = 300

# --- tags ---
tags = {
  project     = "tm"
  environment = "dev"
  managed_by  = "terraform"
}

certificate_officer_principal_ids = {
  deployer       = "bd225c40-8669-4429-8bd9-383041309a74"
  github_actions = "0cfcdfe7-b2ab-43a3-9246-9ff65debad60"
}
