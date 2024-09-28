################################################################################
# Resource Group
################################################################################

output "resource_group_id" {
  description = "The ID of the Resource Group"
  value       = try(azurerm_resource_group.this[0].id, null)
}


################################################################################
# Virtual Network
################################################################################

output "vnet_id" {
  description = "The ID of the VNet"
  value       = try(module.vnet[0].id, null)
}


################################################################################
# DNS
################################################################################

output "public_zone_id" {
  description = "ID of the public zone"
  value       = try(module.dns[0].public_zone_id, null)
}

output "private_zone_id" {
  description = "ID of the private zone"
  value       = try(module.dns[0].private_zone_id, null)
}


################################################################################
# Storage
################################################################################

output "storage_account_name" {
  description = "Name of the storage account"
  value       = try(module.storage[0].account_name, null)
}

output "storage_container_name" {
  description = "Name of the storage container"
  value       = try(module.storage[0].container_name, null)
}

output "storage_access_key" {
  description = "The primary access key for the storage account"
  value       = try(module.storage[0].access_key, null)
}


################################################################################
# Container Registry
################################################################################

output "container_registry_id" {
  description = "ID of the container registry"
  value       = try(module.acr[0].id, null)
}

output "container_registry_login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = try(module.acr[0].login_server, null)
}

output "container_registry_admin_username" {
  description = "Admin username of the container registry"
  value       = try(module.acr[0].admin_username, null)
}

output "container_registry_admin_password" {
  description = "Admin password of the container registry"
  value       = try(module.acr[0].admin_password, null)
}


################################################################################
# User Assigned Identity
################################################################################

output "user_assigned_identity_id" {
  description = "ID of the user assigned identity"
  value       = try(module.uai[0].id, null)
}

output "user_assigned_identity_name" {
  description = "Name of the user assigned identity"
  value       = try(module.uai[0].name, null)
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user assigned identity"
  value       = try(module.uai[0].client_id, null)
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID of the user assigned identity"
  value       = try(module.uai[0].principal_id, null)
}

output "user_assigned_identity_tenant_id" {
  description = "Tenant ID of the user assigned identity"
  value       = try(module.uai[0].tenant_id, null)
}


################################################################################
# AKS
################################################################################

output "aks_cluster_id" {
  description = "ID of the Azure Kubernetes Service cluster"
  value       = try(module.aks[0].id, null)
}
