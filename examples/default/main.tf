provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id                 = "812dbb7b-f095-43d9-a4d2-0035b7e842f1"
  features {}
  use_cli = true
}

locals {
  name               = "garrett"
  location           = "westus2"
  domain_name        = "${local.name}.rd.int.datarobot.com"
  vnet_address_space = "10.7.0.0/16"

  tags = {
    application = local.name
    environment = "dev"
    managed-by  = "terraform"
  }
}


module "datarobot_infra" {
  source = "../.."

  name               = local.name
  location           = local.location
  domain_name        = local.domain_name
  vnet_address_space = local.vnet_address_space

  create_aks_gpu_node_pool   = true
  internet_facing_ingress_lb = true
  cert_manager_email_address = "garrett.schultz@datarobot.com"

  tags = local.tags
}
