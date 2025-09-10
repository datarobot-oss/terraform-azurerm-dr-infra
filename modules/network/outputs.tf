output "id" {
  description = "ID of the VNet"
  value       = azurerm_virtual_network.this.id
}

output "kubernetes_nodes_subnet_id" {
  description = "ID of the subnet intended for the Kubernetes nodes"
  value       = azurerm_subnet.kubernetes_nodes.id
}

output "postgres_subnet_id" {
  description = "ID of the subnet intended for the PostgreSQL Flexible Server"
  value       = azurerm_subnet.postgres.id
}

output "redis_subnet_id" {
  description = "ID of the subnet intended for the Azure Cache for Redis instance"
  value       = azurerm_subnet.redis.id
}

output "mongodb_subnet_id" {
  description = "ID of the subnet intended for the MongoDB Atlas private endpoint"
  value       = azurerm_subnet.mongodb.id
}

output "nat_gateway_pip" {
  description = "Public IP of the NAT Gateway"
  value       = azurerm_public_ip.ng.ip_address
}
