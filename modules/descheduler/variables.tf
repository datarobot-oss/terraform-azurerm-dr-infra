variable "values_overrides" {
  description = "Values in raw yaml format to pass to helm."
  type        = string
  default     = null
}

variable "chart_version" {
  description = "Version of the descheduler helm chart to install."
  type        = string
  default     = "0.37.0"
}
