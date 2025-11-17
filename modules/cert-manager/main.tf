locals {
  name            = "cert-manager"
  namespace       = "cert-manager"
  service_account = "cert-manager"
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

resource "helm_release" "this" {
  name       = local.name
  namespace  = local.namespace
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.16.1"

  create_namespace = true

  values = [
    templatefile("${path.module}/values.yaml", {
      clientId = azurerm_user_assigned_identity.this.client_id
    }),
    var.values_overrides
  ]

  depends_on = [azurerm_role_assignment.dns_zone_contributor]
}

resource "helm_release" "letsencrypt_clusterissuers" {
  count = var.letsencrypt_clusterissuers ? 1 : 0

  name       = "letsencrypt-clusterissuers"
  namespace  = local.namespace
  repository = "https://dysnix.github.io/charts"
  chart      = "raw"
  version    = "0.3.2"

  values = [
    <<-EOF
    resources:
      - apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: letsencrypt-staging
        spec:
          acme:
            server: https://acme-staging-v02.api.letsencrypt.org/directory
            email: ${var.email_address}
            privateKeySecretRef:
              name: letsencrypt-staging
            solvers:
            - dns01:
                azureDNS:
                  hostedZoneName: ${var.hosted_zone_name}
                  resourceGroupName: ${var.resource_group_name}
                  subscriptionID: ${var.subscription_id}
                  environment: AzurePublicCloud
                  managedIdentity:
                    clientID: ${azurerm_user_assigned_identity.this.client_id}
      - |
          apiVersion: cert-manager.io/v1
          kind: ClusterIssuer
          metadata:
            name: letsencrypt-prod
          spec:
            acme:
              server: https://acme-v02.api.letsencrypt.org/directory
              email: ${var.email_address}
              privateKeySecretRef:
                name: letsencrypt-prod
              solvers:
              - dns01:
                  azureDNS:
                    hostedZoneName: ${var.hosted_zone_name}
                    resourceGroupName: ${var.resource_group_name}
                    subscriptionID: ${var.subscription_id}
                    environment: AzurePublicCloud
                    managedIdentity:
                      clientID: ${azurerm_user_assigned_identity.this.client_id}
    EOF
  ]

  depends_on = [helm_release.this]
}
