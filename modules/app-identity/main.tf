resource "azurerm_user_assigned_identity" "datarobot" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = var.name

  tags = var.tags
}

resource "azurerm_role_assignment" "storage" {
  count                            = var.create_storage ? 1 : 0
  scope                            = var.storage_account_id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azurerm_user_assigned_identity.datarobot.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPush"
  principal_id                     = azurerm_user_assigned_identity.datarobot.principal_id
  skip_service_principal_aad_check = true
}


resource "azurerm_federated_identity_credential" "datarobot" {
  for_each = var.datarobot_service_accounts

  resource_group_name = var.resource_group_name

  name      = "${var.name}-${each.value}-fic"
  parent_id = azurerm_user_assigned_identity.datarobot.id
  issuer    = var.aks_oidc_issuer_url
  subject   = "system:serviceaccount:${var.datarobot_namespace}:${each.value}"
  audience  = ["api://AzureADTokenExchange"]
}
