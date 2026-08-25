provider "azurerm" {
  features {}
}

locals {
  name                    = "datarobot"
  subscription_id         = "existing-subscription-id"
  resource_group_name     = "existing-resource-group-name"
  vnet_name               = "existing-virtual-network-name"
  subnet_name             = "existing-subnet-name"
  domain_name             = "yourdomain.com"
  storage_account_name    = "existingstorageaccount"
  container_registry_name = "existingcontainerregistry"
  aks_cluster_name        = "existing-aks-cluster-name"
}


module "datarobot_infra" {
  source = "../.."

  name        = local.name
  domain_name = local.domain_name
  location    = "westus2"

  existing_resource_group_name    = local.resource_group_name
  existing_vnet_name              = local.vnet_name
  existing_private_dns_zone_id    = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/privateDnsZones/${local.domain_name}"
  existing_storage_account_id     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"
  existing_container_registry_id  = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.ContainerRegistry/registries/${local.container_registry_name}"
  existing_kubernetes_node_subnet = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/${local.subnet_name}"
  existing_aks_cluster_name       = local.aks_cluster_name

  kubernetes_cluster_endpoint_public_access = false
  internet_facing_ingress_lb                = false

  # bring your own clusterissuer/cert to the DataRobot helm chart
  cert_manager_letsencrypt_clusterissuers = false

  tags = {
    application = local.name
    environment = "dev"
    managed-by  = "terraform"
  }
}
