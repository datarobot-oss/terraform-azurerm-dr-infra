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

variable "public_network_access_enabled" {
  description = "Whether the public network access to the storage account is enabled"
  type        = bool
}

variable "network_rules_default_action" {
  description = "Specifies the default action of allow or deny when no other rules match"
  type        = string
}

variable "public_ip_allow_list" {
  description = "List of public IP or IP ranges in CIDR Format to allow access to the storage account. Only IPv4 addresses are allowed. /31 CIDRs, /32 CIDRs, and Private IP address ranges (as defined in RFC 1918), are not allowed."
  type        = list(string)
}

variable "virtual_network_subnet_ids" {
  description = "List of resource IDs for subnets which are allowed to access the storage account"
  type        = list(string)
}
