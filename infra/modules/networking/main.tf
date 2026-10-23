resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
resource "azurerm_subnet" "appgateway_subnet" {
  name                 = var.appgw_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.appgw_subnet_address_prefix
}
resource "azurerm_subnet" "aca_subnet" {
  name                 = var.aca_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.aca_subnet_address_prefix

  delegation {
    name = "aca-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_network_security_group" "nsg_agw" {
  name                = var.nsg_agw_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Required by App Gateway v2 for its infrastructure; deployment fails without it
  security_rule {
    name                       = "AllowGatewayManager"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Only used to redirect to HTTPS
  security_rule {
    name                       = "AllowHttpInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = var.tags
}
resource "azurerm_network_security_group" "nsg_cae" {
  name                = var.nsg_cae_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_nat_gateway" "natgw" {
  name                = var.nat_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "appgw_nsg_association" {
  subnet_id                 = azurerm_subnet.appgateway_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_agw.id
}

resource "azurerm_subnet_network_security_group_association" "aca_nsg_association" {
  subnet_id                 = azurerm_subnet.aca_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_cae.id
}

resource "azurerm_nat_gateway_public_ip_association" "natgw_public_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natgw.id
}

resource "azurerm_subnet_nat_gateway_association" "aca_nat_association" {
  subnet_id      = azurerm_subnet.aca_subnet.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

resource "azurerm_public_ip" "agw" {
  name                = var.agw_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_public_ip" "natgw" {
  name                = var.natgw_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}
