variable "name" {
  description = "Name to use as a prefix for created resources"
  type        = string
}

variable "domain_name" {
  description = "Name of the domain to use for the DataRobot application. If create_dns_zones is true then zones will be created for this domain. It is also used by the cert-manager helm chart for DNS validation and as a domain filter by the external-dns helm chart."
  type        = string
  default     = null
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
  description = "Create a new Azure resource group. Ignored if existing existing_resource_group_name is specified."
  type        = bool
  default     = true
}

variable "existing_resource_group_name" {
  description = "Name of existing resource group to use"
  type        = string
  default     = null
}


################################################################################
# Network
################################################################################

variable "existing_vnet_name" {
  description = "Name of an existing VNet to use. When specified, other network variables are ignored."
  type        = string
  default     = null
}

variable "create_network" {
  description = "Create a new Azure Virtual Network. Ignored if an existing existing_vnet_name is specified."
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
  default     = null
}

variable "existing_private_dns_zone_id" {
  description = "ID of existing private hosted zone to use for private DNS records created by external-dns. This is required when create_dns_zones is false and ingress_nginx is true with internet_facing_ingress_lb false."
  type        = string
  default     = null
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
  default     = null
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

variable "storage_public_network_access_enabled" {
  description = "Whether the public network access to the storage account is enabled"
  type        = bool
  default     = true
}

variable "storage_network_rules_default_action" {
  description = "Specifies the default action of the storage firewall to allow or deny when no other rules match"
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Deny", "Allow"], var.storage_network_rules_default_action)
    error_message = "Valid options are Deny or Allow"
  }
}

variable "storage_public_ip_allow_list" {
  description = "List of public IP or IP ranges in CIDR Format which are allowed to access the storage account. Only IPv4 addresses are allowed. /31 CIDRs, /32 CIDRs, and Private IP address ranges (as defined in RFC 1918), are not allowed. Ignored if storage_public_network_access_enabled is false."
  type        = list(string)
  default     = []
}

variable "storage_virtual_network_subnet_ids" {
  description = "List of resource IDs for subnets which are allowed to access the storage account"
  type        = list(string)
  default     = null
}


################################################################################
# Container Registry
################################################################################

variable "existing_container_registry_id" {
  description = "ID of existing container registry to use"
  type        = string
  default     = null
}


variable "create_container_registry" {
  description = "Create a new Azure Container Registry. Ignored if an existing existing_container_registry_id is specified."
  type        = bool
  default     = true
}

variable "container_registry_public_network_access_enabled" {
  description = "Whether the public network access to the container registry is enabled"
  type        = bool
  default     = true
}

variable "container_registry_network_rules_default_action" {
  description = "Specifies the default action of allow or deny when no other rules match"
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Deny", "Allow"], var.container_registry_network_rules_default_action)
    error_message = "Valid options are Deny or Allow"
  }
}

variable "container_registry_ip_allow_list" {
  description = "List of CIDR blocks to allow access to the container registry. Only IPv4 addresses are allowed"
  type        = list(string)
  default     = []
}


################################################################################
# Kubernetes
################################################################################

variable "existing_aks_cluster_name" {
  description = "Name of existing AKS cluster to use. When specified, all other kubernetes variables will be ignored."
  type        = string
  default     = null
}

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

variable "kubernetes_cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Kubernetes API server endpoint"
  type        = list(string)
  default     = []
}

variable "existing_kubernetes_node_subnet" {
  description = "ID of an existing subnet to use for the AKS node pools. Required when an existing_network_id is specified. Ignored if create_network is true and no existing_network_id is specified."
  type        = string
  default     = null
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

variable "kubernetes_default_node_pool" {
  description = "Specifies configuration for System mode node pool"
  type        = any
  default = {
    name                        = "system"
    temporary_name_for_rotation = "systemtemp"
    zones                       = ["1", "2"]
    vm_size                     = "Standard_DS4_v2"
    host_encryption_enabled     = false
    fips_enabled                = false
    auto_scaling_enabled        = true
    node_count                  = 2
    min_count                   = 2
    max_count                   = 4
  }
}

variable "kubernetes_node_pools" {
  description = "Map of AKS node pools"
  type        = any
  default = {
    drcpu = {
      zones      = ["1", "2"]
      vm_size    = "Standard_D32s_v4"
      node_count = 2
      min_count  = 2
      max_count  = 10
      node_labels = {
        "datarobot.com/node-capability" = "cpu"
      }
      node_taints = []
    }
    drgpu = {
      vm_size    = "Standard_NC4as_T4_v3"
      node_count = 0
      min_count  = 0
      max_count  = 10
      node_labels = {
        "datarobot.com/node-capability" = "gpu"
      }
      node_taints = ["nvidia.com/gpu=true:NoSchedule"]
    }
  }
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
  description = "Kubernetes service accounts in the datarobot_namespace to provide with Storage Blob Data Contributor and AcrPush access"
  type        = set(string)
  default = [
    "datarobot-storage-sa",
    "dynamic-worker",
    "kubeworker-sa",
    "prediction-server-sa",
    "internal-api-sa",
    "build-service",
    "tileservergl-sa",
    "nbx-notebook-revisions-account",
    "buzok-account",
    "exec-manager-qw",
    "exec-manager-wrangling",
    "lrs-job-manager",
    "blob-view-service",
    "spark-compute-services-sa",
  ]
}


################################################################################
# PostgreSQL
################################################################################

variable "create_postgres" {
  description = "Whether to create a Azure PostgreSQL Flexible Server"
  type        = bool
  default     = false
}

variable "existing_postgres_subnet" {
  description = "ID of existing virtual network subnet to create the PostgreSQL Flexible Server. The provided subnet should not have any other resource deployed in it and this subnet will be delegated to the PostgreSQL Flexible Server, if not already delegated. Required when an existing_network_id is specified. Ignored if create_network is true and no existing_network_id is specified."
  type        = string
  default     = null
}

variable "postgres_multi_az" {
  description = "Create Postgres PostgreSQL Flexible Server in ZoneRedundant high availability mode"
  type        = bool
  default     = false
}

variable "postgres_version" {
  description = "The version of PostgreSQL Flexible Server to use"
  type        = string
  default     = "13"
}

variable "postgres_sku_name" {
  description = "The SKU Name for the PostgreSQL Flexible Server"
  type        = string
  default     = "GP_Standard_D2ds_v4"
}

variable "postgres_storage_mb" {
  description = "The max storage allowed for the PostgreSQL Flexible Server in MB. Default is 32768."
  type        = number
  default     = null
}

variable "postgres_backup_retention_days" {
  description = "The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days."
  type        = number
  default     = 7
}


################################################################################
# Redis
################################################################################

variable "create_redis" {
  description = "Whether to create an Azure Cache for Redis instance"
  type        = bool
  default     = false
}

variable "existing_redis_subnet" {
  description = "ID of existing virtual network subnet to create the Azure Cache for Redis private endpoint in. Required when an existing_network_id is specified. Ignored if create_network is true and no existing_network_id is specified."
  type        = string
  default     = null
}

variable "redis_capacity" {
  description = "The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4, 5."
  type        = number
  default     = 4
}

variable "redis_version" {
  description = "Redis version. Only major version needed. Possible values are 4 and 6. Defaults to 6."
  type        = number
  default     = null
}


################################################################################
# MongoDB
################################################################################

variable "create_mongodb" {
  description = "Whether to create a MongoDB Atlas instance"
  type        = bool
  default     = false
}

variable "existing_mongodb_subnet" {
  description = "Existing subnet IDs to be used for the MongoDB Atlas instance. Required when an existing_network_id is specified."
  type        = string
  default     = null
}

variable "mongodb_version" {
  description = "MongoDB version"
  type        = string
  default     = "7.0"
}

variable "mongodb_atlas_org_id" {
  description = "Atlas organization ID"
  type        = string
  default     = null
}

variable "mongodb_atlas_public_key" {
  description = "Public API key for Mongo Atlas"
  type        = string
  default     = ""
}

variable "mongodb_atlas_private_key" {
  description = "Private API key for Mongo Atlas"
  type        = string
  default     = ""
}

variable "mongodb_termination_protection_enabled" {
  description = "Enable protection to avoid accidental production cluster termination"
  type        = bool
  default     = false
}

variable "mongodb_audit_enable" {
  type        = bool
  description = "Enable database auditing for production instances only(cost incurred 10%)"
  default     = false
}

variable "mongodb_atlas_auto_scaling_disk_gb_enabled" {
  description = "Enable Atlas disk size autoscaling"
  type        = bool
  default     = true
}

variable "mongodb_atlas_disk_size" {
  description = "Starting atlas disk size"
  type        = string
  default     = "20"
}

variable "mongodb_atlas_instance_type" {
  description = "atlas instance type"
  type        = string
  default     = "M30"
}

variable "mongodb_admin_username" {
  description = "MongoDB admin username"
  type        = string
  default     = "pcs-mongodb"
}

variable "mongodb_enable_slack_alerts" {
  description = "Enable alert notifications to a Slack channel. When `true`, `slack_api_token` and `slack_notification_channel` must be set."
  type        = string
  default     = false
}

variable "mongodb_slack_api_token" {
  description = "Slack API token to use for alert notifications. Required when `enable_slack_alerts` is `true`."
  type        = string
  default     = null
}

variable "mongodb_slack_notification_channel" {
  description = "Slack channel to send alert notifications to. Required when `enable_slack_alerts` is `true`."
  type        = string
  default     = null
}


################################################################################
# Helm Charts
################################################################################

variable "install_helm_charts" {
  description = "Whether to install helm charts into the target EKS cluster. All other helm chart variables are ignored if this is `false`."
  type        = bool
  default     = true
}

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

variable "ingress_nginx_values_overrides" {
  description = "Values in raw yaml format to pass to helm."
  type        = string
  default     = null
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

variable "cert_manager_values_overrides" {
  description = "Values in raw yaml format to pass to helm."
  type        = string
  default     = null
}

variable "external_dns" {
  description = "Install the external_dns helm chart to create DNS records for ingress resources matching the domain_name variable. All other external_dns variables are ignored if this variable is false."
  type        = bool
  default     = true
}

variable "external_dns_values_overrides" {
  description = "Values in raw yaml format to pass to helm."
  type        = string
  default     = null
}

variable "nvidia_device_plugin" {
  description = "Install the nvidia-device-plugin helm chart to expose node GPU resources to the AKS cluster. All other nvidia_device_plugin variables are ignored if this variable is false."
  type        = bool
  default     = true
}

variable "nvidia_device_plugin_values_overrides" {
  description = "Values in raw yaml format to pass to helm."
  type        = string
  default     = null
}

variable "descheduler" {
  description = "Install the descheduler helm chart to enable rescheduling of pods. All other descheduler variables are ignored if this variable is false"
  type        = bool
  default     = true
}

variable "descheduler_values_overrides" {
  description = "Values in raw yaml format to pass to helm."
  type        = string
  default     = null
}

################################################################################
# Privaete Link Service
################################################################################
variable "create_ingress_pl_service" {
  description = "Expose the internal LB created by the ingress-nginx controller as an Azure Private Link Service. Only applies if internet_facing_ingress_lb is false."
  type        = bool
  default     = false
}

variable "existing_load_balancer_name" {
  description = "Name of an existing Azure Load Balancer to expose via the Private Link Service."
  type        = string
  default     = null
}

variable "ingress_pl_visibility_subscription_ids" {
  description = "A list of Subscription UUID/GUID's that will be able to see the ingress Private Link Service. Only applies if internet_facing_ingress_lb is false."
  type        = list(string)
  default     = null
}

variable "ingress_pl_auto_approval_subscription_ids" {
  description = "A list of Subscription UUID/GUID's that will be automatically be able to use this Private Link Service. Only applies if internet_facing_ingress_lb is false."
  type        = list(string)
  default     = null
}

################################################################################
# Custom Private Endpoints
################################################################################
variable "custom_private_endpoints" {
  description = "A list of custom private endpoints"
  type = list(object({
    resource_id       = string
    subresource_names = list(string)
    private_dns_zone  = optional(string, "")
    private_dns_name  = optional(string, "")
    create_dns_zone   = optional(bool, true)
  }))
  default = []
}
