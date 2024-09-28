output "id" {
  description = "ID of the VNet"
  value       = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "IDs of the subnets created in this module"
  value       = azurerm_virtual_network.this.subnet[*].id
}

output "subnet_cidrs" {
  description = "CIDRs of the subnets created in this module"
  value       = azurerm_virtual_network.this.subnet[*].address_prefixes
}
