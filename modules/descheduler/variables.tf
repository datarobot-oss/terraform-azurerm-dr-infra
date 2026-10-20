variable "values_overrides" {
  description = "Values in raw yaml format to pass to helm."
  type        = string
  default     = null
}

variable "chart_version" {
  description = "Version of the descheduler helm chart to install. Accepts an exact version or a semver range constraint (e.g. ^X.Y.Z)."
  type        = string
  default     = ">=0.33.0 <1.0.0"
}
