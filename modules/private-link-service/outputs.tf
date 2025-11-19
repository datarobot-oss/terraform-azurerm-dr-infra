output "ingress_pl_service_alias" {
  description = "A globally unique DNS Name for your Private Link Service. You can use this alias to request a connection to your Private Link Service"
  value       = try(azurerm_private_link_service.internal_ingress.alias, null)
}
