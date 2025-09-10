output "id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "host" {
  description = "Host used to communicate with the kubernetes API"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
}

output "client_certificate" {
  description = "The base64 encoded public certificate used by clients to authenticate to the kubernetes cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
}

output "client_key" {
  description = "The base64 encoded private key used by clients to authenticate to the kubernetes cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_key
}

output "cluster_ca_certificate" {
  description = "The base64 encoded public CA certificate used as the root of trust for the kubernetes cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
}

output "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}
