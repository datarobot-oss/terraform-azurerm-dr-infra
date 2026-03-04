output "monitor_workspace_id" {
  description = "The id of the monitor workspace"
  value       = azurerm_monitor_workspace.observability_monitor_workspace.id
}

output "monitor_workspace_query_endpoint" {
  description = "The query endpoint of the monitor workspace"
  value       = azurerm_monitor_workspace.observability_monitor_workspace.query_endpoint
}

output "user_assigned_identity_client_id" {
  description = "The client_id of the user assigned identity"
  value       = azurerm_user_assigned_identity.this.client_id
}

output "grafana_endpoint" {
  description = "The endpoint URL for the Azure Managed Grafana instance"
  value       = azurerm_dashboard_grafana.observability_grafana.endpoint
}
