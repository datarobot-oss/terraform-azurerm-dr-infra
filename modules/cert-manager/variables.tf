variable "resource_group_name" {
  description = "Name of the Resource Group"
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

variable "aks_oidc_issuer_url" {
  description = "OIDC issuer URL of the AKS cluster"
  type        = string
}

variable "hosted_zone_id" {
  description = "ID of the DNS hosted zone used for certificate validation"
  type        = string
}

variable "letsencrypt_clusterissuers" {
  description = "Whether to create letsencrypt-prod and letsencrypt-staging ClusterIssuers"
  type        = bool
}

variable "hosted_zone_name" {
  description = "Name of the DNS hosted zone used for certificate validation. Only required if letsencrypt_clusterissuers is true."
  type        = string
}

variable "email_address" {
  description = "Email address for the certificate owner. Let's Encrypt will use this to contact you about expiring certificates, and issues related to your account. Only required if letsencrypt_clusterissuers is true."
  type        = string
}

variable "subscription_id" {
  description = "ID of the Azure subscription. Only required if letsencrypt_clusterissuers is true."
  type        = string
}

variable "values_overrides" {
  description = "Values in raw yaml format to pass to helm."
  type        = string
  default     = null
}
