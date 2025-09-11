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
    name                         = lookup(var.default_node_pool, "name", "system")
    temporary_name_for_rotation  = lookup(var.default_node_pool, "temporary_name_for_rotation", "systemtemp")
    only_critical_addons_enabled = true
    vnet_subnet_id               = var.node_pool_subnet_id
    zones                        = lookup(var.default_node_pool, "zones", null)
    vm_size                      = lookup(var.default_node_pool, "vm_size", "Standard_DS4_v2")
    host_encryption_enabled      = lookup(var.default_node_pool, "host_encryption_enabled", false)
    fips_enabled                 = lookup(var.default_node_pool, "fips_enabled", false)
    auto_scaling_enabled         = lookup(var.default_node_pool, "auto_scaling_enabled", true)
    node_count                   = lookup(var.default_node_pool, "node_count", 1)
    min_count                    = lookup(var.default_node_pool, "min_count", 1)
    max_count                    = lookup(var.default_node_pool, "max_count", 3)
    node_labels                  = lookup(var.default_node_pool, "node_labels", {})

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
      max_surge                     = "10%"
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
  scope                            = var.node_pool_subnet_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_kubelet_acr" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.container_registry_id
  skip_service_principal_aad_check = true
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  name                        = each.key
  temporary_name_for_rotation = "${each.key}temp"
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.this.id

  vnet_subnet_id = var.node_pool_subnet_id
  zones          = try(each.value.zones, null)

  vm_size                 = each.value.vm_size
  os_disk_size_gb         = try(each.value.os_disk_size_gb, null)
  host_encryption_enabled = try(each.value.host_encryption_enabled, false)
  fips_enabled            = try(each.value.fips_enabled, false)
  gpu_driver              = try(each.value.gpu_driver, "None")
  node_public_ip_enabled  = try(each.value.node_public_ip_enabled, false)
  auto_scaling_enabled    = try(each.value.auto_scaling_enabled, true)
  node_count              = try(each.value.node_count, 1)
  min_count               = try(each.value.min_count, 0)
  max_count               = try(each.value.max_count, 1)

  node_labels = try(each.value.node_labels, {})
  node_taints = try(each.value.node_taints, [])

  upgrade_settings {
    drain_timeout_in_minutes      = try(each.value.drain_timeout_in_minutes, 0)
    max_surge                     = try(each.value.max_surge, "10%")
    node_soak_duration_in_minutes = try(each.value.node_soak_duration_in_minutes, 0)
  }

  tags = merge(
    var.tags,
    { for k, v in each.value.node_labels : "k8s.io_cluster-autoscaler_node-template_label_${replace(k, "///", "_")}" => v },
    { for taint in each.value.node_taints : "k8s.io_cluster-autoscaler_node-template_taint_${split("=", replace(taint, "///", "_"))[0]}" => split("=", taint)[1] }
  )

  lifecycle {
    ignore_changes = [node_count]
  }
}
