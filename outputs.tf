################################################################################
# Resource Group
################################################################################

output "resource_group_id" {
  description = "The ID of the Resource Group"
  value       = try(azurerm_resource_group.this[0].id, null)
}


################################################################################
# Network
################################################################################

output "vnet_id" {
  description = "The ID of the VNet"
  value       = try(module.network[0].id, null)
}


################################################################################
# DNS
################################################################################

output "public_zone_id" {
  description = "ID of the public zone"
  value       = local.public_zone_id
}

output "private_zone_id" {
  description = "ID of the private zone"
  value       = local.private_zone_id
}

output "public_dns_zone_name_servers" {
  description = "Name servers of the public DNS zone"
  value       = try(azurerm_dns_zone.public[0].name_servers, null)
}

output "public_dns_zone_name" {
  description = "Name of the public zone"
  value       = try(azurerm_dns_zone.public[0].name, null)
}

output "private_dns_zone_name" {
  description = "Name of the private zone"
  value       = try(azurerm_private_dns_zone.private[0].name, null)
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
  value       = try(module.container_registry[0].id, null)
}

output "container_registry_login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = try(module.container_registry[0].login_server, null)
}

output "container_registry_admin_username" {
  description = "Admin username of the container registry"
  value       = try(module.container_registry[0].admin_username, null)
}

output "container_registry_admin_password" {
  description = "Admin password of the container registry"
  value       = try(module.container_registry[0].admin_password, null)
}


################################################################################
# App Identity
################################################################################

output "user_assigned_identity_id" {
  description = "ID of the user assigned identity"
  value       = try(module.app_identity[0].id, null)
}

output "user_assigned_identity_name" {
  description = "Name of the user assigned identity"
  value       = try(module.app_identity[0].name, null)
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user assigned identity"
  value       = try(module.app_identity[0].client_id, null)
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID of the user assigned identity"
  value       = try(module.app_identity[0].principal_id, null)
}

output "user_assigned_identity_tenant_id" {
  description = "Tenant ID of the user assigned identity"
  value       = try(module.app_identity[0].tenant_id, null)
}


################################################################################
# Kubernetes
################################################################################

output "aks_cluster_id" {
  description = "ID of the Azure Kubernetes Service cluster"
  value       = try(module.kubernetes[0].id, null)
}


################################################################################
# PostgreSQL
################################################################################

output "postgres_endpoint" {
  description = "PostgreSQL Flexible Server endpoint"
  value       = try(module.postgres[0].endpoint, null)
}

output "postgres_password" {
  description = "PostgreSQL Flexible Server admin password"
  value       = try(module.postgres[0].password, null)
  sensitive   = true
}


################################################################################
# Redis
################################################################################

output "redis_endpoint" {
  description = "Azure Cache for Redis endpoint"
  value       = try(module.redis[0].endpoint, null)
}

output "redis_ssl_port" {
  description = "Azure Cache for Redis SSL port"
  value       = try(module.redis[0].ssl_port, null)
}

output "redis_non_ssl_port" {
  description = "Azure Cache for Redis non-SSL port"
  value       = try(module.redis[0].port, null)
}

output "redis_password" {
  description = "Azure Cache for Redis primary access key"
  value       = try(module.redis[0].password, null)
  sensitive   = true
}


################################################################################
# MongoDB
################################################################################

output "mongodb_endpoint" {
  description = "MongoDB endpoint"
  value       = try(module.mongodb[0].endpoint, null)
}

output "mongodb_password" {
  description = "MongoDB admin password"
  value       = try(module.mongodb[0].password, null)
  sensitive   = true
}


################################################################################
# ingress-nginx
################################################################################

output "ingress_pl_service_alias" {
  description = "A globally unique DNS Name for your Private Link Service. You can use this alias to request a connection to your Private Link Service"
  value       = try(module.private_link_service[0].ingress_pl_service_alias, null)
}

################################################################################
# Observability
################################################################################

output "observability_monitor_workspace_id" {
  description = "The id of the monitor workspace for observability"
  value       = try(module.observability[0].monitor_workspace_id, null)
}

output "observability_monitor_workspace_query_endpoint" {
  description = "The query endpoint of the monitor workspace for observability"
  value       = try(module.observability[0].monitor_workspace_query_endpoint, null)
}

output "observability_grafana_endpoint" {
  description = "The endpoint URL for the Azure Managed Grafana instance for observability"
  value       = try(module.observability[0].grafana_endpoint, null)
}

output "observability_user_assigned_identity_client_id" {
  description = "The client_id of the user assigned identity"
  value       = try(module.observability[0].user_assigned_identity_client_id, null)
}
