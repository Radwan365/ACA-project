resource "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_container_registry" "acr" {

  #checkov:skip=CKV_AZURE_164:Content trust requires Premium SKU; not used for cost
  #checkov:skip=CKV_AZURE_167:Retention policy requires Premium SKU; not used for cost
  #checkov:skip=CKV_AZURE_139:Private access requires Premium plus private endpoint; GitHub runners push over internet
  #checkov:skip=CKV_AZURE_163:Images scanned with Grype in CI before push
  #checkov:skip=CKV_AZURE_237:Dedicated data endpoints require Premium SKU; not used for cost
  #checkov:skip=CKV_AZURE_165:Single-region deployment; geo-replication not needed
  #checkov:skip=CKV_AZURE_233:Dev environment in single region; zone redundancy not needed
  #checkov:skip=CKV_AZURE_166:Quarantine not used; Grype scan in CI gates images before push

  name                = var.azure_container_registry_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.azure_container_registry_sku
  admin_enabled       = false

  tags = var.tags
}

resource "azurerm_user_assigned_identity" "aca_acr_identity" {
  name                = var.aca_acr_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.aca_acr_identity.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  principal_type       = "ServicePrincipal"
}

# RBAC assignments take a few minutes to propagate; wait before the app tries to pull
resource "time_sleep" "acr_pull_propagation" {
  create_duration = "120s"

  depends_on = [azurerm_role_assignment.acr_pull]
}

resource "azurerm_container_app_environment" "cae" {
  name                           = var.container_apps_environment_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  internal_load_balancer_enabled = true
  logs_destination               = "log-analytics"
  infrastructure_subnet_id       = var.container_apps_subnet_id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id

  # Workload profiles environment: required for the delegated /24 subnet and NAT gateway
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  tags = var.tags
}

resource "azurerm_container_app" "app" {
  name                         = var.container_apps_name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.cae.id
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_acr_identity.id]
  }

  # Credentials for pulling the real application image from ACR. The placeholder image used
  # when this app is first created comes from a public registry and needs no credentials.
  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.aca_acr_identity.id
  }

  template {
    # At least one instance always running: the Application Gateway health probe would
    # report the backend as unhealthy if the app were allowed to scale to zero
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "tm"
      image  = var.initial_container_image
      cpu    = var.container_apps_cpu
      memory = var.container_apps_memory
    }
  }

  ingress {
    # The environment is internal, so "external" means reachable from the VNet (App Gateway), not the internet
    external_enabled = true
    target_port      = var.target_port
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.tags

  depends_on = [time_sleep.acr_pull_propagation]

  # The running image is owned by the build pipeline, which releases it with
  # `az containerapp update --image` after pushing to ACR. Terraform sets the image
  # only when this app is first created, and ignores it from then on, so an
  # infrastructure change can never roll the application back to an older version.
  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }
}
