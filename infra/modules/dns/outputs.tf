output "public_zone_name_servers" {
  description = "Name servers Azure assigned to the theradwan.com zone. These must be set at GoDaddy for the zone to be authoritative."
  value       = data.azurerm_dns_zone.public.name_servers
}

output "public_zone_name" {
  description = "Name of the public DNS zone. Referenced by the key-vault module for the ACME DNS challenge."
  value       = data.azurerm_dns_zone.public.name
}
