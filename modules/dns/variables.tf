variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "domain_name" {
  description = "valid domain name"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}
