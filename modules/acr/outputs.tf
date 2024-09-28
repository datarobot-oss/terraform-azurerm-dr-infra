output "id" {
  description = "ID of the container registry"
  value       = azurerm_container_registry.this.id
}

output "login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "Admin username of the container registry"
  value       = azurerm_container_registry.this.admin_username
}

output "admin_password" {
  description = "Admin password of the container registry"
  value       = azurerm_container_registry.this.admin_password
}
