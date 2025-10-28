resource "azurerm_databricks_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "standard"

  tags = var.tags
}

resource "databricks_service_principal" "this" {
  application_id        = var.application_id
  display_name          = var.name
  allow_cluster_create  = true
  databricks_sql_access = true
  workspace_access      = true
}
