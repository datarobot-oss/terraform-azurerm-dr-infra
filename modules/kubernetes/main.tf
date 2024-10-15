resource "azurerm_kubernetes_cluster" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name                      = var.name
  dns_prefix                = var.name
  sku_tier                  = "Standard"
  kubernetes_version        = var.cluster_version
  workload_identity_enabled = true
  oidc_issuer_enabled       = true
  private_cluster_enabled   = var.private_cluster

  identity {
    type = "SystemAssigned"
  }

  dynamic "api_server_access_profile" {
    for_each = var.cluster_endpoint_public_access_cidrs != null ? ["api_server_access_profile"] : []
    content {
      authorized_ip_ranges = var.cluster_endpoint_public_access_cidrs
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    outbound_type       = "userAssignedNATGateway"
  }

  default_node_pool {
    name                         = "system"
    temporary_name_for_rotation  = "systemrota"
    only_critical_addons_enabled = true
    vnet_subnet_id               = var.nodepool_subnet_id
    zones                        = var.nodepool_availability_zones
    vm_size                      = "Standard_DS4_v2"
    node_count                   = 3

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }

    tags = var.tags
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "aks_nodepool_subnet" {
  principal_id                     = azurerm_kubernetes_cluster.this.identity[0].principal_id
  role_definition_name             = "Network Contributor"
  scope                            = var.nodepool_subnet_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_kubelet_acr" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.container_registry_id
  skip_service_principal_aad_check = true
}

resource "azurerm_kubernetes_cluster_node_pool" "primary" {
  name                  = var.primary_nodepool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

  vnet_subnet_id = var.nodepool_subnet_id
  zones          = var.nodepool_availability_zones

  node_labels = var.primary_nodepool_labels
  node_taints = var.primary_nodepool_taints

  vm_size              = var.primary_nodepool_vm_size
  os_disk_size_gb      = 500
  auto_scaling_enabled = true
  node_count           = var.primary_nodepool_node_count
  min_count            = var.primary_nodepool_min_count
  max_count            = var.primary_nodepool_max_count

  upgrade_settings {
    drain_timeout_in_minutes      = 0
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 0
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  name                  = var.gpu_nodepool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

  vnet_subnet_id = var.nodepool_subnet_id
  zones          = var.nodepool_availability_zones

  node_labels = var.gpu_nodepool_labels
  node_taints = var.gpu_nodepool_taints

  vm_size              = var.gpu_nodepool_vm_size
  os_disk_size_gb      = 500
  auto_scaling_enabled = true
  node_count           = var.gpu_nodepool_node_count
  min_count            = var.gpu_nodepool_min_count
  max_count            = var.gpu_nodepool_max_count

  upgrade_settings {
    drain_timeout_in_minutes      = 0
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 0
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}
