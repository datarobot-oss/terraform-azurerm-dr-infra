variable "grafana_admin_principal_ids" {
  description = "The principal ID for Grafana admin access in the observability module."
  type        = list(string)
}

variable "grafana_editor_principal_ids" {
  description = "The principal IDs for Grafana editor access in the observability module."
  type        = list(string)
  default     = []
}

variable "grafana_viewer_principal_ids" {
  description = "The principal IDs for Grafana viewer access in the observability module."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Default tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy observability resources into."
  type        = string
}

variable "location" {
  description = "The Azure region where the resource group exists."
  type        = string
}

variable "grafana_major_version" {
  description = "The major version of Grafana to deploy."
  type        = number
  default     = 11
}
