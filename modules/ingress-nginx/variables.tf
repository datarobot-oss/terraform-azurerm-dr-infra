variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = null
}

variable "aks_managed_resource_group_name" {
  description = "Name of the Resource Group which contains the Kubernetes ingress LB"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = null
}

variable "internet_facing_ingress_lb" {
  description = "Connect to the DataRobot application via an complete load balancer"
  type        = bool
  default     = true
}

variable "create_ingress_pl_service" {
  description = "Expose the internal LB created by the ingress-nginx controller as an Azure Private Link Service. Only applies if internet_facing_ingress_lb is false."
  type        = bool
  default     = false
}

variable "ingress_pl_subnet_id" {
  description = "The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint"
  type        = string
  default     = null
}

variable "ingress_pl_visibility_subscription_ids" {
  description = "A list of Subscription UUID/GUID's that will be able to see the ingress Private Link Service. Only applies if internet_facing_ingress_lb is false."
  type        = list(string)
  default     = null
}

variable "ingress_pl_auto_approval_subscription_ids" {
  description = "A list of Subscription UUID/GUID's that will be automatically be able to use this Private Link Service. Only applies if internet_facing_ingress_lb is false."
  type        = list(string)
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

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
  default     = null
}
