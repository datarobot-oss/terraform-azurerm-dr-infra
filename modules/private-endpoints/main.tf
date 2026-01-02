locals {
  storage_account_name = try(regex("storageAccounts/([^/]+)$", var.storage_account_id)[0], null)

  storage_config = local.storage_account_name != null ? [
    for type in var.private_storage_endpoints : {
      pe_name              = "${var.name}-${local.storage_account_name}-${type}-pe"
      dns_zone_name        = "privatelink.${type}.core.windows.net"
      resource_id          = var.storage_account_id
      subresource_names    = [type]
      is_manual_connection = true
      request_message      = "Private endpoint request for DataRobot"
      create_dns_zone      = true
    }
  ] : []

  custom_config = [
    for ep in var.private_endpoint_config : {
      pe_name              = "${var.name}-${ep.private_dns_name}-pe"
      dns_zone_name        = ep.private_dns_zone
      resource_id          = ep.resource_id
      subresource_names    = ep.subresource_names
      is_manual_connection = true
      request_message      = ep.request_message
      create_dns_zone      = ep.create_dns_zone
    }
  ]

  all_endpoints_map = {
    for ep in concat(local.storage_config, local.custom_config) :
    ep.pe_name => ep
  }
}

resource "azurerm_private_dns_zone" "this" {
  for_each = { for k, v in local.all_endpoints_map : k => v if v.create_dns_zone }

  name                = each.value.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

data "azurerm_private_dns_zone" "existing" {
  for_each = { for k, v in local.all_endpoints_map : k => v if !v.create_dns_zone }

  name                = each.value.dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = { for k, v in local.all_endpoints_map : k => v if v.create_dns_zone }

  name                  = "${each.key}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = var.network_id
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "this" {
  for_each = local.all_endpoints_map

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = each.value.is_manual_connection
    request_message                = each.value.request_message
  }

  private_dns_zone_group {
    name = "default-dns-zone-group"
    private_dns_zone_ids = [
      each.value.create_dns_zone
      ? azurerm_private_dns_zone.this[each.key].id
      : data.azurerm_private_dns_zone.existing[each.key].id
    ]
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.this
  ]
}
