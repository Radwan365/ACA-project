output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.vnet.id
}

# Subnet outputs wait for their associations so nothing is deployed into a half-configured subnet
output "appgw_subnet_id" {
  description = "ID of the Application Gateway subnet."
  value       = azurerm_subnet.appgateway_subnet.id
  depends_on  = [azurerm_subnet_network_security_group_association.appgw_nsg_association]
}

output "aks_subnet_id" {
  description = "ID of the AKS node subnet."
  value       = azurerm_subnet.aks_subnet.id
  depends_on = [
    azurerm_subnet_network_security_group_association.aks_nsg_association,
    azurerm_subnet_nat_gateway_association.aks_nat_association,
    azurerm_nat_gateway_public_ip_association.natgw_public_ip_association,
  ]
}

output "agw_public_ip_id" {
  description = "ID of the Application Gateway's public IP."
  value       = azurerm_public_ip.agw.id
}

output "agw_public_ip_address" {
  description = "The Application Gateway's public IP address."
  value       = azurerm_public_ip.agw.ip_address
}
