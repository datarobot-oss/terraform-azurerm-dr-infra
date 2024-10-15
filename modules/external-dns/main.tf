resource "azurerm_user_assigned_identity" "external_dns" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "external-dns-uai"

  tags = var.tags
}

resource "azurerm_federated_identity_credential" "external_dns" {
  resource_group_name = var.resource_group_name

  name      = "external-dns-uai-fic"
  parent_id = azurerm_user_assigned_identity.external_dns.id
  issuer    = var.aks_oidc_issuer_url
  subject   = "system:serviceaccount:external-dns:external-dns"
  audience  = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "external_dns_dns" {
  scope                            = var.hosted_zone_id
  role_definition_name             = "DNS Zone Contributor"
  principal_id                     = azurerm_user_assigned_identity.external_dns.principal_id
  skip_service_principal_aad_check = true
}

module "external_dns" {
  source     = "terraform-module/release/helm"
  version    = "~> 2.0"
  depends_on = [azurerm_role_assignment.external_dns_dns]

  namespace  = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"

  app = {
    name             = "external-dns"
    version          = "8.3.5"
    chart            = "external-dns"
    create_namespace = true
    wait             = true
    recreate_pods    = false
    deploy           = 1
    timeout          = 600
  }

  values = [
    templatefile("${path.module}/values.tftpl", {
      domain         = var.hosted_zone_name,
      clusterName    = var.aks_cluster_name,
      resourceGroup  = var.resource_group_name,
      clientId       = azurerm_user_assigned_identity.external_dns.client_id,
      tenantId       = azurerm_user_assigned_identity.external_dns.tenant_id,
      subscriptionId = var.subscription_id
    }),
    var.custom_values_templatefile != "" ? templatefile(var.custom_values_templatefile, var.custom_values_variables) : ""
  ]
}
