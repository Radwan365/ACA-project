output "public_zone_name_servers" {
  description = "Name servers for the theradwan.com zone. These need to be set at GoDaddy to complete delegation."
  value       = module.dns.public_zone_name_servers
}

output "app_gateway_public_ip_address" {
  description = "Application Gateway's public IP address. Useful for testing with --resolve before DNS has propagated."
  value       = module.networking.agw_public_ip_address
}

output "website_url" {
  description = "The public URL for the deployed application, once DNS has propagated."
  value       = "https://${var.tm_record_name}.${var.dns_zone_name}"
}
