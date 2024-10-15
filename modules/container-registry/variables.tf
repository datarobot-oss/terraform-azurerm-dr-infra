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
  description = "Name of the container registry"
  type        = string
}

variable "vnet_id" {
  description = "ID of the VNet used for the private endpoint to storage"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet used for the private endpoint to storage"
  type        = string
}

variable "public_ip_allow_list" {
  description = "List of public IP address ranges in CIDR block notation which will be allowed to access this container registry"
  type        = list(string)
}
