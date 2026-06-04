provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

module "datarobot_infra" {
  source = "../.."

  name        = var.name
  location    = var.location
  domain_name = var.domain_name

  cert_manager_letsencrypt_email_address = var.email_address

  tags = merge(
    {
      app         = var.name
      environment = var.environment
    },
    var.tags
  )
}
