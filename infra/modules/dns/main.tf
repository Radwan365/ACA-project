# The public zone is created once, outside the main stack (see the README), so a destroy
# doesn't change the name servers delegated at the registrar
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
