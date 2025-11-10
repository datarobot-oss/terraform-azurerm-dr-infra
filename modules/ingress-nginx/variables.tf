variable "internet_facing_ingress_lb" {
  description = "Connect to the DataRobot application via an complete load balancer"
  type        = bool
  default     = true
}

variable "aks_managed_resource_group_name" {
  description = "Name of the Resource Group which contains the Kubernetes ingress LB"
  type        = string
  default     = null
}

variable "custom_values_templatefile" {
  description = "Custom values templatefile to pass to the helm chart"
  type        = string
  default     = ""
}

variable "custom_values_variables" {
  description = "Variables for the custom values templatefile"
  type        = any
  default     = {}
}
