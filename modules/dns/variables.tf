variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "create_public_zone" {
  description = "Whether to create a public Azure DNS zone"
  type        = bool
}

variable "create_private_zone" {
  description = "Whether to create a private Azure DNS zone"
  type        = bool
}

variable "domain_name" {
  description = "valid domain name"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}
