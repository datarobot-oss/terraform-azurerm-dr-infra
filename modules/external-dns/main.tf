locals {
  name            = "external-dns"
  namespace       = "external-dns"
  service_account = "external-dns"
}

resource "azurerm_user_assigned_identity" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "${local.name}-uai"

  tags = var.tags
}

resource "azurerm_federated_identity_credential" "this" {
  resource_group_name = var.resource_group_name

  name      = "${local.name}-uai-fic"
  parent_id = azurerm_user_assigned_identity.this.id
  issuer    = var.aks_oidc_issuer_url
  subject   = "system:serviceaccount:${local.namespace}:${local.service_account}"
  audience  = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "dns_zone_contributor" {
  scope                            = var.hosted_zone_id
  role_definition_name             = "DNS Zone Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "kubectl_manifest" "azure_json" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "external-dns-azure"
      namespace = local.namespace
    }
    data = {
      "azure.json" = base64encode(jsonencode({
        tenantId                     = azurerm_user_assigned_identity.this.tenant_id
        subscriptionId               = var.subscription_id
        resourceGroup                = var.resource_group_name
        useWorkloadIdentityExtension = true
      }))
    }
  })
}

resource "helm_release" "this" {
  name       = local.name
  namespace  = local.namespace
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = local.name
  version    = "1.19.0"

  create_namespace = true

  values = [
    templatefile("${path.module}/values.yaml", {
      domain      = var.hosted_zone_name
      clusterName = var.aks_cluster_name
      clientId    = azurerm_user_assigned_identity.this.client_id
    }),
    var.values_overrides
  ]

  depends_on = [
    azurerm_role_assignment.dns_zone_contributor,
    kubectl_manifest.azure_json
  ]
}
