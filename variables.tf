variable "name" {
  description = "Name to use as a prefix for created resources"
  type        = string
}

variable "location" {
  description = "Azure location to create resources in"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
  default = {
    managed-by = "terraform"
  }
}


################################################################################
# Resource Group
################################################################################

variable "create_resource_group" {
  description = "Whether to create an Azure resource group"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of existing resource group to use"
  type        = string
  default     = null
}


################################################################################
# Virtual Network
################################################################################

variable "create_vnet" {
  description = "Whether to create an Azure virtual network"
  type        = bool
  default     = true
}

variable "vnet_id" {
  description = "ID of existing Azure VNet to use"
  type        = string
  default     = ""
}

variable "vnet_address_space" {
  description = "CIDR block to use for the Azure VNet"
  type        = string
  default     = "10.1.0.0/16"
}


################################################################################
# DNS
################################################################################

variable "create_dns_zones" {
  description = "Whether to create a public and private zone for domain_name"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "ID of existing zone to use"
  type        = string
  default     = ""
}

variable "domain_name" {
  type        = string
  description = "Name of the domain to create. Used by the cert-manager helm chart for DNS validation and as a domain filter by the external-dns helm chart."
  default     = ""
}


################################################################################
# Storage
################################################################################

variable "create_storage" {
  description = "Whether to create a storage account and container"
  type        = bool
  default     = true
}

variable "storage_account_id" {
  description = "ID of existing storage account to use"
  type        = string
  default     = ""
}

variable "account_replication_type" {
  description = "Storage account data replication type as described in https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy"
  type        = string
  default     = "ZRS"
}


################################################################################
# Container Registry
################################################################################

variable "create_container_registry" {
  description = "Whether to create a container registry"
  type        = bool
  default     = true
}

variable "container_registry_id" {
  description = "ID of existing container registry to use"
  type        = string
  default     = ""
}


################################################################################
# AKS
################################################################################

variable "create_aks_cluster" {
  description = "Whether to create an AKS cluster"
  type        = bool
  default     = true
}

variable "aks_private_cluster" {
  description = "Whether the Kubernetes API endpoint should be exposed only internally to the virtual network. If true, the Kubernetes API endpoint will not be accessible over the public internet."
  type        = bool
  default     = false
}

variable "aks_node_pool_subnet_id" {
  description = "ID of the subnet to use for the node pools"
  type        = string
  default     = ""
}

variable "aks_node_pool_availability_zones" {
  description = "Availability zones to use for the node pools"
  type        = list(number)
  default     = [1, 2, 3]
}

variable "aks_primary_node_pool_name" {
  description = "Name of the primary node pool"
  type        = string
  default     = "primary"
}

variable "aks_primary_node_pool_labels" {
  description = "A map of Kubernetes labels to apply to the primary node pool"
  type        = map(string)
  default     = {}
}

variable "aks_primary_node_pool_taints" {
  description = "A list of Kubernetes taints to apply to the primary node pool"
  type        = list(string)
  default     = []
}

variable "aks_primary_node_pool_vm_size" {
  description = "VM size used for the primary node pool"
  type        = string
  default     = "Standard_D32s_v4"
}


variable "aks_primary_node_pool_node_count" {
  description = "Node count of the primary node pool"
  type        = number
  default     = 6
}

variable "aks_primary_node_pool_min_count" {
  description = "Minimum number of nodes in the primary node pool"
  type        = number
  default     = 3
}

variable "aks_primary_node_pool_max_count" {
  description = "Maximum number of nodes in the primary node pool"
  type        = number
  default     = 10
}

variable "create_gpu_node_pool" {
  description = "Whether to create a GPU node pool"
  type        = bool
  default     = false
}

variable "gpu_node_pool_name" {
  description = "Name of the GPU node pool"
  type        = string
  default     = "gpu"
}

variable "gpu_node_pool_labels" {
  description = "A map of Kubernetes labels to apply to the GPU node pool"
  type        = map(string)
  default = {
    "datarobot.com/node-capability" = "gpu"
  }
}

variable "gpu_node_pool_taints" {
  description = "A list of Kubernetes taints to apply to the GPU node pool"
  type        = list(string)
  default     = ["nvidia.com/gpu:NoSchedule"]
}

variable "gpu_node_pool_vm_size" {
  description = "VM size used for the GPU node pool"
  type        = string
  default     = "Standard_NC6s_v3"
}

variable "gpu_node_pool_node_count" {
  description = "Node count of the GPU node pool"
  type        = number
  default     = 1
}

variable "gpu_node_pool_min_count" {
  description = "Minimum number of nodes in the GPU node pool"
  type        = number
  default     = 1
}

variable "gpu_node_pool_max_count" {
  description = "Maximum number of nodes in the GPU node pool"
  type        = number
  default     = 3
}


################################################################################
# User Assigned Identity
################################################################################

variable "create_user_assigned_identity" {
  description = "Whether to create a user assigned identity"
  type        = bool
  default     = true
}

variable "user_assigned_identity_id" {
  description = "ID of existing user assigned identity"
  type        = string
  default     = ""
}

variable "datarobot_namespace" {
  description = "Kubernetes namespace in which the DataRobot application will be installed"
  type        = string
  default     = "dr-app"
}

variable "datarobot_service_accounts" {
  description = "Names of the Kubernetes service accounts used by the DataRobot application"
  type        = set(string)
  default = [
    "dr",
    "build-service",
    "build-service-image-builder",
    "buzok-account",
    "dr-lrs-operator",
    "dynamic-worker",
    "internal-api-sa",
    "nbx-notebook-revisions-account",
    "prediction-server-sa",
    "tileservergl-sa",
  ]
}


################################################################################
# Helm Charts
################################################################################

variable "ingress_nginx" {
  description = "Install the ingress-nginx helm chart to use as the ingress controller for the AKS cluster. Ignored if create_aks_cluster is false."
  type        = bool
  default     = true
}

variable "internet_facing_ingress_lb" {
  description = "Determines the type of NLB created for AKS ingress. If true, an internet-facing NLB will be created. If false, an internal NLB will be created. Ignored when ingress_nginx is false."
  type        = bool
  default     = true
}

variable "ingress_nginx_values" {
  description = "Path to templatefile containing custom values for the ingress-nginx helm chart."
  type        = string
  default     = ""
}

variable "ingress_nginx_variables" {
  description = "Variables passed to the ingress_nginx_values templatefile"
  type        = map(string)
  default     = {}
}

variable "cert_manager" {
  description = "Install the cert-manager helm chart"
  type        = bool
  default     = true
}

variable "cert_manager_email_address" {
  description = "Email address for the certificate owner. Let's Encrypt will use this to contact you about expiring certificates, and issues related to your account."
  type        = string
  default     = "user@example.com"
}

variable "cert_manager_values" {
  description = "Path to templatefile containing custom values for the cert-manager helm chart."
  type        = string
  default     = ""
}

variable "cert_manager_variables" {
  description = "Variables passed to the cert_manager_values templatefile"
  type        = map(string)
  default     = {}
}

variable "external_dns" {
  description = "Install the external_dns helm chart"
  type        = bool
  default     = true
}

variable "external_dns_values" {
  description = "Path to templatefile containing custom values for the external_dns helm chart."
  type        = string
  default     = ""
}

variable "external_dns_variables" {
  description = "Variables passed to the external_dns_values templatefile"
  type        = map(string)
  default     = {}
}

variable "nvidia_device_plugin" {
  description = "Install the nvidia-device-plugin helm chart to expose node GPU resources to the EKS cluster. Ignored if create_eks_cluster is false."
  type        = bool
  default     = true
}

variable "nvidia_device_plugin_values" {
  description = "Path to templatefile containing custom values for the nvidia-device-plugin helm chart."
  type        = string
  default     = ""
}

variable "nvidia_device_plugin_variables" {
  description = "Variables passed to the nvidia_device_plugin_values templatefile"
  type        = map(string)
  default     = {}
}
