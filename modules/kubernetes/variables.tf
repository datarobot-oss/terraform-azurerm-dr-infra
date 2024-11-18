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

variable "nodepool_subnet_id" {
  description = "ID of the subnet to use for the node pools"
  type        = string
}

variable "nodepool_availability_zones" {
  description = "Availability zones to use for the node pools"
  type        = set(string)
}

variable "primary_nodepool_name" {
  description = "Name of the primary node pool"
  type        = string
}

variable "primary_nodepool_labels" {
  description = "A map of Kubernetes labels to apply to the primary node pool"
  type        = map(string)
}

variable "primary_nodepool_taints" {
  description = "A list of Kubernetes taints to apply to the primary node pool"
  type        = list(string)
}

variable "primary_nodepool_vm_size" {
  description = "VM size used for the primary node pool"
  type        = string
}

variable "primary_nodepool_node_count" {
  description = "Node count of the primary node pool"
  type        = number
}

variable "primary_nodepool_min_count" {
  description = "Minimum number of nodes in the primary node pool"
  type        = number
}

variable "primary_nodepool_max_count" {
  description = "Maximum number of nodes in the primary node pool"
  type        = number
}

variable "gpu_nodepool_name" {
  description = "Name of the GPU node pool"
  type        = string
}

variable "gpu_nodepool_labels" {
  description = "A map of Kubernetes labels to apply to the GPU node pool"
  type        = map(string)
}

variable "gpu_nodepool_taints" {
  description = "A list of Kubernetes taints to apply to the GPU node pool"
  type        = list(string)
}

variable "gpu_nodepool_vm_size" {
  description = "VM size used for the GPU node pool"
  type        = string
}

variable "gpu_nodepool_node_count" {
  description = "Node count of the GPU node pool"
  type        = number
}

variable "gpu_nodepool_min_count" {
  description = "Minimum number of nodes in the GPU node pool"
  type        = number
}

variable "gpu_nodepool_max_count" {
  description = "Maximum number of nodes in the GPU node pool"
  type        = number
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}
