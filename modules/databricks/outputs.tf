output "workspace_url" {
  description = "URL of the DataBricks Workspace"
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "workspace_id" {
  description = "ID of the DataBricks Workspace"
  value       = azurerm_databricks_workspace.this.id
}
