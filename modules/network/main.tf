resource "azurerm_virtual_network" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name          = var.name
  address_space = [var.address_space]

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.this.name
  name                 = "${var.name}-snet"
  address_prefixes     = [cidrsubnet(var.address_space, 4, 0)]
}

resource "azurerm_nat_gateway" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "${var.name}-ng"

  tags = var.tags
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = azurerm_subnet.this.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_public_ip" "ng" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name              = "${var.name}-ng-pip"
  allocation_method = "Static"

  tags = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.ng.id
}
