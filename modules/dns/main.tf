resource "azurerm_dns_zone" "public" {
  count = var.create_public_zone ? 1 : 0

  resource_group_name = var.resource_group_name

  name = var.domain_name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "private" {
  count = var.create_private_zone ? 1 : 0

  resource_group_name = var.resource_group_name

  name = var.domain_name

  tags = var.tags
}
