locals {
  cloud_provider = "AZURE"
  region         = lookup(local.atlas_regions, var.location)
}

resource "mongodbatlas_project" "this" {
  org_id = var.atlas_org_id
  name   = var.name
}

resource "mongodbatlas_project_ip_access_list" "this" {
  project_id = mongodbatlas_project.this.id
  cidr_block = var.vnet_cidr
  comment    = "cidr block for Azure VNet"
}

resource "mongodbatlas_privatelink_endpoint" "this" {
  project_id    = mongodbatlas_project.this.id
  provider_name = local.cloud_provider
  region        = local.region
}

resource "azurerm_private_endpoint" "this" {
  name                = "${var.name}-mongodb"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  private_service_connection {
    name                           = mongodbatlas_privatelink_endpoint.this.private_link_service_name
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.this.private_link_service_resource_id
    is_manual_connection           = true
    request_message                = "Azure Private Link Mongo Atlas Setup"
  }

  tags = var.tags
}

resource "mongodbatlas_privatelink_endpoint_service" "this" {
  project_id                  = mongodbatlas_privatelink_endpoint.this.project_id
  private_link_id             = mongodbatlas_privatelink_endpoint.this.id
  endpoint_service_id         = azurerm_private_endpoint.this.id
  private_endpoint_ip_address = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
  provider_name               = local.cloud_provider
}

resource "mongodbatlas_advanced_cluster" "this" {
  project_id   = mongodbatlas_project.this.id
  name         = var.name
  cluster_type = "REPLICASET"

  mongo_db_major_version         = var.mongodb_version
  backup_enabled                 = true
  pit_enabled                    = true
  termination_protection_enabled = var.termination_protection_enabled

  replication_specs = [{
    region_configs = [{
      provider_name = local.cloud_provider
      region_name   = local.region
      priority      = 7

      electable_specs = {
        instance_size = var.atlas_instance_type
        disk_size_gb  = var.atlas_disk_size
        node_count    = 3
      }

      auto_scaling = {
        disk_gb_enabled = var.atlas_auto_scaling_disk_gb_enabled
      }
    }]
  }]

  advanced_configuration = {
    javascript_enabled           = true
    minimum_enabled_tls_protocol = "TLS1_2"
  }

  lifecycle {
    ignore_changes = [replication_specs[0].region_configs[0].electable_specs.disk_size_gb]
  }

  depends_on = [mongodbatlas_privatelink_endpoint_service.this]
}

resource "mongodbatlas_cloud_backup_schedule" "this" {
  project_id   = mongodbatlas_project.this.id
  cluster_name = mongodbatlas_advanced_cluster.this.name

  policy_item_hourly {
    frequency_interval = 6 #accepted values = 1, 2, 4, 6, 8, 12 -> every n hours
    retention_unit     = "days"
    retention_value    = 7
  }
  policy_item_daily {
    frequency_interval = 1 #accepted values = 1 -> every 1 day
    retention_unit     = "days"
    retention_value    = 30
  }
  policy_item_weekly {
    frequency_interval = 6 # accepted values = 1 to 7 -> every 1=Monday,2=Tuesday,3=Wednesday,4=Thursday,5=Friday,6=Saturday,7=Sunday day of the week
    retention_unit     = "days"
    retention_value    = 30
  }
  policy_item_monthly {
    frequency_interval = 1 # accepted values = 1 to 28 -> 1 to 28 every nth day of the month
    # accepted values = 40 -> every last day of the month
    retention_unit  = "months"
    retention_value = 1
  }
  copy_settings {
    cloud_provider = local.cloud_provider
    frequencies = [
      "HOURLY",
      "DAILY",
      "WEEKLY",
      "MONTHLY",
      "ON_DEMAND"
    ]
    region_name        = lookup(local.atlas_copy_regions, local.region)
    zone_id            = mongodbatlas_advanced_cluster.this.replication_specs[0].zone_id
    should_copy_oplogs = true
  }
}

# https://www.mongodb.com/docs/atlas/security-private-endpoint/#port-ranges-used-for-private-endpoints
resource "azurerm_network_security_group" "mongo_atlas_pl" {
  name                = "${var.name}-mongodb"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "vnet-to-atlas-pe"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "1024"
    destination_port_range     = "65535"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }
  tags = var.tags
}
