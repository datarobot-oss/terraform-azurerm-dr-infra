output "monitor_workspace_id" {
  description = "The id of the monitor workspace"
  value       = azurerm_monitor_workspace.observability_monitor_workspace.id
}

output "monitor_workspace_query_endpoint" {
  description = "The query endpoint of the monitor workspace"
  value       = azurerm_monitor_workspace.observability_monitor_workspace.query_endpoint
}

output "grafana_endpoint" {
  description = "The endpoint URL for the Azure Managed Grafana instance"
  value       = azurerm_dashboard_grafana.observability_grafana.endpoint
}
