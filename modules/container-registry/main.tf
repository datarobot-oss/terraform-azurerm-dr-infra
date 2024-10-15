resource "azurerm_container_registry" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name                          = var.name
  sku                           = "Premium"
  admin_enabled                 = true
  zone_redundancy_enabled       = true
  public_network_access_enabled = length(var.public_ip_allow_list) > 0
  network_rule_set {
    default_action = "Deny"

    ip_rule = [for cidr_block in var.public_ip_allow_list : {
      action   = "Allow"
      ip_range = cidr_block
    }]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "acr_privatelink" {
  resource_group_name = var.resource_group_name

  name = "privatelink.azurecr.io"

  tags = var.tags
}

resource "azurerm_private_endpoint" "acr" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name      = "${var.name}-pe"
  subnet_id = var.subnet_id

  private_service_connection {
    name                           = "acr-psc"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-zg"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr_privatelink.id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  resource_group_name = var.resource_group_name

  name                  = "acr-link"
  private_dns_zone_name = azurerm_private_dns_zone.acr_privatelink.name
  virtual_network_id    = var.vnet_id

  tags = var.tags
}
