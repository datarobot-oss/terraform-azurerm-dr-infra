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

variable "public_network_access_enabled" {
  description = "Whether the public network access to the container registry is enabled"
  type        = bool
}

variable "network_rules_default_action" {
  description = "Specifies the default action of allow or deny when no other rules match"
  type        = string
}

variable "ip_allow_list" {
  description = "List of CIDR blocks to allow access to the container registry. Only IPv4 addresses are allowed"
  type        = list(string)
}

variable "vnet_id" {
  description = "ID of the VNet used for the private endpoint to storage"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet used for the private endpoint to storage"
  type        = string
}
