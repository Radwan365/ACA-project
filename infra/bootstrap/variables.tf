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

# This must match the subject claim GitHub puts in the OIDC token, or the pipeline cannot
# log in to Azure. Since 15 July 2026 any repository that is created, renamed or transferred
# uses the immutable form, which appends GitHub's numeric owner and repository IDs after an
# "@". The IDs never change, which is the point: a renamed repository keeps the same trust.
variable "github_repo" {
  type        = string
  description = "GitHub repository as it appears in the OIDC subject claim: owner@owner_id/repo@repo_id for repositories created, renamed or transferred since 15 July 2026, otherwise owner/repo."

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repo))
    error_message = "Must be in owner/repo or owner@owner_id/repo@repo_id form."
  }
}

variable "github_branch" {
  type    = string
  default = "main"
}
