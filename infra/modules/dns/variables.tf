variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the public DNS zone (theradwan.com)."
  type        = string
}

variable "tm_record_name" {
  description = "The name of the public A record ('tm')."
  type        = string
}

variable "public_record_ttl" {
  description = "TTL, in seconds, for the public tm A record."
  type        = number
}

variable "agw_public_ip_address" {
  description = "Application Gateway's public IP address, created in the networking module. The public tm A record points here."
  type        = string
}

variable "aca_environment_default_domain" {
  description = "The Container Apps environment's auto-generated default domain suffix, created in the container-apps module. Must match it exactly — becomes the private DNS zone's name."
  type        = string
}

variable "vnet_link_name" {
  description = "The name of the private DNS zone's virtual network link."
  type        = string
}

variable "vnet_id" {
  description = "The ID of the VNet, created in the networking module, that the private zone links to."
  type        = string
}

variable "private_record_ttl" {
  description = "TTL, in seconds, for the private wildcard A record."
  type        = number
}

variable "aca_static_ip_address" {
  description = "The Container Apps environment's internal static IP, created in the container-apps module. The private wildcard A record points here."
  type        = string
}


variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
}
