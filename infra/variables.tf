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

variable "aks_subnet_name" {
  description = "The name of the AKS node subnet."
  type        = string
}

variable "aks_subnet_address_prefix" {
  description = "The address prefix for the AKS node subnet."
  type        = list(string)
}

variable "nsg_aks_name" {
  description = "The name of the network security group for the AKS node subnet."
  type        = string
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

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "aks_node_resource_group_name" {
  description = "Name of the resource group AKS creates for the nodes, disks and load balancer."
  type        = string
}

variable "aks_identity_name" {
  description = "Name of the managed identity used by the AKS control plane."
  type        = string
}

variable "aks_node_vm_size" {
  description = "VM size of the AKS nodes."
  type        = string
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS node pool."
  type        = number
}

variable "aks_pod_cidr" {
  description = "Overlay address range for pods. Must not overlap the VNet or the service range."
  type        = string
}

variable "aks_service_cidr" {
  description = "Address range for Kubernetes services. Must not overlap the VNet or the pod range."
  type        = string
}

variable "aks_dns_service_ip" {
  description = "Address of the cluster DNS service. Must be inside aks_service_cidr."
  type        = string
}

variable "aks_diagnostic_setting_name" {
  description = "Name of the diagnostic setting that sends AKS control plane logs to Log Analytics."
  type        = string
}

variable "app_backend_ip" {
  description = "Private IP of the internal load balancer in front of the pods. Must be a free address in the AKS node subnet and match k8s/service.yaml."
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

variable "app_gateway_sku_tier" {
  description = "The tier of the application gateway SKU."
  type        = string
}

variable "probe_name" {
  description = "The name of the Application Gateway health probe."
  type        = string
}

variable "app_gateway_diagnostic_setting_name" {
  description = "Name of the diagnostic setting that sends Application Gateway logs and metrics to Log Analytics."
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
