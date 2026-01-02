variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "name" {
  description = "Name of the user assigned identity"
  type        = string
}

variable "aks_oidc_issuer_url" {
  description = "OIDC issuer URL of the AKS cluster"
  type        = string
}

variable "datarobot_namespace" {
  description = "Namespace in which the DataRobot application will be installed"
  type        = string
}

variable "datarobot_service_accounts" {
  description = "Service accounts used by the DataRobot application"
  type        = set(string)
}

variable "storage_account_id" {
  description = "ID of storage account to provide Storage Blob Contributor"
  type        = string
}

variable "create_storage" {
  description = "Indicates whether storage account should be created by module or existing one used"
  type        = bool
}

variable "acr_id" {
  description = "ID of the Azure Container Registry to provide AcrPush access"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}
