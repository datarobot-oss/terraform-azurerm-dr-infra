variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "name" {
  description = "Name of the user AKS cluster"
  type        = string
}

variable "private_cluster" {
  description = "Whether the Kubernetes API endpoint should be exposed only internally to the virtual network. If true, the Kubernetes API endpoint will not be accessible over the public internet."
  type        = bool
}

variable "node_pool_subnet_id" {
  description = "ID of the subnet to use for the node pools"
  type        = string
}

variable "primary_node_pool_vm_size" {
  description = "VM size used for the primary node pool"
  type        = string
}

variable "primary_node_pool_node_count" {
  description = "Node count of the primary node pool"
  type        = number
}

variable "primary_node_pool_min_count" {
  description = "Minimum number of nodes in the primary node pool"
  type        = number
}

variable "primary_node_pool_max_count" {
  description = "Maximum number of nodes in the primary node pool"
  type        = number
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}
