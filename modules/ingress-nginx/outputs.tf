output "load_balancer_frontend_ip_configuration_ids" {
  description = "List of Azure Load Balancer frontend IP configuration resource IDs (strings)."
  value       = try(data.azurerm_lb.internal_ingress[0].frontend_ip_configuration[0].id, null)
}
