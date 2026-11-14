resource "azurerm_application_gateway" "appgw" {

  #checkov:skip=CKV_AZURE_120:WAF out of scope for brief; Standard_v2 chosen for cost
  #checkov:skip=CKV_AZURE_218:Predefined AppGwSslPolicy20220101 enforces TLS 1.2 minimum

  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name = var.app_gateway_sku_name
    tier = var.app_gateway_sku_tier
  }

  autoscale_configuration {
    min_capacity = var.autoscale_configuration.min_capacity
    max_capacity = var.autoscale_configuration.max_capacity
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.agw_kv_identity_id]
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = var.appgw_subnet_id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 443
  }

  frontend_port {
    name = var.http_frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = var.agw_public_ip_id
  }

  # The private IP of the internal load balancer in front of the pods (see k8s/service.yaml)
  backend_address_pool {
    name         = var.backend_pool_name
    ip_addresses = [var.backend_ip_address]
  }

  # TLS ends at the gateway. From here to the cluster the request stays inside the VNet over HTTP.
  backend_http_settings {
    name                  = var.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    probe_name            = var.probe_name
  }

  # The backend is only marked healthy when nginx answers on /health
  probe {
    name                = var.probe_name
    protocol            = "Http"
    host                = var.probe_host
    path                = "/health"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 3

    match {
      status_code = ["200"]
    }
  }

  http_listener {
    name                           = var.https_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = var.ssl_certificate_name
  }

  http_listener {
    name                           = var.http_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.http_frontend_port_name
    protocol                       = "Http"
  }

  ssl_certificate {
    name                = var.ssl_certificate_name
    key_vault_secret_id = var.certificate_secret_id
  }

  redirect_configuration {
    name                 = var.redirect_configuration_name
    redirect_type        = "Permanent"
    target_listener_name = var.https_listener_name
    include_path         = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = var.routing_rule_name
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = var.https_listener_name
    backend_address_pool_name  = var.backend_pool_name
    backend_http_settings_name = var.backend_http_settings_name
  }

  request_routing_rule {
    name                        = var.http_routing_rule_name
    priority                    = 200
    rule_type                   = "Basic"
    http_listener_name          = var.http_listener_name
    redirect_configuration_name = var.redirect_configuration_name
  }

  tags = var.tags

}

# Access, performance and firewall logs plus metrics, for troubleshooting unhealthy backends
resource "azurerm_monitor_diagnostic_setting" "appgw" {
  name                       = var.diagnostic_setting_name
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
