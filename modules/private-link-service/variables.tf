variable "resource_group_name" {
  description = "Name of the Resource Group"
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

variable "pl_subnet_id" {
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

variable "load_balancer_frontend_ip_configuration_ids" {
  description = "List of Azure Load Balancer frontend IP configuration resource IDs (strings) to expose via the Private Link Service."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all created resources"
  type        = map(string)
  default     = null
}
