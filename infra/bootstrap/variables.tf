variable "subscription_id" {
  type        = string
  description = "Subscription the bootstrap resources deploy into"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group holding the state storage"
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique, 3-24 lowercase alphanumeric"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "container_name" {
  type    = string
  default = "tfstate"
}

variable "retention_days" {
  type    = number
  default = 30
}

variable "replication_type" {
  type        = string
  default     = "ZRS"
  description = "Replication for the state storage account"
}

variable "deploy_resource_group_name" {
  type        = string
  description = "Existing resource group the main stack deploys into"
}

variable "identity_name" {
  type    = string
  default = "id-github-actions"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in owner/repo form"

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repo))
    error_message = "Must be in owner/repo form."
  }
}

variable "github_branch" {
  type    = string
  default = "main"
}
