output "endpoint" {
  description = "Azure Cache for Redis instance endpoint"
  value       = azurerm_redis_cache.this.hostname
}

output "password" {
  description = "Azure Cache for Redis primary access key"
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
}

output "ssl_port" {
  description = "Azure Cache for Redis instance SSL port"
  value       = azurerm_redis_cache.this.ssl_port
}

output "non_ssl_port" {
  description = "Azure Cache for Redis instance non-SSL port"
  value       = azurerm_redis_cache.this.port
}
