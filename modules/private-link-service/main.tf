resource "azurerm_private_link_service" "internal_ingress" {
  name                = "${var.name}-ingress-pl-service"
  resource_group_name = var.resource_group_name
  location            = var.location

  visibility_subscription_ids                 = var.ingress_pl_visibility_subscription_ids
  auto_approval_subscription_ids              = var.ingress_pl_auto_approval_subscription_ids
  load_balancer_frontend_ip_configuration_ids = var.load_balancer_frontend_ip_configuration_ids

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address_version = "IPv4"
    subnet_id                  = var.pl_subnet_id
    primary                    = true
  }

  tags = var.tags
}
