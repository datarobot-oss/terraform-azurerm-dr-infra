output "user_assigned_identity_client_id" {
  description = "Client ID of the user assigned identity created for the DataRobot application"
  value       = module.datarobot_infra.user_assigned_identity_client_id
}

output "user_assigned_identity_tenant_id" {
  description = "Tenant ID of the user assigned identity created for the DataRobot application"
  value       = module.datarobot_infra.user_assigned_identity_tenant_id
}

output "dns_zone_name_servers" {
  description = "Name servers of the DNS zone. Create NS records for these with your domain registrar to delegate the zone."
  value       = module.datarobot_infra.dns_zone_name_servers
}
