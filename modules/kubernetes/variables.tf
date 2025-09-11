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

variable "cluster_version" {
  description = "AKS cluster version"
  type        = string
}

variable "container_registry_id" {
  description = "ID of an Azure Container Registry to attach to the kubernetes cluster"
  type        = string
}

variable "private_cluster" {
  description = "Whether the Kubernetes API endpoint should be exposed only internally to the virtual network. If true, the Kubernetes API endpoint will not be accessible over the public internet."
  type        = bool
}

variable "cluster_endpoint_authorized_ip_ranges" {
  description = "List of CIDR blocks which can access the Kubernetes API server endpoint"
  type        = list(string)
}

variable "pod_cidr" {
  description = "The CIDR to use for Kubernetes pod IP addresses"
  type        = string
}

variable "service_cidr" {
  description = "The CIDR to use for Kubernetes service IP addresses"
  type        = string
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)"
  type        = string
}

variable "node_pool_subnet_id" {
  description = "ID of the subnet to use for the node pools"
  type        = string
}

variable "default_node_pool" {
  description = "Specifies configuration for System mode node pool"
  type        = any
}

variable "node_pools" {
  description = "Map of AKS node pools"
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}
