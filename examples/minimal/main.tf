provider "azurerm" {
  features {}
}

locals {
  name = "datarobot"
}


module "datarobot_infra" {
  source = "datarobot-oss/dr-infra/azurerm"

  name                                   = local.name
  domain_name                            = "${local.name}.yourdomain.com"
  location                               = "westus2"
  public_ip_allow_list                   = ["123.123.123.123/32"]
  cert_manager_letsencrypt_email_address = "youremail@yourdomain.com"

  tags = {
    application = local.name
    environment = "dev"
    managed-by  = "terraform"
  }
}
