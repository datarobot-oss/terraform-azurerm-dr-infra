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

variable "values_overrides" {
  description = "Values in raw yaml format to pass to helm."
  type        = string
  default     = null
}
