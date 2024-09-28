provider "azurerm" {
  features {}
}

locals {
  name               = "datarobot"
  location           = "westus2"
  domain_name        = "${local.name}.yourdomain.com"
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

  tags = local.tags
}
