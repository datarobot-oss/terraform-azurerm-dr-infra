
resource "azurerm_user_assigned_identity" "cert_manager" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "cert-manager-uai"

  tags = var.tags
}

resource "azurerm_federated_identity_credential" "cert_manager" {
  resource_group_name = var.resource_group_name

  name      = "cert-manager-uai-fic"
  parent_id = azurerm_user_assigned_identity.cert_manager.id
  issuer    = var.aks_oidc_issuer_url
  subject   = "system:serviceaccount:cert-manager:cert-manager"
  audience  = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "cert_manager_dns" {
  scope                            = var.hosted_zone_id
  role_definition_name             = "DNS Zone Contributor"
  principal_id                     = azurerm_user_assigned_identity.cert_manager.principal_id
  skip_service_principal_aad_check = true
}

module "cert_manager" {
  source     = "terraform-module/release/helm"
  version    = "~> 2.0"
  depends_on = [azurerm_role_assignment.cert_manager_dns]

  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"

  app = {
    name             = "cert-manager"
    version          = "1.16.1"
    chart            = "cert-manager"
    create_namespace = true
    wait             = true
    recreate_pods    = false
    deploy           = 1
    timeout          = 600
  }

  values = [
    templatefile("${path.module}/values.tftpl", {
      clientId = azurerm_user_assigned_identity.cert_manager.client_id
    }),
    var.custom_values_templatefile != "" ? templatefile(var.custom_values_templatefile, var.custom_values_variables) : ""
  ]
}

module "letsencrypt_clusterissuers" {
  source  = "terraform-module/release/helm"
  version = "~> 2.0"
  count   = var.letsencrypt_clusterissuers ? 1 : 0

  namespace  = "cert-manager"
  repository = "https://dysnix.github.io/charts"

  app = {
    name             = "letsencrypt-clusterissuers"
    version          = "0.3.2"
    chart            = "raw"
    create_namespace = true
    wait             = true
    recreate_pods    = false
    deploy           = 1
    timeout          = 600
  }
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
                    clientID: ${azurerm_user_assigned_identity.cert_manager.client_id}
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
                      clientID: ${azurerm_user_assigned_identity.cert_manager.client_id}
    EOF
  ]

  depends_on = [module.cert_manager]
}
