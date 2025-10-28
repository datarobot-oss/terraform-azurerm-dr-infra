variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "name" {
  description = "Name of the user assigned identity"
  type        = string
}

variable "application_id" {
  description = "The Azure Application ID of the given Azure service principal and will be their form of access and identity"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}
