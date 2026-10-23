variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
  type        = string
}

variable "container_apps_name" {
  description = "The name of the container app."
  type        = string
}

variable "container_apps_image" {
  description = "The image of the container app."
  type        = string
}

variable "container_apps_subnet_id" {
  description = "The ID of the subnet for the container app."
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

variable "target_port" {
  description = "The port the container listens on inside the app, referenced by the Container App's ingress configuration."
  type        = number
}

variable "aca_acr_identity_name" {
  description = "Name of the managed identity that the Container App uses to pull images from the Container Registry."
  type        = string
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

variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
}
