variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "name" {
  description = "Name to use as a prefix for created resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}

variable "subnet_id" {
  description = "The ID of the Subnet to create the Private Endpoint in"
  type        = string
}

variable "network_id" {
  description = "value of the Virtual Network ID to link the Private DNS Zone to"
  type        = string
}

variable "endpoint_config" {
  description = "Configuration object for the private endpoint"
  type = object({
    resource_id       = string
    subresource_names = list(string)
    private_dns_zone  = string
    private_dns_name  = string
    create_dns_zone   = bool
  })
}
