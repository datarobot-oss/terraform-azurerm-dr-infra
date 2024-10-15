variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}

variable "name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "address_space" {
  description = "CIDR block to use for the Azure VNet"
  type        = string
}
