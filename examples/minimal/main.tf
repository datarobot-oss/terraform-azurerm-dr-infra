provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id                 = "812dbb7b-f095-43d9-a4d2-0035b7e842f1"
  features {}
  use_cli = true
}

locals {
  name = "garrett"
}


module "datarobot_infra" {
  source = "../.."

  name                       = local.name
  location                   = "westus2"
  domain_name                = "${local.name}.rd.int.datarobot.com"
  cert_manager_email_address = "garrett.schultz@datarobot.com"

  tags = {
    application = local.name
    environment = "dev"
    managed-by  = "terraform"
  }
}
