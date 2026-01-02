resource "azurerm_storage_account" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name                     = var.account_name
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type

  public_network_access_enabled = var.public_network_access_enabled
  dynamic "network_rules" {
    for_each = var.network_rules_default_action == "Deny" || length(var.public_ip_allow_list) > 0 || var.virtual_network_subnet_ids != null ? ["rule"] : []

    content {
      default_action             = var.network_rules_default_action
      ip_rules                   = var.public_ip_allow_list
      virtual_network_subnet_ids = var.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  name               = var.container_name
  storage_account_id = azurerm_storage_account.this.id
}
