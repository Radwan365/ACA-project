data "azurerm_client_config" "current" {}

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

# Identity of the AKS control plane. User-assigned so its network permission exists before the cluster does.
resource "azurerm_user_assigned_identity" "aks" {
  name                = var.aks_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# The control plane creates the internal load balancer in the node subnet, which needs this role on the subnet
resource "azurerm_role_assignment" "aks_subnet" {
  scope                = var.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  principal_type       = "ServicePrincipal"
}

# RBAC assignments take a few minutes to propagate; wait before the cluster relies on them
resource "time_sleep" "aks_subnet_propagation" {
  create_duration = "120s"

  depends_on = [azurerm_role_assignment.aks_subnet]
}

resource "azurerm_kubernetes_cluster" "aks" {

  #checkov:skip=CKV_AZURE_4:Container Insights not enabled for cost; control plane logs go to Log Analytics via the diagnostic setting below
  #checkov:skip=CKV_AZURE_6:GitHub-hosted runner IPs change per run, so an API server allow-list is not practical; access needs Entra ID plus Azure RBAC
  #checkov:skip=CKV_AZURE_115:Private cluster would need self-hosted runners inside the VNet; out of scope
  #checkov:skip=CKV_AZURE_116:Azure Policy add-on not enabled to keep the single small node free for the workload
  #checkov:skip=CKV_AZURE_117:Customer-managed disk encryption set not used; platform-managed encryption is on by default
  #checkov:skip=CKV_AZURE_170:Free tier control plane chosen for cost; no uptime SLA needed for a dev environment
  #checkov:skip=CKV_AZURE_172:No secrets are mounted from Key Vault, so the Secrets Store CSI driver is not installed
  #checkov:skip=CKV_AZURE_226:Ephemeral OS disks need a VM size with a large enough cache disk; the chosen size has none
  #checkov:skip=CKV_AZURE_227:Encryption at host requires a subscription feature registration; not enabled for this dev environment
  #checkov:skip=CKV_AZURE_232:Single node pool for cost, so the workload shares it with system pods

  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_cluster_name
  node_resource_group = var.aks_node_resource_group_name
  sku_tier            = "Free"

  # Kubernetes patch versions and node images are kept current automatically
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"

  # No shared admin certificate: every caller signs in with Entra ID and is authorised by Azure RBAC
  local_account_disabled = true

  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  default_node_pool {
    name           = "system"
    vm_size        = var.aks_node_vm_size
    node_count     = var.aks_node_count
    vnet_subnet_id = var.aks_subnet_id
    max_pods       = 110

    # Needed so Terraform can replace the pool in place when vm_size or similar settings change
    temporary_name_for_rotation = "systemtmp"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  network_profile {
    # Azure CNI Overlay with Cilium: nodes get VNet addresses, pods get addresses from pod_cidr
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    load_balancer_sku   = "standard"

    # Outbound traffic leaves through the NAT Gateway already attached to the node subnet
    outbound_type = "userAssignedNATGateway"

    # These ranges must not overlap the VNet (10.0.0.0/16)
    pod_cidr       = var.aks_pod_cidr
    service_cidr   = var.aks_service_cidr
    dns_service_ip = var.aks_dns_service_ip
  }

  tags = var.tags

  depends_on = [time_sleep.aks_subnet_propagation]
}

# The kubelet identity is what the nodes use to pull images
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = var.aks_diagnostic_setting_name
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  # Who changed what in the cluster, and sign-in decisions
  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "guard"
  }
}
