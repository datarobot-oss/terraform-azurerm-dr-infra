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

variable "account_name" {
  description = "Name of the Storage Account"
  type        = string
}

variable "container_name" {
  description = "Name of the Storage Container"
  type        = string
}

variable "account_replication_type" {
  description = "Storage account data replication type as described in https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy"
  type        = string
}
