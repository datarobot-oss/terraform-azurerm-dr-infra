resource "azurerm_storage_account" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name                     = var.account_name
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  name                 = var.container_name
  storage_account_name = azurerm_storage_account.this.name
}
