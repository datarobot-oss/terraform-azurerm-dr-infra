provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id                 = "812dbb7b-f095-43d9-a4d2-0035b7e842f1"
  features {}
  use_cli = true
}

locals {
  name = "datarobot"
}


module "datarobot_infra" {
  source = "../.."

  name               = local.name
  location           = "westus2"
  domain_name        = "${local.name}.yourdomain.com"
  vnet_address_space = "10.7.0.0/16"

  create_resource_group         = true
  create_vnet                   = true
  create_dns_zone               = true
  create_storage                = true
  create_container_registry     = true
  create_aks_cluster            = true
  create_aks_gpu_node_pool      = true
  create_user_assigned_identity = true

  ingress_nginx              = true
  internet_facing_ingress_lb = true
  cert_manager               = true
  cert_manager_email_address = "garrett.schultz@datarobot.com"
  external_dns               = true
  nvidia_device_plugin       = true

  tags = {
    application = local.name
    environment = "dev"
    managed-by  = "terraform"
  }
}
