variable "name" {
  description = "Name to use as a prefix for created resources"
  type        = string
}

variable "domain_name" {
  description = "Name of the domain to use for the DataRobot application. If create_dns_zones is true then zones will be created for this domain. It is also used by the cert-manager helm chart for DNS validation and as a domain filter by the external-dns helm chart."
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure location to create resources in"
  type        = string
}

variable "public_ip_allow_list" {
  description = "List of public IP ranges in CIDR format to allow Kubernetes cluster API endpoint, storage account, and container registry access. By default the storage account and container registry can only be accessed within the VNet via PrivateLink. When kubernetes_cluster_endpoint_public_access are true, this list restricts access to only the specified IP addresses. When kubernetes_cluster_endpoint_public_access is false, this list is ignored and the Kubernetes cluster API endpoint can only be reached from within the VNet. Required when creating a storage account, container registry, or kubernetes cluster over the public internet."
  type        = list(string)
  default     = []
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
  description = "Create a new Azure resource group. Ignored if existing existing_resource_group_name is specified."
  type        = bool
  default     = true
}

variable "existing_resource_group_name" {
  description = "Name of existing resource group to use"
  type        = string
  default     = ""
}


################################################################################
# Network
################################################################################

variable "existing_vnet_id" {
  description = "ID of an existing VNet to use. When specified, other network variables are ignored."
  type        = string
  default     = ""
}

variable "create_network" {
  description = "Create a new Azure Virtual Network. Ignored if an existing existing_vnet_id is specified."
  type        = bool
  default     = true
}

variable "network_address_space" {
  description = "CIDR block to be used for the new VNet. By default, AKS uses 10.0.0.0/16 for services and 10.244.0.0/16 for pods. This should not overlap with the kubernetes_service_cidr or kubernetes_pod_cidr variables."
  type        = string
  default     = "10.1.0.0/16"
}


################################################################################
# DNS
################################################################################

variable "existing_public_dns_zone_id" {
  description = "ID of existing public hosted zone to use for public DNS records created by external-dns and public LetsEncrypt certificate validation by cert-manager. This is required when create_dns_zones is false and ingress_nginx and internet_facing_ingress_lb are true or when cert_manager and cert_manager_letsencrypt_clusterissuers are true."
  type        = string
  default     = ""
}

variable "existing_private_dns_zone_id" {
  description = "ID of existing private hosted zone to use for private DNS records created by external-dns. This is required when create_dns_zones is false and ingress_nginx is true with internet_facing_ingress_lb false."
  type        = string
  default     = ""
}

variable "create_dns_zones" {
  description = "Create DNS zones for domain_name. Ignored if existing_public_dns_zone_id and existing_private_dns_zone_id are specified."
  type        = bool
  default     = true
}


################################################################################
# Storage
################################################################################

variable "existing_storage_account_id" {
  description = "ID of existing Azure Storage Account to use for DataRobot file storage. When specified, all other storage variables will be ignored."
  type        = string
  default     = ""
}

variable "create_storage" {
  description = "Create a new Azure Storage account and container. Ignored if an existing_storage_account_id is specified."
  type        = bool
  default     = true
}

variable "storage_account_replication_type" {
  description = "Storage account data replication type as described in https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy"
  type        = string
  default     = "ZRS"
}


################################################################################
# Container Registry
################################################################################

variable "existing_container_registry_id" {
  description = "ID of existing container registry to use"
  type        = string
  default     = ""
}


variable "create_container_registry" {
  description = "Create a new Azure Container Registry. Ignored if an existing existing_container_registry_id is specified."
  type        = bool
  default     = true
}


################################################################################
# Kubernetes
################################################################################

variable "create_kubernetes_cluster" {
  description = "Create a new Azure Kubernetes Service cluster. All kubernetes and helm chart variables are ignored if this variable is false."
  type        = bool
  default     = true
}

variable "kubernetes_cluster_version" {
  description = "AKS cluster version"
  type        = string
  default     = null
}

variable "kubernetes_cluster_endpoint_public_access" {
  description = "Whether or not the Kubernetes API endpoint should be exposed to the public internet. When false, the cluster endpoint is only available internally to the virtual network."
  type        = bool
  default     = true
}

variable "existing_kubernetes_nodes_subnet_id" {
  description = "ID of an existing subnet to use for the AKS node pools. Required when an existing_network_id is specified. Ignored if create_network is true and no existing_network_id is specified."
  type        = string
  default     = ""
}

variable "kubernetes_pod_cidr" {
  description = "The CIDR to use for Kubernetes pod IP addresses"
  type        = string
  default     = null
}

variable "kubernetes_service_cidr" {
  description = "The CIDR to use for Kubernetes service IP addresses"
  type        = string
  default     = null
}

variable "kubernetes_dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)"
  type        = string
  default     = null
}

variable "kubernetes_nodepool_availability_zones" {
  description = "Availability zones to use for the AKS node pools"
  type        = set(string)
  default     = ["1", "2", "3"]
}

variable "kubernetes_primary_nodepool_name" {
  description = "Name of the primary node pool"
  type        = string
  default     = "primary"
}

variable "kubernetes_primary_nodepool_vm_size" {
  description = "VM size used for the primary node pool"
  type        = string
  default     = "Standard_D32s_v4"
}

variable "kubernetes_primary_nodepool_node_count" {
  description = "Node count of the primary node pool"
  type        = number
  default     = 6
}

variable "kubernetes_primary_nodepool_min_count" {
  description = "Minimum number of nodes in the primary node pool"
  type        = number
  default     = 3
}

variable "kubernetes_primary_nodepool_max_count" {
  description = "Maximum number of nodes in the primary node pool"
  type        = number
  default     = 10
}

variable "kubernetes_primary_nodepool_labels" {
  description = "A map of Kubernetes labels to apply to the primary node pool"
  type        = map(string)
  default     = {}
}

variable "kubernetes_primary_nodepool_taints" {
  description = "A list of Kubernetes taints to apply to the primary node pool"
  type        = list(string)
  default     = []
}

variable "kubernetes_gpu_nodepool_name" {
  description = "Name of the GPU node pool"
  type        = string
  default     = "gpu"
}

variable "kubernetes_gpu_nodepool_vm_size" {
  description = "VM size used for the GPU node pool"
  type        = string
  default     = "Standard_NC4as_T4_v3"
}

variable "kubernetes_gpu_nodepool_node_count" {
  description = "Node count of the GPU node pool"
  type        = number
  default     = 0
}

variable "kubernetes_gpu_nodepool_min_count" {
  description = "Minimum number of nodes in the GPU node pool"
  type        = number
  default     = 0
}

variable "kubernetes_gpu_nodepool_max_count" {
  description = "Maximum number of nodes in the GPU node pool"
  type        = number
  default     = 10
}

variable "kubernetes_gpu_nodepool_labels" {
  description = "A map of Kubernetes labels to apply to the GPU node pool"
  type        = map(string)
  default = {
    "datarobot.com/node-capability" = "gpu"
  }
}

variable "kubernetes_gpu_nodepool_taints" {
  description = "A list of Kubernetes taints to apply to the GPU node pool"
  type        = list(string)
  default     = ["nvidia.com/gpu:NoSchedule"]
}


################################################################################
# App Identity
################################################################################

variable "create_app_identity" {
  description = "Create a new user assigned identity for the DataRobot application"
  type        = bool
  default     = true
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
  description = "Install the ingress-nginx helm chart to use as the ingress controller for the AKS cluster. All other ingress_nginx variables are ignored if this variable is false."
  type        = bool
  default     = true
}

variable "internet_facing_ingress_lb" {
  description = "Determines the type of Standard Load Balancer created for AKS ingress. If true, a public Standard Load Balancer will be created. If false, an internal Standard Load Balancer will be created."
  type        = bool
  default     = true
}

variable "ingress_nginx_values" {
  description = "Path to templatefile containing custom values for the ingress-nginx helm chart"
  type        = string
  default     = ""
}

variable "ingress_nginx_variables" {
  description = "Variables passed to the ingress_nginx_values templatefile"
  type        = any
  default     = {}
}

variable "cert_manager" {
  description = "Install the cert-manager helm chart. All other cert_manager variables are ignored if this variable is false."
  type        = bool
  default     = true
}

variable "cert_manager_letsencrypt_clusterissuers" {
  description = "Whether to create letsencrypt-prod and letsencrypt-staging ClusterIssuers"
  type        = bool
  default     = true
}

variable "cert_manager_letsencrypt_email_address" {
  description = "Email address for the certificate owner. Let's Encrypt will use this to contact you about expiring certificates, and issues related to your account. Only required if cert_manager_letsencrypt_clusterissuers is true."
  type        = string
  default     = "user@example.com"
}

variable "cert_manager_values" {
  description = "Path to templatefile containing custom values for the cert-manager helm chart"
  type        = string
  default     = ""
}

variable "cert_manager_variables" {
  description = "Variables passed to the cert_manager_values templatefile"
  type        = any
  default     = {}
}

variable "external_dns" {
  description = "Install the external_dns helm chart to create DNS records for ingress resources matching the domain_name variable. All other external_dns variables are ignored if this variable is false."
  type        = bool
  default     = true
}

variable "external_dns_values" {
  description = "Path to templatefile containing custom values for the external-dns helm chart"
  type        = string
  default     = ""
}

variable "external_dns_variables" {
  description = "Variables passed to the external_dns_values templatefile"
  type        = any
  default     = {}
}

variable "nvidia_device_plugin" {
  description = "Install the nvidia-device-plugin helm chart to expose node GPU resources to the AKS cluster. All other nvidia_device_plugin variables are ignored if this variable is false."
  type        = bool
  default     = true
}

variable "nvidia_device_plugin_values" {
  description = "Path to templatefile containing custom values for the nvidia-device-plugin helm chart"
  type        = string
  default     = ""
}

variable "nvidia_device_plugin_variables" {
  description = "Variables passed to the nvidia_device_plugin_values templatefile"
  type        = any
  default     = {}
}
