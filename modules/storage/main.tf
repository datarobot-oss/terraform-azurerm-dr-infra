locals {
  private_storage_endpoints = toset([
    "blob",
    "dfs"
  ])
}

resource "azurerm_storage_account" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name                     = var.account_name
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type

  public_network_access_enabled = var.public_network_access_enabled
  network_rules {
    default_action             = var.network_rules_default_action
    ip_rules                   = var.public_ip_allow_list
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "storage_privatelink" {
  for_each = local.private_storage_endpoints

  resource_group_name = var.resource_group_name

  name = "privatelink.${each.key}.core.windows.net"

  tags = var.tags
}

resource "azurerm_private_endpoint" "storage" {
  for_each = local.private_storage_endpoints

  resource_group_name = var.resource_group_name
  location            = var.location

  name      = "${var.account_name}-${each.key}-pe"
  subnet_id = var.subnet_id

  private_service_connection {
    name                           = "storage-${each.key}-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-${each.key}-dns-zg"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_privatelink[each.key].id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  for_each = local.private_storage_endpoints

  resource_group_name = var.resource_group_name

  name                  = "storage-${each.key}-link"
  private_dns_zone_name = azurerm_private_dns_zone.storage_privatelink[each.key].name
  virtual_network_id    = var.vnet_id

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  name               = var.container_name
  storage_account_id = azurerm_storage_account.this.id

  depends_on = [azurerm_private_endpoint.storage, azurerm_private_dns_zone_virtual_network_link.storage]
}
