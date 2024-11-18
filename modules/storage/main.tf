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
  resource_group_name = var.resource_group_name

  name = "privatelink.blob.core.windows.net"

  tags = var.tags
}

resource "azurerm_private_endpoint" "storage" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name      = "${var.account_name}-pe"
  subnet_id = var.subnet_id

  private_service_connection {
    name                           = "storage-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dns-zg"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_privatelink.id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  resource_group_name = var.resource_group_name

  name                  = "storage-link"
  private_dns_zone_name = azurerm_private_dns_zone.storage_privatelink.name
  virtual_network_id    = var.vnet_id

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  name               = var.container_name
  storage_account_id = azurerm_storage_account.this.id

  depends_on = [azurerm_private_endpoint.storage, azurerm_private_dns_zone_virtual_network_link.storage]
}
