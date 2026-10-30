output "credential_set_principal_id" {
  description = "Principal ID of the credential set managed identity. Grant it read access to existing Key Vault secrets."
  value       = azurerm_container_registry_credential_set.this.identity[0].principal_id
}

output "key_vault_id" {
  description = "ID of the Key Vault holding the Docker Hub credentials"
  value       = try(azurerm_key_vault.this[0].id, null)
}
