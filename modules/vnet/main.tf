resource "azurerm_virtual_network" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name          = var.name
  address_space = [var.address_space]

  subnet {
    name             = var.subnet_name
    address_prefixes = [cidrsubnet(var.address_space, 4, 0)]
  }

  tags = var.tags
}

# resource "azurerm_nat_gateway" "this" {
#   resource_group_name = var.resource_group_name
#   location = var.location
# }
