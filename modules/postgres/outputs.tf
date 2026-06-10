output "endpoint" {
  description = "PostgreSQL Flexible Server endpoint"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "port" {
  description = "PostgreSQL Flexible Server port"
  value       = "5432"
}

output "password" {
  description = "PostgreSQL Flexible Server admin password"
  value       = random_password.admin.result
  sensitive   = true
}
