variable "resource_group_name" {
  description = "Name of the Resource Group for the Key Vault"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}

variable "container_registry_id" {
  description = "ID of the container registry to create the cache rule in"
  type        = string
}

variable "rule_name" {
  description = "Name of the cache rule. Also used as the target repository prefix in the container registry."
  type        = string
}

variable "credential_set_name" {
  description = "Name of the container registry credential set holding the Docker Hub credentials"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault created to store the Docker Hub credentials. Ignored when existing secret IDs are provided."
  type        = string
}

variable "dockerhub_username" {
  description = "Docker Hub username. Required unless existing secret IDs are provided."
  type        = string
  default     = null
}

variable "dockerhub_access_token" {
  description = "Docker Hub personal access token. Required unless existing secret IDs are provided."
  type        = string
  default     = null
  sensitive   = true
}

variable "existing_username_secret_id" {
  description = "Versionless ID of an existing Key Vault secret holding the Docker Hub username"
  type        = string
  default     = null
}

variable "existing_password_secret_id" {
  description = "Versionless ID of an existing Key Vault secret holding the Docker Hub access token"
  type        = string
  default     = null
}
