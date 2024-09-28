output "public_zone_id" {
  description = "ID of the public zone"
  value       = azurerm_dns_zone.public.id
}

output "private_zone_id" {
  description = "ID of the private zone"
  value       = azurerm_private_dns_zone.private.id
}
