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

  #checkov:skip=CKV_AZURE_160:Port 80 only serves the App Gateway HTTP to HTTPS redirect

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
# Inbound lockdown on the Container Apps subnet: the Application Gateway is the only thing
# in the VNet allowed to reach the environment. Outbound is deliberately left at the Azure
# defaults, because the environment needs to reach the registry, Azure Monitor and Azure DNS
# (168.63.129.16), and denying any of those stops the environment working.
resource "azurerm_network_security_group" "nsg_cae" {
  name                = var.nsg_cae_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # 443 and 80 are the internal load balancer's ports. 31443 and 31080 are the fixed ports
  # the Container Apps environment's edge proxy listens on behind that load balancer, and
  # traffic arriving from the VNet has to be allowed through to them as well.
  security_rule {
    name                         = "AllowAppGatewayInbound"
    priority                     = 100
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_ranges      = ["80", "443", "31080", "31443"]
    source_address_prefixes      = var.appgw_subnet_address_prefix
    destination_address_prefixes = var.aca_subnet_address_prefix
  }

  # Azure's own health probes to the internal load balancer
  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # Traffic between instances inside the environment's own subnet
  security_rule {
    name                         = "AllowSubnetInternalInbound"
    priority                     = 120
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "*"
    source_port_range            = "*"
    destination_port_range       = "*"
    source_address_prefixes      = var.aca_subnet_address_prefix
    destination_address_prefixes = var.aca_subnet_address_prefix
  }

  # Everything else arriving from the VNet is dropped. This replaces Azure's default
  # AllowVnetInBound rule, which would let any other subnet reach the app directly.
  security_rule {
    name                       = "DenyOtherVnetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

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
