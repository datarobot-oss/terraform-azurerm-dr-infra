
locals {
  name      = "ingress-nginx"
  namespace = "ingress-nginx"
}

resource "helm_release" "this" {
  name       = local.name
  namespace  = local.namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = local.name
  version    = "4.11.5"

  create_namespace = true

  values = [
    templatefile("${path.module}/values.yaml", {
      internal = !var.internet_facing_ingress_lb
    }),
    var.values_overrides
  ]
}

data "azurerm_lb" "internal_ingress" {
  count = var.internet_facing_ingress_lb ? 0 : 1

  name                = "kubernetes-internal"
  resource_group_name = var.aks_managed_resource_group_name

  depends_on = [helm_release.this]
}
