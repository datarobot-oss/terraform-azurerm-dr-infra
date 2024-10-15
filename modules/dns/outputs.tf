output "public_zone_id" {
  description = "ID of the public zone"
  value       = try(azurerm_dns_zone.public[0].id, null)
}

output "private_zone_id" {
  description = "ID of the private zone"
  value       = try(azurerm_private_dns_zone.private[0].id, null)
}
