provider "azurerm" {
  features {}
}

locals {
  name = "datarobot"
}


module "datarobot_infra" {
  source = "../.."

  name        = local.name
  domain_name = "${local.name}.yourdomain.com"
  location    = "westus2"

  cert_manager_letsencrypt_email_address = "youremail@yourdomain.com"

  tags = {
    application = local.name
    environment = "dev"
    managed-by  = "terraform"
  }
}
