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

variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
}
