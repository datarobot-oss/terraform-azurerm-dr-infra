output "id" {
  description = "ID of the VNet"
  value       = azurerm_virtual_network.this.id
}

output "subnet_id" {
  description = "ID of the subnet created in this module"
  value       = azurerm_subnet_nat_gateway_association.this.id
}

output "nat_gateway_pip" {
  description = "Public IP of the NAT Gateway"
  value       = azurerm_public_ip.ng.ip_address
}
