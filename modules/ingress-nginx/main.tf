
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.5"

  create_namespace = true

  values = [
    templatefile("${path.module}/common.yaml", {}),
    templatefile(var.internet_facing_ingress_lb ? "${path.module}/internet_facing.yaml" : "${path.module}/internal.yaml", {}),
    var.custom_values_templatefile != "" ? templatefile(var.custom_values_templatefile, var.custom_values_variables) : ""
  ]
}

data "azurerm_lb" "internal_ingress" {
  count = var.internet_facing_ingress_lb ? 0 : 1

  name                = "kubernetes-internal"
  resource_group_name = var.aks_managed_resource_group_name

  depends_on = [helm_release.ingress_nginx]
}

resource "azurerm_private_link_service" "internal_ingress" {
  count = var.create_ingress_pl_service && !var.internet_facing_ingress_lb ? 1 : 0

  name                = "${var.name}-ingress-pl-service"
  resource_group_name = var.resource_group_name
  location            = var.location

  visibility_subscription_ids                 = var.ingress_pl_visibility_subscription_ids
  auto_approval_subscription_ids              = var.ingress_pl_auto_approval_subscription_ids
  load_balancer_frontend_ip_configuration_ids = [data.azurerm_lb.internal_ingress[0].frontend_ip_configuration[0].id]

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address_version = "IPv4"
    subnet_id                  = var.ingress_pl_subnet_id
    primary                    = true
  }

  tags = var.tags
}
