data "azurerm_client_config" "current" {}

locals {
  create_key_vault = var.existing_username_secret_id == null && var.existing_password_secret_id == null
}

resource "azurerm_key_vault" "this" {
  count = local.create_key_vault ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location

  name                       = var.key_vault_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  tags = var.tags
}

resource "azurerm_role_assignment" "deployer_secrets_officer" {
  count = local.create_key_vault ? 1 : 0

  scope                = azurerm_key_vault.this[0].id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "username" {
  count = local.create_key_vault ? 1 : 0

  key_vault_id = azurerm_key_vault.this[0].id
  name         = "dockerhub-username"
  value        = var.dockerhub_username != null ? var.dockerhub_username : ""

  depends_on = [azurerm_role_assignment.deployer_secrets_officer]
}

resource "azurerm_key_vault_secret" "password" {
  count = local.create_key_vault ? 1 : 0

  key_vault_id = azurerm_key_vault.this[0].id
  name         = "dockerhub-access-token"
  value        = var.dockerhub_access_token != null ? var.dockerhub_access_token : ""

  depends_on = [azurerm_role_assignment.deployer_secrets_officer]

  lifecycle {
    precondition {
      condition     = var.dockerhub_username != null && var.dockerhub_access_token != null
      error_message = "Docker Hub username and access token are required unless existing Key Vault secret IDs are provided."
    }
  }
}

resource "azurerm_container_registry_credential_set" "this" {
  name                  = var.credential_set_name
  container_registry_id = var.container_registry_id
  login_server          = "docker.io"

  identity {
    type = "SystemAssigned"
  }

  authentication_credentials {
    username_secret_id = local.create_key_vault ? azurerm_key_vault_secret.username[0].versionless_id : var.existing_username_secret_id
    password_secret_id = local.create_key_vault ? azurerm_key_vault_secret.password[0].versionless_id : var.existing_password_secret_id
  }

  lifecycle {
    precondition {
      condition     = (var.existing_username_secret_id == null) == (var.existing_password_secret_id == null)
      error_message = "Existing username and password secret IDs must be provided together."
    }
  }
}

resource "azurerm_role_assignment" "credential_set_secrets_user" {
  count = local.create_key_vault ? 1 : 0

  scope                = azurerm_key_vault.this[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_registry_credential_set.this.identity[0].principal_id
}

resource "azurerm_container_registry_cache_rule" "this" {
  name                  = var.rule_name
  container_registry_id = var.container_registry_id
  source_repo           = "docker.io/*"
  target_repo           = "${var.rule_name}/*"
  credential_set_id     = azurerm_container_registry_credential_set.this.id

  depends_on = [azurerm_role_assignment.credential_set_secrets_user]
}
