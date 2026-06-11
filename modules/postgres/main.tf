resource "azurerm_private_dns_zone" "this" {
  name                = var.private_dns_zone_name
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
  length           = var.password_constraints.length
  min_lower        = var.password_constraints.min_lower
  min_upper        = var.password_constraints.min_upper
  min_numeric      = var.password_constraints.min_numeric
  min_special      = var.password_constraints.min_special
  special          = var.password_constraints.special
  override_special = var.password_constraints.override_special
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

resource "azurerm_postgresql_flexible_server_configuration" "this" {
  for_each = var.server_configurations

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = each.value
}
