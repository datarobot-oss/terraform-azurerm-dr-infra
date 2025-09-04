variable "name" {
  description = "The name which should be used for this PostgreSQL Flexible Server"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the PostgreSQL Flexible Server should exist"
  type        = string
}

variable "location" {
  description = "The Azure Region where the PostgreSQL Flexible Server should exist"
  type        = string
}

variable "vnet_id" {
  description = "ID of the VNet to create a private DNS zone virtual network link in"
  type        = string
}

variable "delegated_subnet_id" {
  description = "The ID of the virtual network subnet to create the PostgreSQL Flexible Server. The provided subnet should not have any other resource deployed in it and this subnet will be delegated to the PostgreSQL Flexible Server, if not already delegated."
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Create Postgres PostgreSQL Flexible Server in ZoneRedundant high availability mode"
  type        = bool
  default     = false
}

variable "postgres_version" {
  description = "The version of PostgreSQL Flexible Server to use"
  type        = string
  default     = "13"
}

variable "sku_name" {
  description = "The SKU Name for the PostgreSQL Flexible Server"
  type        = string
  default     = "GP_Standard_D2ds_v4"
}

variable "storage_mb" {
  description = "The max storage allowed for the PostgreSQL Flexible Server in MB. Default is 32768."
  type        = number
  default     = null
}

variable "backup_retention_days" {
  description = "The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days."
  type        = number
  default     = 7
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}
