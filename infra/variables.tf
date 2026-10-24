variable "resource_group_name" {
  description = "Name of the resource group. Shared across all modules."
  type        = string
}

variable "location" {
  description = "Location of the resource group. Shared across all modules."
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "appgw_subnet_name" {
  description = "The name of the application gateway subnet."
  type        = string
}

variable "appgw_subnet_address_prefix" {
  description = "The address prefix for the application gateway subnet."
  type        = list(string)
}

variable "aca_subnet_name" {
  description = "The name of the ACA subnet."
  type        = string
}

variable "aca_subnet_address_prefix" {
  description = "The address prefix for the ACA subnet."
  type        = list(string)
}

variable "agw_public_ip_name" {
  description = "The name of the public IP address for the application gateway."
  type        = string
}

variable "natgw_public_ip_name" {
  description = "The name of the public IP address for the NAT gateway."
  type        = string
}

variable "nsg_agw_name" {
  description = "The name of the network security group for the application gateway subnet."
  type        = string
}

variable "nsg_cae_name" {
  description = "The name of the network security group for the ACA subnet."
  type        = string
}

variable "nat_gateway_name" {
  description = "The name of the NAT gateway."
  type        = string
}

variable "key_vault_sku_name" {
  description = "The SKU name of the Key Vault."
  type        = string

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "key_vault_sku_name must be either \"standard\" or \"premium\"."
  }
}

variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
}

variable "agw_kv_identity_name" {
  description = "Name of the managed identity that Application Gateway uses to read the TLS certificate from Key Vault."
  type        = string
}

variable "acme_registration_email" {
  description = "The email address for ACME registration."
  type        = string
}

variable "common_name" {
  description = "The common name for the certificate."
  type        = string
}

variable "certificate_name" {
  description = "Name of the certificate object stored in Key Vault (cert-tm-dev-eus)."
  type        = string
}

variable "container_apps_name" {
  description = "The name of the container app."
  type        = string
}

variable "container_apps_image" {
  description = "The repository:tag portion of the image (e.g. 'tm:v1') — the registry hostname is added automatically from the ACR resource's own login_server, not typed here."
  type        = string
}

variable "container_apps_environment_name" {
  description = "The name of the container app environment."
  type        = string
}

variable "azure_container_registry_name" {
  description = "The name of the Azure Container Registry."
  type        = string
}

variable "azure_container_registry_sku" {
  description = "The SKU of the Azure Container Registry."
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
}

variable "aca_acr_identity_name" {
  description = "Name of the managed identity that the Container App uses to pull images from the Container Registry."
  type        = string
}

variable "target_port" {
  description = "The port the container listens on inside the app, referenced by the Container App's ingress configuration."
  type        = number
}

variable "container_apps_cpu" {
  description = "The number of CPU cores allocated to the container app."
  type        = number
}

variable "container_apps_memory" {
  description = "The amount of memory allocated to the container app."
  type        = string
}

variable "log_analytics_workspace_sku" {
  description = "The SKU of the Log Analytics workspace."
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the public DNS zone (theradwan.com)."
  type        = string
}

variable "tm_record_name" {
  description = "The name of the public A record ('tm')."
  type        = string
}

variable "public_record_ttl" {
  description = "TTL, in seconds, for the public tm A record."
  type        = number
}

variable "vnet_link_name" {
  description = "The name of the private DNS zone's virtual network link."
  type        = string
}

variable "private_record_ttl" {
  description = "TTL, in seconds, for the private wildcard A record."
  type        = number
}

variable "frontend_ip_configuration_name" {
  description = "The name of the frontend IP configuration."
  type        = string
}

variable "app_gateway_name" {
  description = "The name of the application gateway."
  type        = string
}

variable "app_gateway_sku_name" {
  description = "The name of the application gateway SKU."
  type        = string
}

variable "backend_pool_name" {
  description = "The name of the backend pool."
  type        = string
}

variable "https_listener_name" {
  description = "The name of the HTTPS listener."
  type        = string
}

variable "frontend_port_name" {
  description = "The name of the frontend port."
  type        = string
}

variable "routing_rule_name" {
  description = "The name of the routing rule."
  type        = string
}

variable "gateway_ip_configuration_name" {
  description = "The name of the gateway IP configuration."
  type        = string
}

variable "backend_http_settings_name" {
  description = "The name of the backend HTTP settings."
  type        = string
}

variable "ssl_certificate_name" {
  description = "The name of the SSL certificate."
  type        = string
}

variable "autoscale_configuration" {
  description = "Autoscale settings for the Application Gateway (minimum and maximum instance count)."
  type = object({
    min_capacity = number
    max_capacity = number
  })
}


variable "http_frontend_port_name" {
  description = "The name of the frontend port for plain HTTP (80), used only to redirect to HTTPS."
  type        = string
}

variable "http_listener_name" {
  description = "The name of the HTTP listener that redirects to HTTPS."
  type        = string
}

variable "redirect_configuration_name" {
  description = "The name of the HTTP to HTTPS redirect configuration."
  type        = string
}

variable "http_routing_rule_name" {
  description = "The name of the routing rule for the HTTP to HTTPS redirect."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
}

variable "certificate_officer_principal_ids" {
  description = "Principals granted Key Vault Certificates Officer on the vault."
  type        = map(string)
}
