resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${var.name}-postgres"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.vnet_id

  tags = var.tags
}

resource "random_password" "admin" {
  length      = 20
  special     = false
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  version                       = var.postgres_version
  public_network_access_enabled = false
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.this.id
  administrator_login           = "postgres"
  administrator_password        = random_password.admin.result
  sku_name                      = var.sku_name
  storage_mb                    = var.storage_mb
  auto_grow_enabled             = true
  backup_retention_days         = var.backup_retention_days

  high_availability {
    mode = var.multi_az ? "ZoneRedundant" : "SameZone"
  }

  tags = var.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.this
  ]

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone
    ]
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "azure_extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "UUID-OSSP,PLPGSQL,PG_STAT_STATEMENTS"
}

resource "azurerm_postgresql_flexible_server_configuration" "postgresql_password_encryption" {
  name      = "password_encryption"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "SCRAM-SHA-256"
}

resource "azurerm_postgresql_flexible_server_configuration" "postgresql_password_auth_method" {
  name      = "azure.accepted_password_auth_method"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "MD5,SCRAM-SHA-256"
}
