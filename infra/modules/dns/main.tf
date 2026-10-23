# Created by bootstrap/bootstrap.sh, deliberately kept outside Terraform so a destroy
# doesn't change the name servers delegated at GoDaddy
data "azurerm_dns_zone" "public" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_a_record" "tm" {
  name                = var.tm_record_name
  zone_name           = data.azurerm_dns_zone.public.name
  resource_group_name = var.resource_group_name
  ttl                 = var.public_record_ttl
  records             = [var.agw_public_ip_address]

  tags = var.tags
}

resource "azurerm_private_dns_zone" "aca" {
  name                = var.aca_environment_default_domain
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "aca" {
  name                = var.vnet_link_name
  private_dns_zone_id = azurerm_private_dns_zone.aca.id
  virtual_network_id  = var.vnet_id

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "aca_wildcard" {
  name                = "*"
  private_dns_zone_id = azurerm_private_dns_zone.aca.id
  ttl                 = var.private_record_ttl
  records             = [var.aca_static_ip_address]

  tags = var.tags
}
