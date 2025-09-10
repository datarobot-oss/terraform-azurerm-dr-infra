data "azurerm_subscription" "current" {}


module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"

  prefix = [var.name]
}


################################################################################
# Resource Group
################################################################################

locals {
  resource_group_name = var.existing_resource_group_name != null ? var.existing_resource_group_name : try(azurerm_resource_group.this[0].name, null)
}

resource "azurerm_resource_group" "this" {
  count = var.create_resource_group && var.existing_resource_group_name == null ? 1 : 0

  location = var.location
  name     = module.naming.resource_group.name
  tags     = var.tags
}


################################################################################
# Network
################################################################################

data "azurerm_virtual_network" "existing" {
  count = var.existing_vnet_name != null ? 1 : 0

  name                = var.existing_vnet_name
  resource_group_name = var.existing_resource_group_name
}

locals {
  vnet_id   = var.existing_vnet_name != null ? data.azurerm_virtual_network.existing[0].id : try(module.network[0].id, null)
  vnet_cidr = try(data.azurerm_virtual_network.existing[0].address_space, var.network_address_space)
}

module "network" {
  source = "./modules/network"
  count  = var.create_network && var.existing_vnet_name == null ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  name          = module.naming.virtual_network.name
  address_space = var.network_address_space

  tags = var.tags
}


################################################################################
# DNS
################################################################################

locals {
  # create a public zone if we're using external_dns with internet_facing LB
  # or we're using cert_manager with letsencrypt clusterissuers
  create_public_zone = var.create_dns_zones && var.existing_public_dns_zone_id == null && ((var.external_dns && var.internet_facing_ingress_lb) || (var.cert_manager && var.cert_manager_letsencrypt_clusterissuers))
  public_zone_id     = var.existing_public_dns_zone_id != null ? var.existing_public_dns_zone_id : try(module.dns[0].public_zone_id, null)

  # create a private zone if we're using external_dns with an internal LB
  create_private_zone = var.create_dns_zones && var.existing_private_dns_zone_id == null && (var.external_dns && !var.internet_facing_ingress_lb)
  private_zone_id     = var.existing_private_dns_zone_id != null ? var.existing_private_dns_zone_id : try(module.dns[0].private_zone_id, null)
}

module "dns" {
  source = "./modules/dns"
  count  = local.create_public_zone || local.create_private_zone ? 1 : 0

  resource_group_name = local.resource_group_name

  domain_name         = var.domain_name
  create_public_zone  = local.create_public_zone
  create_private_zone = local.create_private_zone

  tags = var.tags
}


################################################################################
# Storage
################################################################################

locals {
  storage_account_id = var.existing_storage_account_id != null ? var.existing_storage_account_id : try(module.storage[0].account_id, null)
}

module "storage" {
  source = "./modules/storage"
  count  = var.create_storage && var.existing_storage_account_id == null ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  account_name                  = module.naming.storage_account.name_unique
  container_name                = module.naming.storage_container.name
  account_replication_type      = var.storage_account_replication_type
  public_network_access_enabled = var.storage_public_network_access_enabled
  network_rules_default_action  = var.storage_network_rules_default_action
  public_ip_allow_list          = [for cidr in var.storage_public_ip_allow_list : replace(cidr, "/32", "")]
  virtual_network_subnet_ids    = var.storage_virtual_network_subnet_ids
  vnet_id                       = local.vnet_id
  subnet_id                     = local.aks_nodes_subnet_id

  tags = var.tags
}


################################################################################
# Container Registry
################################################################################

locals {
  container_registry_id = var.existing_container_registry_id != null ? var.existing_container_registry_id : try(module.container_registry[0].id, null)
}

module "container_registry" {
  source = "./modules/container-registry"
  count  = var.create_container_registry && var.existing_container_registry_id == null ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  name                          = module.naming.container_registry.name_unique
  vnet_id                       = local.vnet_id
  subnet_id                     = local.aks_nodes_subnet_id
  public_network_access_enabled = var.container_registry_public_network_access_enabled
  network_rules_default_action  = var.container_registry_network_rules_default_action
  ip_allow_list                 = var.container_registry_ip_allow_list

  tags = var.tags
}


################################################################################
# Kubernetes
################################################################################

data "azurerm_kubernetes_cluster" "existing" {
  count = var.existing_aks_cluster_name != null ? 1 : 0

  name                = var.existing_aks_cluster_name
  resource_group_name = local.resource_group_name
}

locals {
  aks_cluster_name                = try(data.azurerm_kubernetes_cluster.existing[0].name, module.kubernetes[0].name, null)
  aks_nodes_subnet_id             = var.existing_kubernetes_node_subnet != null ? var.existing_kubernetes_node_subnet : try(module.network[0].kubernetes_nodes_subnet_id, null)
  aks_client_certificate          = try(data.azurerm_kubernetes_cluster.existing[0].kube_config[0].client_certificate, module.kubernetes[0].client_certificate, "")
  aks_client_key                  = try(data.azurerm_kubernetes_cluster.existing[0].kube_config[0].client_key, module.kubernetes[0].client_key, "")
  aks_cluster_ca_certificate      = try(data.azurerm_kubernetes_cluster.existing[0].kube_config[0].cluster_ca_certificate, module.kubernetes[0].cluster_ca_certificate, "")
  aks_cluster_host                = try(data.azurerm_kubernetes_cluster.existing[0].kube_config[0].host, module.kubernetes[0].host, "")
  aks_cluster_oidc_issuer_url     = try(data.azurerm_kubernetes_cluster.existing[0].oidc_issuer_url, module.kubernetes[0].oidc_issuer_url, null)
  aks_managed_resource_group_name = try(data.azurerm_kubernetes_cluster.existing[0].node_resource_group, module.kubernetes[0].node_resource_group, null)
}

module "kubernetes" {
  source = "./modules/kubernetes"
  count  = var.existing_aks_cluster_name == null && var.create_kubernetes_cluster ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  name                  = module.naming.kubernetes_cluster.name
  cluster_version       = var.kubernetes_cluster_version
  container_registry_id = local.container_registry_id

  private_cluster = !var.kubernetes_cluster_endpoint_public_access
  cluster_endpoint_authorized_ip_ranges = length(var.kubernetes_cluster_endpoint_public_access_cidrs) > 0 ? concat(
    var.kubernetes_cluster_endpoint_public_access_cidrs,
    try(["${module.network[0].nat_gateway_pip}/32"], [])
  ) : null

  pod_cidr                    = var.kubernetes_pod_cidr
  service_cidr                = var.kubernetes_service_cidr
  dns_service_ip              = var.kubernetes_dns_service_ip
  nodepool_subnet_id          = local.aks_nodes_subnet_id
  nodepool_availability_zones = var.kubernetes_nodepool_availability_zones

  primary_nodepool_name       = var.kubernetes_primary_nodepool_name
  primary_nodepool_labels     = var.kubernetes_primary_nodepool_labels
  primary_nodepool_taints     = var.kubernetes_primary_nodepool_taints
  primary_nodepool_vm_size    = var.kubernetes_primary_nodepool_vm_size
  primary_nodepool_node_count = var.kubernetes_primary_nodepool_node_count
  primary_nodepool_min_count  = var.kubernetes_primary_nodepool_min_count
  primary_nodepool_max_count  = var.kubernetes_primary_nodepool_max_count
  gpu_nodepool_name           = var.kubernetes_gpu_nodepool_name
  gpu_nodepool_labels         = var.kubernetes_gpu_nodepool_labels
  gpu_nodepool_taints         = var.kubernetes_gpu_nodepool_taints
  gpu_nodepool_vm_size        = var.kubernetes_gpu_nodepool_vm_size
  gpu_nodepool_node_count     = var.kubernetes_gpu_nodepool_node_count
  gpu_nodepool_min_count      = var.kubernetes_gpu_nodepool_min_count
  gpu_nodepool_max_count      = var.kubernetes_gpu_nodepool_max_count

  tags = var.tags
}


################################################################################
# App Identity
################################################################################

module "app_identity" {
  source = "./modules/app-identity"
  count  = var.create_app_identity ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  name                       = module.naming.user_assigned_identity.name
  aks_oidc_issuer_url        = local.aks_cluster_oidc_issuer_url
  storage_account_id         = local.storage_account_id
  acr_id                     = local.container_registry_id
  datarobot_namespace        = var.datarobot_namespace
  datarobot_service_accounts = var.datarobot_service_accounts

  tags = var.tags
}


################################################################################
# PostgreSQL
################################################################################

locals {
  postgres_subnet_id = var.existing_postgres_subnet != null ? var.existing_postgres_subnet : try(module.network[0].postgres_subnet_id, null)
}

module "postgres" {
  source = "./modules/postgres"
  count  = var.create_postgres ? 1 : 0

  name                = var.name
  resource_group_name = local.resource_group_name
  location            = var.location

  vnet_id               = local.vnet_id
  delegated_subnet_id   = local.postgres_subnet_id
  multi_az              = var.postgres_multi_az
  postgres_version      = var.postgres_version
  sku_name              = var.postgres_sku_name
  storage_mb            = var.postgres_storage_mb
  backup_retention_days = var.postgres_backup_retention_days

  tags = var.tags
}


################################################################################
# Redis
################################################################################

locals {
  redis_subnet = var.existing_redis_subnet != null ? var.existing_redis_subnet : try(module.network[0].redis_subnet_id, null)
}


module "redis" {
  source = "./modules/redis"
  count  = var.create_redis ? 1 : 0

  name                = var.name
  resource_group_name = local.resource_group_name
  location            = var.location

  vnet_id       = local.vnet_id
  subnet_id     = local.redis_subnet
  capacity      = var.redis_capacity
  redis_version = var.redis_version

  tags = var.tags
}


################################################################################
# MongoDB
################################################################################

provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

locals {
  mongodb_subnets = var.existing_mongodb_subnet != null ? var.existing_mongodb_subnet : try(module.network[0].mongodb_subnet_id, null)
}

module "mongodb" {
  source = "./modules/mongodb"
  count  = var.create_mongodb ? 1 : 0

  name                = var.name
  resource_group_name = local.resource_group_name
  location            = var.location
  vnet_cidr           = local.vnet_cidr
  subnet_id           = local.mongodb_subnets

  mongodb_version                    = var.mongodb_version
  atlas_org_id                       = var.mongodb_atlas_org_id
  termination_protection_enabled     = var.mongodb_termination_protection_enabled
  db_audit_enable                    = var.mongodb_audit_enable
  atlas_auto_scaling_disk_gb_enabled = var.mongodb_atlas_auto_scaling_disk_gb_enabled
  atlas_disk_size                    = var.mongodb_atlas_disk_size
  atlas_instance_type                = var.mongodb_atlas_instance_type
  mongodb_admin_username             = var.mongodb_admin_username
  enable_slack_alerts                = var.mongodb_enable_slack_alerts
  slack_api_token                    = var.mongodb_slack_api_token
  slack_notification_channel         = var.mongodb_slack_notification_channel

  tags = var.tags
}


################################################################################
# Helm Charts
################################################################################

provider "helm" {
  kubernetes = {
    host                   = local.aks_cluster_host
    client_certificate     = try(base64decode(local.aks_client_certificate), "")
    client_key             = try(base64decode(local.aks_client_key), "")
    cluster_ca_certificate = try(base64decode(local.aks_cluster_ca_certificate), "")
  }
}

provider "kubectl" {
  host                   = local.aks_cluster_host
  client_certificate     = try(base64decode(local.aks_client_certificate), "")
  client_key             = try(base64decode(local.aks_client_key), "")
  cluster_ca_certificate = try(base64decode(local.aks_cluster_ca_certificate), "")
  load_config_file       = false
}


module "ingress_nginx" {
  source = "./modules/ingress-nginx"
  count  = var.install_helm_charts && var.ingress_nginx ? 1 : 0

  name                                      = var.name
  resource_group_name                       = local.resource_group_name
  location                                  = var.location
  aks_managed_resource_group_name           = local.aks_managed_resource_group_name
  ingress_pl_subnet_id                      = local.aks_nodes_subnet_id
  internet_facing_ingress_lb                = var.internet_facing_ingress_lb
  create_ingress_pl_service                 = var.create_ingress_pl_service
  ingress_pl_visibility_subscription_ids    = var.ingress_pl_visibility_subscription_ids
  ingress_pl_auto_approval_subscription_ids = var.ingress_pl_auto_approval_subscription_ids

  custom_values_templatefile = var.ingress_nginx_values
  custom_values_variables    = var.ingress_nginx_variables

  tags = var.tags

  depends_on = [local.aks_cluster_name]
}

module "cert_manager" {
  source = "./modules/cert-manager"
  count  = var.install_helm_charts && var.cert_manager ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  aks_oidc_issuer_url        = local.aks_cluster_oidc_issuer_url
  hosted_zone_id             = local.public_zone_id
  letsencrypt_clusterissuers = var.cert_manager_letsencrypt_clusterissuers
  hosted_zone_name           = var.domain_name
  email_address              = var.cert_manager_letsencrypt_email_address
  subscription_id            = data.azurerm_subscription.current.subscription_id

  custom_values_templatefile = var.cert_manager_values
  custom_values_variables    = var.cert_manager_variables

  tags = var.tags
}

module "external_dns" {
  source = "./modules/external-dns"
  count  = var.install_helm_charts && var.external_dns ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location
  subscription_id     = data.azurerm_subscription.current.subscription_id
  aks_cluster_name    = local.aks_cluster_name
  aks_oidc_issuer_url = local.aks_cluster_oidc_issuer_url
  hosted_zone_name    = var.domain_name
  hosted_zone_id      = var.internet_facing_ingress_lb ? local.public_zone_id : local.private_zone_id

  custom_values_templatefile = var.external_dns_values
  custom_values_variables    = var.external_dns_variables

  tags = var.tags
}

module "nvidia_device_plugin" {
  source = "./modules/nvidia-device-plugin"
  count  = var.install_helm_charts && var.nvidia_device_plugin ? 1 : 0

  custom_values_templatefile = var.nvidia_device_plugin_values
  custom_values_variables    = var.nvidia_device_plugin_variables

  depends_on = [local.aks_cluster_name]
}

module "descheduler" {
  source = "./modules/descheduler"
  count  = var.install_helm_charts && var.descheduler ? 1 : 0

  custom_values_templatefile = var.descheduler_values
  custom_values_variables    = var.descheduler_variables

  depends_on = [local.aks_cluster_name]
}
