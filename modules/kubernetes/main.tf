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
    for_each = var.cluster_endpoint_authorized_ip_ranges != null ? ["api_server_access_profile"] : []
    content {
      authorized_ip_ranges = var.cluster_endpoint_authorized_ip_ranges
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    outbound_type       = "userAssignedNATGateway"
  }

  auto_scaler_profile {
    expander                                   = "least-waste"
    balance_similar_node_groups                = true
    daemonset_eviction_for_empty_nodes_enabled = true
    skip_nodes_with_local_storage              = false
    skip_nodes_with_system_pods                = false
  }

  default_node_pool {
    name                         = "system"
    temporary_name_for_rotation  = "systemrota"
    only_critical_addons_enabled = true
    vnet_subnet_id               = var.nodepool_subnet_id
    zones                        = var.nodepool_availability_zones
    vm_size                      = "Standard_DS4_v2"
    auto_scaling_enabled         = true
    node_count                   = 1
    min_count                    = 1
    max_count                    = 3

    upgrade_settings {
      max_surge = "10%"
    }

    tags = merge(
      var.tags,
      { "k8s.io_cluster-autoscaler_node-template_taint_CriticalAddonsOnly" = "true:NoSchedule" }
    )
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
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
  for_each = var.nodepool_availability_zones

  name                  = "${var.primary_nodepool_name}az${each.value}"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

  vnet_subnet_id = var.nodepool_subnet_id
  zones          = [each.value]

  node_labels = var.primary_nodepool_labels
  node_taints = var.primary_nodepool_taints

  vm_size              = var.primary_nodepool_vm_size
  os_disk_size_gb      = 200
  auto_scaling_enabled = true
  node_count           = var.primary_nodepool_node_count
  min_count            = var.primary_nodepool_min_count
  max_count            = var.primary_nodepool_max_count

  upgrade_settings {
    max_surge = "10%"
  }

  tags = merge(
    var.tags,
    { for k, v in var.primary_nodepool_labels : "k8s.io_cluster-autoscaler_node-template_label_${replace(k, "///", "_")}" => v },
    { for taint in var.primary_nodepool_taints : "k8s.io_cluster-autoscaler_node-template_taint_${split("=", replace(taint, "///", "_"))[0]}" => split("=", taint)[1] }
  )

  lifecycle {
    ignore_changes = [node_count]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  for_each = var.nodepool_availability_zones

  name                  = "${var.gpu_nodepool_name}az${each.value}"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

  vnet_subnet_id = var.nodepool_subnet_id
  zones          = [each.value]

  node_labels = var.gpu_nodepool_labels
  node_taints = var.gpu_nodepool_taints

  vm_size              = var.gpu_nodepool_vm_size
  os_disk_size_gb      = 200
  auto_scaling_enabled = true
  node_count           = var.gpu_nodepool_node_count
  min_count            = var.gpu_nodepool_min_count
  max_count            = var.gpu_nodepool_max_count

  upgrade_settings {
    max_surge = "10%"
  }

  tags = merge(
    var.tags,
    { for k, v in var.gpu_nodepool_labels : "k8s.io_cluster-autoscaler_node-template_label_${replace(k, "///", "_")}" => v },
    { for taint in var.gpu_nodepool_taints : "k8s.io_cluster-autoscaler_node-template_taint_${split("=", replace(taint, "///", "_"))[0]}" => split("=", taint)[1] }
  )

  lifecycle {
    ignore_changes = [node_count]
  }
}
