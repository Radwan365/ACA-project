variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
  type        = string
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

variable "appgw_subnet_id" {
  description = "The ID of the subnet for the application gateway."
  type        = string
}

variable "agw_kv_identity_id" {
  description = "The ID of the managed identity for the application gateway to access Key Vault."
  type        = string
}

variable "certificate_secret_id" {
  description = "The secret ID of the SSL certificate in Key Vault."
  type        = string
}

variable "container_apps_fqdn" {
  description = "The fully qualified domain name of the container app."
  type        = string
}

variable "agw_public_ip_id" {
  description = "ID of the Application Gateway's public IP, created in the networking module."
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
