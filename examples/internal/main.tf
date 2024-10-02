provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id                 = "812dbb7b-f095-43d9-a4d2-0035b7e842f1"
  features {}
  use_cli = true
}

locals {
  name                    = "garrett"
  subscription_id         = "812dbb7b-f095-43d9-a4d2-0035b7e842f1"
  resource_group_name     = "${local.name}-rg"
  vnet_name               = "garrett-vnet"
  subnet_name             = "garrett-snet"
  domain_name             = "${local.name}.rd.int.datarobot.com"
  storage_account_name    = "garrettstn7fz"
  container_registry_name = "garrettacr"
}


module "datarobot_infra" {
  source = "../.."

  name        = local.name
  location    = "westus2"
  domain_name = local.domain_name

  resource_group_name       = local.resource_group_name
  vnet_id                   = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}"
  dns_zone_id               = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/dnszones/${local.domain_name}"
  storage_account_id        = "/subscriptions/${local.subscription_id}/resourceGroups/{local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"
  container_registry_id     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.ContainerRegistry/registries/${local.container_registry_name}"
  aks_node_pool_subnet_id   = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/${local.subnet_name}"
  aks_private_cluster       = true

  internet_facing_ingress_lb = false
  cert_manager_email_address = "garrett.schultz@datarobot.com"

  tags = {
    application = local.name
    environment = "dev"
    managed-by  = "terraform"
  }
}
