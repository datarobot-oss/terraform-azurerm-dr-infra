resource "azurerm_dns_zone" "public" {
  resource_group_name = var.resource_group_name

  name = var.domain_name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "private" {
  resource_group_name = var.resource_group_name

  name = var.domain_name

  tags = var.tags
}
