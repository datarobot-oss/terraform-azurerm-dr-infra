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
  resource_group_name = coalesce(var.resource_group_name, azurerm_resource_group.this[0].name)
}

resource "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 1 : 0

  location = var.location
  name     = coalesce(var.resource_group_name, module.naming.resource_group.name)
  tags     = var.tags
}


################################################################################
# Virtual Network
################################################################################

locals {
  vnet_id = var.create_vnet && var.vnet_id == "" ? module.vnet[0].id : var.vnet_id
}

module "vnet" {
  source = "./modules/vnet"
  count  = var.create_vnet && var.vnet_id == "" ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  name          = module.naming.virtual_network.name
  address_space = var.vnet_address_space
  subnet_name   = module.naming.subnet.name

  tags = var.tags
}


################################################################################
# DNS
################################################################################

locals {
  private_zone_id = var.create_dns_zones && var.zone_id == "" ? module.dns[0].private_zone_id : var.zone_id
  public_zone_id  = var.create_dns_zones && var.zone_id == "" ? module.dns[0].public_zone_id : var.zone_id
}

module "dns" {
  source = "./modules/dns"
  count  = var.create_dns_zones && var.zone_id == "" ? 1 : 0

  resource_group_name = local.resource_group_name
  domain_name         = var.domain_name

  tags = var.tags
}


################################################################################
# Storage
################################################################################

locals {
  storage_account_name   = var.create_storage && var.storage_account_name == "" ? module.storage[0].account_name : var.storage_account_name
  storage_account_id     = var.create_storage && var.storage_account_id == "" ? module.storage[0].account_id : var.storage_account_id
  storage_container_name = var.create_storage && var.storage_container_name == "" ? module.storage[0].container_name : var.storage_container_name
}

module "storage" {
  source = "./modules/storage"
  count  = var.create_storage && var.storage_account_name == "" ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  account_name             = module.naming.storage_account.name_unique
  container_name           = module.naming.storage_container.name
  account_replication_type = var.account_replication_type

  tags = var.tags
}


################################################################################
# Container Registry
################################################################################

locals {
  container_registry_id = var.create_container_registry && var.container_registry_id == "" ? module.acr[0].id : var.container_registry_id
}

module "acr" {
  source = "./modules/acr"
  count  = var.create_container_registry && var.container_registry_id == "" ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  name = module.naming.container_registry.name

  tags = var.tags
}


################################################################################
# AKS
################################################################################

module "aks" {
  source = "./modules/aks"
  count  = var.create_aks_cluster ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  name                         = module.naming.kubernetes_cluster.name
  node_pool_subnet_id          = var.create_aks_cluster && var.vnet_id == "" ? module.vnet[0].subnet_ids[0] : var.aks_node_pool_subnet_id
  node_pool_subnet_cidr        = module.vnet[0].subnet_cidrs[0][0]
  primary_node_pool_vm_size    = var.aks_primary_node_pool_vm_size
  primary_node_pool_node_count = var.aks_primary_node_pool_node_count
  primary_node_pool_min_count  = var.aks_primary_node_pool_min_count
  primary_node_pool_max_count  = var.aks_primary_node_pool_max_count

  tags = var.tags
}


################################################################################
# User Assigned Identity
################################################################################

module "uai" {
  source = "./modules/uai"
  count  = var.create_user_assigned_identity && var.user_assigned_identity_id == "" ? 1 : 0

  resource_group_name = local.resource_group_name
  location            = var.location

  name                       = module.naming.user_assigned_identity.name
  aks_oidc_issuer_url        = module.aks[0].oidc_issuer_url
  storage_account_id         = local.storage_account_id
  acr_id                     = local.container_registry_id
  datarobot_namespace        = var.datarobot_namespace
  datarobot_service_accounts = var.datarobot_service_accounts

  tags = var.tags
}


################################################################################
# Helm Charts
################################################################################

provider "helm" {
  kubernetes {
    host                   = try(module.aks[0].host, "")
    client_certificate     = base64decode(try(module.aks[0].client_certificate, ""))
    client_key             = base64decode(try(module.aks[0].client_key, ""))
    cluster_ca_certificate = base64decode(try(module.aks[0].cluster_ca_certificate, ""))
  }
}


module "ingress_nginx" {
  source     = "./modules/ingress-nginx"
  count      = var.create_aks_cluster && var.ingress_nginx ? 1 : 0
  depends_on = [module.aks]

  internet_facing_ingress_lb = var.internet_facing_ingress_lb

  custom_values_templatefile = var.ingress_nginx_values
  custom_values_variables    = var.ingress_nginx_variables
}

module "cert_manager" {
  source     = "./modules/cert-manager"
  count      = var.create_aks_cluster && var.cert_manager ? 1 : 0
  depends_on = [module.ingress_nginx]

  resource_group_name = local.resource_group_name
  location            = var.location

  email_address       = var.cert_manager_email_address
  subscription_id     = data.azurerm_subscription.current.subscription_id
  aks_oidc_issuer_url = module.aks[0].oidc_issuer_url
  hosted_zone_name    = var.domain_name
  hosted_zone_id      = local.public_zone_id

  custom_values_templatefile = var.cert_manager_values
  custom_values_variables    = var.cert_manager_variables

  tags = var.tags
}

module "external_dns" {
  source     = "./modules/external-dns"
  count      = var.create_aks_cluster && var.external_dns ? 1 : 0
  depends_on = [module.ingress_nginx]

  resource_group_name = local.resource_group_name
  location            = var.location
  subscription_id     = data.azurerm_subscription.current.subscription_id
  aks_cluster_name    = module.aks[0].name
  aks_oidc_issuer_url = module.aks[0].oidc_issuer_url
  hosted_zone_name    = var.domain_name
  hosted_zone_id      = local.public_zone_id

  custom_values_templatefile = var.external_dns_values
  custom_values_variables    = var.external_dns_variables

  tags = var.tags
}