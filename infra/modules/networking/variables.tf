variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "appgw_subnet_name" {
  description = "The name of the application gateway subnet."
  type        = string
}

variable "appgw_subnet_address_prefix" {
  description = "The address prefix for the application gateway subnet."
  type        = list(string)
}


variable "aca_subnet_name" {
  description = "The name of the ACA subnet."
  type        = string
}

variable "agw_public_ip_name" {
  description = "The name of the public IP address for the application gateway."
  type        = string
}

variable "aca_subnet_address_prefix" {
  description = "The address prefix for the ACA subnet."
  type        = list(string)
}

variable "natgw_public_ip_name" {
  description = "The name of the public IP address for the NAT gateway."
  type        = string
}

variable "nsg_agw_name" {
  description = "The name of the network security group for the application gateway."
  type        = string
}

variable "nsg_cae_name" {
  description = "The name of the network security group for the ACA subnet."
  type        = string
}

variable "nat_gateway_name" {
  description = "The name of the NAT gateway."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
}
