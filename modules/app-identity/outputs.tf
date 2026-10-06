output "identity_type" {
  description = "Type of identity created for the DataRobot application"
  value       = var.identity_type
}

output "id" {
  description = "ID of the user assigned identity or AzureAD application"
  value       = local.create_uai ? azurerm_user_assigned_identity.datarobot[0].id : azuread_application.datarobot[0].id
}

output "name" {
  description = "Name of the user assigned identity or display name of the AzureAD application"
  value       = local.create_uai ? azurerm_user_assigned_identity.datarobot[0].name : azuread_application.datarobot[0].display_name
}

output "client_id" {
  description = "Client ID of the user assigned identity or AzureAD application"
  value       = local.create_uai ? azurerm_user_assigned_identity.datarobot[0].client_id : azuread_application.datarobot[0].client_id
}

output "principal_id" {
  description = "Principal ID of the user assigned identity or object ID of the AzureAD service principal"
  value       = local.principal_id
}

output "tenant_id" {
  description = "Tenant ID of the user assigned identity or AzureAD application"
  value       = local.create_uai ? azurerm_user_assigned_identity.datarobot[0].tenant_id : data.azuread_client_config.current[0].tenant_id
}

output "application_object_id" {
  description = "Object ID of the AzureAD application"
  value       = try(azuread_application.datarobot[0].object_id, null)
}

output "client_secret" {
  description = "Client secret of the AzureAD application"
  value       = try(azuread_application_password.datarobot[0].value, null)
  sensitive   = true
}
