provider "azurerm" {
  features {}
}

locals {
  name                  = "datarobot"
  provisioner_public_ip = "123.123.123.123/32"
}


module "datarobot_infra" {
  source = "../.."

  ################################################################################
  # General
  ################################################################################
  name        = local.name
  domain_name = "${local.name}.yourdomain.com"
  location    = "westus2"
  tags = {
    application = local.name
    environment = "dev"
    managed-by  = "terraform"
  }

  ################################################################################
  # Resource Group
  ################################################################################
  create_resource_group = true

  ################################################################################
  # Network
  ################################################################################
  create_network        = true
  network_address_space = "10.7.0.0/16"

  ################################################################################
  # DNS
  ################################################################################
  create_dns_zones = true

  ################################################################################
  # Storage
  ################################################################################
  create_storage                        = true
  storage_account_replication_type      = "ZRS"
  storage_public_network_access_enabled = true
  storage_network_rules_default_action  = "Deny"
  storage_public_ip_allow_list          = [local.provisioner_public_ip]
  storage_virtual_network_subnet_ids    = null

  ################################################################################
  # Container Registry
  ################################################################################
  create_container_registry                        = true
  container_registry_public_network_access_enabled = true
  container_registry_network_rules_default_action  = "Deny"
  container_registry_ip_allow_list                 = [local.provisioner_public_ip]

  ################################################################################
  # Kubernetes
  ################################################################################
  create_kubernetes_cluster                       = true
  kubernetes_cluster_version                      = "1.30"
  kubernetes_cluster_endpoint_public_access       = true
  kubernetes_cluster_endpoint_public_access_cidrs = [local.provisioner_public_ip]
  kubernetes_pod_cidr                             = "10.244.0.0/16"
  kubernetes_service_cidr                         = "10.0.0.0/16"
  kubernetes_dns_service_ip                       = "10.0.0.10"
  kubernetes_nodepool_availability_zones          = ["1", "2", "3"]
  kubernetes_primary_nodepool_name                = "primary"
  kubernetes_primary_nodepool_vm_size             = "Standard_D32s_v4"
  kubernetes_primary_nodepool_node_count          = 6
  kubernetes_primary_nodepool_min_count           = 3
  kubernetes_primary_nodepool_max_count           = 10
  kubernetes_primary_nodepool_labels              = {}
  kubernetes_primary_nodepool_taints              = []
  kubernetes_gpu_nodepool_name                    = "gpu"
  kubernetes_gpu_nodepool_vm_size                 = "Standard_NC4as_T4_v3"
  kubernetes_gpu_nodepool_node_count              = 0
  kubernetes_gpu_nodepool_min_count               = 0
  kubernetes_gpu_nodepool_max_count               = 10
  kubernetes_gpu_nodepool_labels = {
    "datarobot.com/node-capability" = "gpu"
  }
  kubernetes_gpu_nodepool_taints = [
    "nvidia.com/gpu:NoSchedule"
  ]

  ################################################################################
  # App Identity
  ################################################################################
  create_app_identity = true
  datarobot_namespace = "dr-app"
  datarobot_service_accounts = [
    "dr",
    "build-service",
    "build-service-image-builder",
    "buzok-account",
    "dr-lrs-operator",
    "dynamic-worker",
    "internal-api-sa",
    "nbx-notebook-revisions-account",
    "prediction-server-sa",
    "tileservergl-sa"
  ]

  ################################################################################
  # Helm Charts
  ################################################################################
  install_helm_charts = true

  ################################################################################
  # ingress-nginx
  ################################################################################
  ingress_nginx              = true
  internet_facing_ingress_lb = true

  # in this case our custom values file override is formatted as a templatefile
  # so we can pass variables like our provisioner_public_ip to it.
  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  ingress_nginx_values = "${path.module}/templates/custom_ingress_nginx_values.tftpl"
  ingress_nginx_variables = {
    lb_source_ranges = [local.provisioner_public_ip]
  }

  ################################################################################
  # cert-manager
  ################################################################################
  cert_manager                            = true
  cert_manager_letsencrypt_clusterissuers = true
  cert_manager_letsencrypt_email_address  = "youremail@yourdomain.com"
  cert_manager_values                     = "${path.module}/templates/custom_cert_manager_values.yaml"
  cert_manager_variables                  = {}

  ################################################################################
  # external-dns
  ################################################################################
  external_dns           = true
  external_dns_values    = "${path.module}/templates/custom_external_dns_values.yaml"
  external_dns_variables = {}

  ################################################################################
  # nvidia-device-plugin
  ################################################################################
  nvidia_device_plugin           = true
  nvidia_device_plugin_values    = "${path.module}/templates/custom_nvidia_device_plugin_values.yaml"
  nvidia_device_plugin_variables = {}

  ################################################################################
  # descheduler
  ################################################################################
  descheduler           = true
  descheduler_values    = "${path.module}/templates/custom_descheduler_values.yaml"
  descheduler_variables = {}
}
