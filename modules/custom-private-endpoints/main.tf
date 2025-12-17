resource "azurerm_private_endpoint" "this" {
  name                = "${var.endpoint_config.private_dns_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = var.endpoint_config.resource_id
    subresource_names              = var.endpoint_config.subresource_names
    is_manual_connection           = true
    request_message                = "Private endpoint request for DataRobot"
  }

  dynamic "private_dns_zone_group" {
    for_each = var.endpoint_config.create_dns_zone ? [] : [1]
    content {
      name                 = "custom-private-endpoint-group"
      private_dns_zone_ids = [data.azurerm_private_dns_zone.existing_zone[0].id]
    }
  }
}

data "azurerm_private_dns_zone" "existing_zone" {
  count = var.endpoint_config.create_dns_zone ? 0 : 1
  name  = var.endpoint_config.private_dns_zone
}

resource "azurerm_private_dns_zone" "this" {
  count               = var.endpoint_config.create_dns_zone ? 1 : 0
  name                = var.endpoint_config.private_dns_zone
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count                 = var.endpoint_config.create_dns_zone ? 1 : 0
  name                  = "${var.name}-${var.endpoint_config.private_dns_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[0].name
  virtual_network_id    = var.network_id
  tags                  = var.tags
}

resource "azurerm_private_dns_a_record" "this" {
  count               = var.endpoint_config.create_dns_zone ? 1 : 0
  name                = var.endpoint_config.private_dns_name
  zone_name           = azurerm_private_dns_zone.this[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
}
