output "container_registry_login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = module.datarobot_infra.container_registry_login_server
}

output "container_registry_admin_username" {
  description = "Admin username of the container registry"
  value       = module.datarobot_infra.container_registry_admin_username
}

output "container_registry_admin_password" {
  description = "Admin password of the container registry"
  value       = nonsensitive(module.datarobot_infra.container_registry_admin_password)
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.datarobot_infra.storage_account_name
}

output "storage_container_name" {
  description = "Name of the storage container"
  value       = module.datarobot_infra.storage_container_name
}

output "storage_access_key" {
  description = "The primary access key for the storage account"
  value       = nonsensitive(module.datarobot_infra.storage_access_key)
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user assigned identity"
  value       = module.datarobot_infra.user_assigned_identity_client_id
}

output "user_assigned_identity_tenant_id" {
  description = "Tenant ID of the user assigned identity"
  value       = module.datarobot_infra.user_assigned_identity_tenant_id
}
