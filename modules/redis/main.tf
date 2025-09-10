resource "azurerm_redis_cache" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  capacity                      = var.capacity
  family                        = "C"
  sku_name                      = "Standard"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  redis_version                 = var.redis_version

  tags = var.tags
}

resource "azurerm_private_endpoint" "this" {
  name                = "${var.name}-redis"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name}-redis"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = ["redisCache"]
  }
}

data "azurerm_private_endpoint_connection" "this" {
  name                = azurerm_private_endpoint.this.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${var.name}-redis"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

resource "azurerm_private_dns_a_record" "this" {
  name                = azurerm_redis_cache.this.name
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.this.private_service_connection[0].private_ip_address]
}
