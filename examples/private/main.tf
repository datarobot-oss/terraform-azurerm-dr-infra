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

  # Deploy into an existing VNet. The AKS node subnet within that VNet must be
  # provided as a full subnet resource ID.
  existing_vnet_name              = var.existing_vnet_name
  existing_kubernetes_node_subnet = var.existing_kubernetes_node_subnet

  # Disable public access to the AKS API server, creating a private cluster. The
  # host running "terraform apply" must be able to reach the private API endpoint
  # (e.g. running within the VNet or reachable via VPN/peering) in order to
  # install the helm charts.
  kubernetes_cluster_endpoint_public_access = false

  internet_facing_ingress_lb = false
  # Allow a CIDR to access the internal ingress load balancer
  ingress_nginx_values_overrides = <<-EOT
    controller:
      service:
        loadBalancerSourceRanges:
          - "${var.ingress_allowed_cidr}"
  EOT

  tags = merge(
    {
      app         = var.name
      environment = var.environment
    },
    var.tags
  )
}
