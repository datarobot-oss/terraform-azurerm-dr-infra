locals {
  create_uai = var.identity_type == "user_assigned_identity"
  create_app = var.identity_type == "azuread_application"

  principal_id = local.create_uai ? azurerm_user_assigned_identity.datarobot[0].principal_id : azuread_service_principal.datarobot[0].object_id
}


################################################################################
# User Assigned Identity
################################################################################

resource "azurerm_user_assigned_identity" "datarobot" {
  count = local.create_uai ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location

  name = var.name

  tags = var.tags
}

moved {
  from = azurerm_user_assigned_identity.datarobot
  to   = azurerm_user_assigned_identity.datarobot[0]
}

resource "azurerm_federated_identity_credential" "datarobot" {
  for_each = local.create_uai ? var.datarobot_service_accounts : []

  resource_group_name = var.resource_group_name

  name      = "${var.name}-${each.value}-fic"
  parent_id = azurerm_user_assigned_identity.datarobot[0].id
  issuer    = var.aks_oidc_issuer_url
  subject   = "system:serviceaccount:${var.datarobot_namespace}:${each.value}"
  audience  = ["api://AzureADTokenExchange"]
}


################################################################################
# AzureAD Application
################################################################################

data "azuread_client_config" "current" {
  count = local.create_app ? 1 : 0
}

locals {
  azuread_application_owners = local.create_app ? coalescelist(var.azuread_application_owners, [data.azuread_client_config.current[0].object_id]) : []
}

resource "azuread_application" "datarobot" {
  count = local.create_app ? 1 : 0

  display_name     = var.name
  owners           = local.azuread_application_owners
  sign_in_audience = var.azuread_application_sign_in_audience
}

resource "azuread_service_principal" "datarobot" {
  count = local.create_app ? 1 : 0

  client_id = azuread_application.datarobot[0].client_id
  owners    = local.azuread_application_owners
}

resource "azuread_application_federated_identity_credential" "datarobot" {
  for_each = local.create_app ? var.datarobot_service_accounts : []

  application_id = azuread_application.datarobot[0].id
  display_name   = "${var.name}-${each.value}-fic"
  issuer         = var.aks_oidc_issuer_url
  subject        = "system:serviceaccount:${var.datarobot_namespace}:${each.value}"
  audiences      = ["api://AzureADTokenExchange"]
}

resource "azuread_application_password" "datarobot" {
  count = local.create_app && var.create_azuread_application_password ? 1 : 0

  application_id = azuread_application.datarobot[0].id
}


################################################################################
# Role Assignments
################################################################################

resource "azurerm_role_assignment" "storage" {
  count                            = var.create_storage ? 1 : 0
  scope                            = var.storage_account_id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = local.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPush"
  principal_id                     = local.principal_id
  skip_service_principal_aad_check = true
}
