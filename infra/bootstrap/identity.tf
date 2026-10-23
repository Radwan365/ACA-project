# ---------------------------------------------------------------------------
# GitHub Actions identity (OIDC - no client secret anywhere)
# ---------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "github" {
  name                = var.identity_name
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location
}

# Lets workflows running on the main branch log in (used for apply).
resource "azurerm_federated_identity_credential" "github_branch" {
  name                      = "github-${replace(var.github_branch, "/", "-")}"
  user_assigned_identity_id = azurerm_user_assigned_identity.github.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}"
}

# Lets pull-request workflows log in (used for plan).
resource "azurerm_federated_identity_credential" "github_pull_request" {
  name                      = "github-pull-request"
  user_assigned_identity_id = azurerm_user_assigned_identity.github.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:${var.github_repo}:pull_request"

  # Azure rejects concurrent credential writes on the same identity
  depends_on = [azurerm_federated_identity_credential.github_branch]
}

# ---------------------------------------------------------------------------
# Role assignments
# ---------------------------------------------------------------------------

# Shared keys are disabled, so state access is Entra ID only.
resource "azurerm_role_assignment" "github_state" {
  scope                = azurerm_storage_container.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "deployer_state" {
  scope                = azurerm_storage_container.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azurerm_resource_group" "deploy" {
  name = var.deploy_resource_group_name
}

resource "azurerm_role_assignment" "github_contributor" {
  scope                = data.azurerm_resource_group.deploy.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
  principal_type       = "ServicePrincipal"
}

# The main stack creates role assignments, which Contributor can't do.
# The condition limits this to the roles the main stack actually assigns.
locals {
  assignable_role_ids = join(", ", [
    "7f951dda-4ed3-4680-a7ca-43fe172d538d", # AcrPull
    "4633458b-17de-408a-b874-0445c86b69e6", # Key Vault Secrets User
    "a4417e6f-fecd-4de8-b567-7b0420556985", # Key Vault Certificates Officer
  ])
}

resource "azurerm_role_assignment" "github_rbac_admin" {
  scope                = data.azurerm_resource_group.deploy.id
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
  principal_type       = "ServicePrincipal"
  condition_version    = "2.0"
  condition            = <<-EOT
    (
     (
      !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
     )
     OR
     (
      @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.assignable_role_ids}}
     )
    )
    AND
    (
     (
      !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
     )
     OR
     (
      @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.assignable_role_ids}}
     )
    )
  EOT
}
