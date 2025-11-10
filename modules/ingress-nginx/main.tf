
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
