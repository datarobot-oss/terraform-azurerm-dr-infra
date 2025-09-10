variable "name" {
  description = "The name which should be used for this Redis Instance"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the Redis Instance should exist"
  type        = string
}

variable "location" {
  description = "The Azure Region where the Redis Instance should exist"
  type        = string
}

variable "vnet_id" {
  description = "ID of the VNet to create a private DNS zone virtual network link in"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint"
  type        = string
}

variable "capacity" {
  description = "The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4, 5."
  type        = number
  default     = 4
}

variable "redis_version" {
  description = "Redis version. Only major version needed. Possible values are 4 and 6. Defaults to 6."
  type        = number
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}
