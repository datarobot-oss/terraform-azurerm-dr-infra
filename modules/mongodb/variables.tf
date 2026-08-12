variable "name" {
  description = "Name to use as a prefix for created resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the Redis Instance should exist"
  type        = string
}

variable "location" {
  description = "The Azure Region where the MongoDB Atlas private endpoint should exist"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR of the VNet"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint"
  type        = string
}

variable "mongodb_version" {
  description = "MongoDB version"
  type        = string
}

variable "atlas_org_id" {
  description = "Atlas organization ID"
  type        = string
}

variable "termination_protection_enabled" {
  description = "Enable protection to avoid accidental production cluster termination"
  type        = bool
}

variable "db_audit_enable" {
  type        = bool
  description = "Enable database auditing for production instances only(cost incurred 10%)"
}

variable "atlas_auto_scaling_disk_gb_enabled" {
  description = "Enable Atlas disk size autoscaling"
  type        = bool
}

variable "atlas_compute_auto_scaling_enabled" {
  description = "Enable Atlas compute autoscaling"
  type        = bool
  default     = false
}

variable "atlas_compute_auto_scaling_min_instance_size" {
  description = "Minimum instance size for Atlas compute autoscaling. Required when atlas_compute_auto_scaling_enabled is true."
  type        = string
  default     = null
}

variable "atlas_compute_auto_scaling_max_instance_size" {
  description = "Maximum instance size for Atlas compute autoscaling"
  type        = string
  default     = "M80"
}

variable "atlas_disk_size" {
  description = "Starting atlas disk size"
  type        = string
}

variable "atlas_instance_type" {
  description = "atlas instance type"
  type        = string
}

variable "private_endpoint_name" {
  description = "Name of the Azure private endpoint. If not specified, the `name` variable will be used."
  type        = string
  default     = null
}

variable "mongodb_admin_username" {
  description = "MongoDB admin username"
  type        = string
}

variable "mongodb_admin_arns" {
  description = "List of AWS IAM Principal ARNs to provide admin access to"
  type        = set(string)
  default     = []
}

variable "enable_slack_alerts" {
  description = "Enable alert notifications to a Slack channel. When `true`, `slack_api_token` and `slack_notification_channel` must be set."
  type        = string
  default     = false
}

variable "slack_api_token" {
  description = "Slack API token to use for alert notifications. Required when `enable_slack_alerts` is `true`."
  type        = string
  default     = null
}

variable "slack_notification_channel" {
  description = "Slack channel to send alert notifications to. Required when `enable_slack_alerts` is `true`."
  type        = string
  default     = null
}

variable "password_constraints" {
  description = "Constraints to put on any generated passwords"
  type = object({
    length           = number
    min_lower        = optional(number)
    min_numeric      = optional(number)
    min_upper        = optional(number)
    min_special      = optional(number, 0)
    special          = optional(bool)
    override_special = optional(string)
  })
  default = {
    length           = 32
    min_lower        = 1
    min_numeric      = 1
    min_upper        = 1
    override_special = "-"
  }
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
}

variable "backup_schedule" {
  description = "Configuration for the MongoDB Atlas cloud backup schedule policy items and cross-region copy settings"
  type = object({
    policy_item_hourly = optional(object({
      frequency_interval = optional(number, 6) # accepted values = 1, 2, 4, 6, 8, 12 -> every n hours
      retention_unit     = optional(string, "days")
      retention_value    = optional(number, 7)
    }), {})
    policy_item_daily = optional(object({
      frequency_interval = optional(number, 1) # accepted values = 1 -> every 1 day
      retention_unit     = optional(string, "days")
      retention_value    = optional(number, 30)
    }), {})
    policy_item_weekly = optional(object({
      frequency_interval = optional(number, 6) # accepted values = 1 to 7 -> every 1=Monday,2=Tuesday,3=Wednesday,4=Thursday,5=Friday,6=Saturday,7=Sunday day of the week
      retention_unit     = optional(string, "days")
      retention_value    = optional(number, 30)
    }), {})
    policy_item_monthly = optional(object({
      frequency_interval = optional(number, 1) # accepted values = 1 to 28 -> every nth day of the month, 40 -> every last day of the month
      retention_unit     = optional(string, "months")
      retention_value    = optional(number, 1)
    }), {})
    copy_settings = optional(object({
      enabled            = optional(bool, true)
      cloud_provider     = optional(string, "AZURE")
      frequencies        = optional(list(string), ["DAILY"])
      should_copy_oplogs = optional(bool, false)
    }), {})
  })
  default = {}
}
