resource "azurerm_kubernetes_cluster" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name                      = var.name
  dns_prefix                = var.name
  sku_tier                  = "Standard"
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  # http_proxy_config {
  #   no_proxy = [var.node_pool_subnet_cidr]
  # }

  default_node_pool {
    name                         = "system"
    temporary_name_for_rotation  = "systemrota"
    only_critical_addons_enabled = true
    vnet_subnet_id               = var.node_pool_subnet_id
    zones                        = [1, 2, 3]
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

resource "azurerm_role_assignment" "network" {
  scope                = var.node_pool_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

resource "azurerm_kubernetes_cluster_node_pool" "primary" {
  name                  = "primary"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

  vnet_subnet_id = var.node_pool_subnet_id
  zones          = [1, 2, 3]

  vm_size         = var.primary_node_pool_vm_size
  os_disk_size_gb = 500

  fips_enabled            = false
  host_encryption_enabled = false
  auto_scaling_enabled    = true
  node_count              = var.primary_node_pool_node_count
  min_count               = var.primary_node_pool_min_count
  max_count               = var.primary_node_pool_max_count

  node_labels = {}
  node_taints = []

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
