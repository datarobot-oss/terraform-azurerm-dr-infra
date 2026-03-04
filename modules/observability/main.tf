locals {
  name = "${var.name}-observability"
}

resource "azurerm_user_assigned_identity" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "${local.name}-uai"

  tags = var.tags
}

resource "azurerm_application_insights" "observability_application_insights" {
  name                = "${local.name}-application-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "other"
  tags                = var.tags
}

resource "azurerm_role_assignment" "observability_role_assignment" {
  role_definition_name = "Monitoring Metrics Publisher"
  scope                = azurerm_application_insights.observability_application_insights.id
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_monitor_workspace" "observability_monitor_workspace" {
  name                = "${local.name}-amw"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_dashboard_grafana" "observability_grafana" {
  name                  = "obs-grafana"
  resource_group_name   = var.resource_group_name
  location              = var.location
  grafana_major_version = var.grafana_major_version
  tags                  = var.tags

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.observability_monitor_workspace.id
  }
}

resource "azurerm_role_assignment" "grafana_admin_access" {
  for_each             = toset(var.grafana_admin_principal_ids)
  role_definition_name = "Grafana Admin"
  scope                = azurerm_dashboard_grafana.observability_grafana.id
  principal_id         = each.value
}

resource "azurerm_role_assignment" "grafana_editor_access" {
  for_each             = toset(var.grafana_editor_principal_ids)
  role_definition_name = "Grafana Editor"
  scope                = azurerm_dashboard_grafana.observability_grafana.id
  principal_id         = each.value
}

resource "azurerm_role_assignment" "grafana_viewer_access" {
  for_each             = toset(var.grafana_viewer_principal_ids)
  role_definition_name = "Grafana Viewer"
  scope                = azurerm_dashboard_grafana.observability_grafana.id
  principal_id         = each.value
}

resource "azurerm_role_assignment" "grafana_monitor_reader" {
  role_definition_name = "Monitoring Data Reader"
  scope                = azurerm_monitor_workspace.observability_monitor_workspace.id
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

data "azurerm_monitor_data_collection_rule" "data_collection_rule" {
  name                = azurerm_monitor_workspace.observability_monitor_workspace.name
  resource_group_name = "MA_${azurerm_monitor_workspace.observability_monitor_workspace.name}_${var.location}_managed"
}

resource "azurerm_role_assignment" "prometheus_publisher_role_amw" {
  role_definition_name = "Monitoring Metrics Publisher"
  scope                = data.azurerm_monitor_data_collection_rule.data_collection_rule.id
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}
