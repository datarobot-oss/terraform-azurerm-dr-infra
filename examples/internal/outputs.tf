output "user_assigned_identity_client_id" {
  description = "Client ID of the user assigned identity"
  value       = module.datarobot_infra.user_assigned_identity_client_id
}

output "user_assigned_identity_tenant_id" {
  description = "Tenant ID of the user assigned identity"
  value       = module.datarobot_infra.user_assigned_identity_tenant_id
}
