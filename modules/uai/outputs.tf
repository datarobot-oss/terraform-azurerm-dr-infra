output "id" {
  description = "ID of the user assigned identity"
  value       = azurerm_user_assigned_identity.datarobot.id
}

output "name" {
  description = "Name of the user assigned identity"
  value       = azurerm_user_assigned_identity.datarobot.name
}

output "client_id" {
  description = "Client ID of the user assigned identity"
  value       = azurerm_user_assigned_identity.datarobot.client_id
}

output "principal_id" {
  description = "Principal ID of the user assigned identity"
  value       = azurerm_user_assigned_identity.datarobot.principal_id
}

output "tenant_id" {
  description = "Tenant ID of the user assigned identity"
  value       = azurerm_user_assigned_identity.datarobot.tenant_id
}
