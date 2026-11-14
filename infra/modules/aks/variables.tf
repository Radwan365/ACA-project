variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
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

variable "aks_cluster_name" {
  description = "The name of the AKS cluster. Also used as its DNS prefix."
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

variable "aks_subnet_id" {
  description = "ID of the subnet the nodes and the internal load balancer are placed in, created in the networking module."
  type        = string
}

variable "aks_node_vm_size" {
  description = "VM size of the nodes."
  type        = string
}

variable "aks_node_count" {
  description = "Number of nodes in the node pool."
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

variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
}
