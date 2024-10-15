output "account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.this.name
}

output "access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.this.primary_access_key
}
