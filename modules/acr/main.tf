resource "azurerm_container_registry" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name                    = var.name
  sku                     = "Premium"
  admin_enabled           = true
  zone_redundancy_enabled = true

  tags = var.tags
}
