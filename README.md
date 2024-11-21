# terraform-azurerm-dr-infra
Terraform module to create Azure Cloud infrastructure resources required to run DataRobot.

## Usage
```
module "datarobot_infra" {
  source = "datarobot-oss/dr-infra/azurerm"

  name        = "datarobot"
  domain_name = "yourdomain.com"
  location    = "eastus"

  create_resource_group          = true
  create_network                 = true
  network_address_space          = "10.7.0.0/16"
  existing_public_dns_zone_id    = "/subscriptions/subscription-id/resourceGroups/existing-resource-group-name/providers/Microsoft.Network/dnszones/yourdomain.com"
  create_storage                 = true
  existing_container_registry_id = "/subscriptions/subscription-id/resourceGroups/existing-resource-group-name/providers/Microsoft.ContainerRegistry/registries/existing-acr-name"
  create_kubernetes_cluster      = true
  create_app_identity            = true

  ingress_nginx                          = true
  internet_facing_ingress_lb             = true
  cert_manager                           = true
  cert_manager_letsencrypt_email_address = youremail@yourdomain.com
  external_dns                           = true
  nvidia_device_plugin                   = true
  descheduler                            = true

  tags = {
    application = "datarobot"
    environment = "dev"
    managed-by  = "terraform"
  }
}
```

## Examples
- [Complete](examples/complete) - Demonstrates all input variables
- [Partial](examples/partial) - Demonstrates the use of existing resources
- [Minimal](examples/minimal) - Demonstrates the minimum set of input variables needed to deploy all infrastructure

### Using an example directly from source
1. Clone the repo
```bash
git clone https://github.com/datarobot-oss/terraform-azurerm-dr-infra.git
```
2. Change directories into the example that best suits your needs
```bash
cd terraform-azurerm-dr-infra/examples/minimal
```
3. Modify `main.tf` as needed
4. Run terraform commands
```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

## Module Descriptions

### Resource Group
#### Toggle
- `create_resource_group` to create a new Azure Resource Group
- `existing_resource_group_name` to use an existing resource group

#### Description
Create a new Azure Resource Group to put all created resources in.

#### Permissions
`Contributor`


### Network
#### Toggle
- `create_network` to create a new Azure Virtual Network
- `existing_vnet_id` to use an existing VNet

#### Description
Create a new Azure Virtual Network (VNet) with one subnet and a NAT gateway with a Public IP attached.

#### Permissions
`Network Contributor`


### DNS
#### Toggle
- `create_dns_zones` to create new Azure DNS zones
- `existing_public_dns_zone_id` / `existing_private_dns_zone_id` to use an existing Azure DNS zone

#### Description
Create new public and/or private DNS zones with name `domain_name`.

A public Route53 zone is used by `external_dns` to create records for the DataRobot ingress resources when `internet_facing_ingress_lb` is `true`. It is also used for DNS validation when using `cert_manager` and `cert_manager_letsencrypt_clusterissuers`.

A private Route53 zone is used by `external_dns` to create records for the DataRobot ingress resources when `internet_facing_ingress_lb` is `false`.

#### Permissions
- `DNS Zone Contributor`
- `Private DNS Zone Contributor`


### Storage
#### Toggle
- `create_storage` to create a new Azure Storage Account and Container
- `existing_storage_account_id` to use an existing Azure Storage Account

#### Description
Create a new Azure Storage Account and Container with public internet access allowed by default and PrivateLink access from within the VNet. Network access to the ACR can be managed via the `storage_public_network_access_enabled`, `storage_network_rules_default_action`, `storage_public_ip_allow_list`, and `storage_virtual_network_subnet_ids` variables.

The DataRobot application will use this storage account for persistent file storage.

#### Permissions
`Storage Account Contributor`


### Container Registry
#### Toggle
- `create_container_registry` to create a new Azure Container Registry
- `existing_container_registry_id` to use an existing Azure Container Registry

#### Description
Create a new Azure Container Registry with public internet access allowed by default and PrivateLink access from within the VNet. Network access to the ACR can be managed via the `container_registry_public_network_access_enabled`, `container_registry_network_rules_default_action`, and `container_registry_ip_allow_list` variables.

The DataRobot application will use this registry to host custom images created by various services.

#### Permissions
TBD


### Kubernetes
#### Toggle
- `create_kubernetes_cluster` to create a new Azure Kubernetes Service Cluster
- `existing_eks_cluster_name` to use an existing AKS cluster

#### Description
Create a new AKS cluster to host the DataRobot application and any other helm charts installed by this module.

The AKS cluster Kubernetes API endpoint can either be made available over the public internet or privately to the VNet. When `kubernetes_cluster_endpoint_public_access` is `false`, the cluster API endpoint is only available from within the VNet via a PrivateLink. When `kubernetes_cluster_endpoint_public_access` is `true`, the cluster API endpoint is accessed via the public internet. This access can be restricted to specific IP addresses via the `kubernetes_cluster_endpoint_public_access_cidrs` variable.

Two node groups are created:
- A `primary` node group intended to host the majority of the DataRobot pods
- A `gpu` node group intended to host GPU workload pods

By default, Azure uses `10.0.0.0/16` for Kubernetes services and `10.244.0.0/16` for Kubernetes pods. Ensure these do not conflict with your VNet address space by either specifying a different `network_address_space` for the VNet created by this module, or by specifying alternate `kubernetes_pod_cidr` and/or `kubernetes_service_cidr` as needed.

#### Permissions
TBD


### Helm Chart - ingress-nginx
#### Toggle
- `ingress_nginx` to install the `ingress-nginx` helm chart

#### Description
Uses the [terraform-helm-release](https://github.com/terraform-module/terraform-helm-release) module to install the `ingress-nginx` helm chart from the `https://kubernetes.github.io/ingress-nginx` repo into the `ingress-nginx` namespace.

The `ingress-nginx` helm chart will trigger the deployment of an Azure Standard Load Balancer directing traffic to the `ingress-nginx-controller` Kubernetes services.

Values passed to the helm chart can be overridden by passing a custom values file via the `ingress_nginx_values` variable as demonstrated in the [complete example](examples/complete/main.tf).


#### Permissions
Not required


### Helm Chart - cert-manager
#### Toggle
- `cert_manager` to install the `cert-manager` helm chart

#### Description
Uses the [terraform-helm-release](https://github.com/terraform-module/terraform-helm-release) module to install the `cert-manager` helm chart from the `https://charts.jetstack.io` repo into the `cert-manager` namespace.

A User Assigned Identity and Federated Identity Credential is created for the `cert-manager` service account running in the `cert-manager` namespace that allows the creation of DNS resources within the specified DNS zone.

`cert-manager` can be used by the DataRobot application to create and manage various certificates including the application.

When `cert_manager_letsencrypt_clusterissuers` is enabled, `letsencrypt-staging` and `letsencrypt-prod` ClusterIssuers will be created which can be used by the `datarobot-azure` umbrella chart to issue certificates used by the DataRobot application. The default values in that helm chart (as of version 10.2) have `global.ingress.tls.enabled`, `global.ingress.tls.certmanager`, and `global.ingress.tls.issuer` as `letsencrypt-prod` which will use the `letsencrypt-prod` ClusterIssuer to issue a public ACME certificate as the TLS certificate used by the Kubernetes ingress resources.

Values passed to the helm chart can be overridden by passing a custom values file via the `cert_manager_values` variable as demonstrated in the [complete example](examples/complete/main.tf).

#### Permissions
TBD


### Helm Chart - external-dns
#### Toggle
- `external_dns` to install the `external-dns` helm chart

#### Description
Uses the [terraform-helm-release](https://github.com/terraform-module/terraform-helm-release) module to install the `external-dns` helm chart from the `https://charts.bitnami.com/bitnami` repo into the `external-dns` namespace.

A User Assigned Identity and Federated Identity Credential is created for the `external-dns` service account running in the `external-dns` namespace that allows the creation of DNS resources within the specified DNS zone.

`external-dns` is used to automatically create DNS records for ingress resources in the Kubernetes cluster. When the DataRobot application is installed and the ingress resources are created, `external-dns` will automatically create a DNS record pointing at the ingress resource.

Values passed to the helm chart can be overridden by passing a custom values file via the `external_dns_values` variable as demonstrated in the [complete example](examples/complete/main.tf).

#### Permissions
TBD


### Helm Chart - nvidia-device-plugin
#### Toggle
- `nvidia_device_plugin` to install the `nvidia-device-plugin` helm chart

#### Description
Uses the [terraform-helm-release](https://github.com/terraform-module/terraform-helm-release) module to install the `nvidia-device-plugin` helm chart from the `https://nvidia.github.io/k8s-device-plugin` repo into the `nvidia-device-plugin` namespace.

This helm chart is used to expose GPU resources on nodes intended for GPU workloads such as the default `gpu` node group.

Values passed to the helm chart can be overridden by passing a custom values file via the `nvidia_device_plugin_values` variable as demonstrated in the [complete example](examples/complete/main.tf).

#### Permissions
Not required


### Helm Chart - descheduler
#### Toggle
- `descheduler` to install the `descheduler` helm chart

#### Description
Uses the [terraform-helm-release](https://github.com/terraform-module/terraform-helm-release) module to install the `descheduler` helm chart from the `https://kubernetes-sigs.github.io/descheduler/` helm repo into the `descheduler` namespace.

This helm chart allows for automatic rescheduling of pods for optimizing resource consumption.

#### Permissions
Not required


### Comprehensive Required Permissions
TBD


## DataRobot versions
| Release | Supported DR Versions |
|---------|-----------------------|
| >= 1.0 | >= 10.0 |



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.15.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_identity"></a> [app\_identity](#module\_app\_identity) | ./modules/app-identity | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./modules/cert-manager | n/a |
| <a name="module_container_registry"></a> [container\_registry](#module\_container\_registry) | ./modules/container-registry | n/a |
| <a name="module_descheduler"></a> [descheduler](#module\_descheduler) | ./modules/descheduler | n/a |
| <a name="module_dns"></a> [dns](#module\_dns) | ./modules/dns | n/a |
| <a name="module_external_dns"></a> [external\_dns](#module\_external\_dns) | ./modules/external-dns | n/a |
| <a name="module_ingress_nginx"></a> [ingress\_nginx](#module\_ingress\_nginx) | ./modules/ingress-nginx | n/a |
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | ./modules/kubernetes | n/a |
| <a name="module_naming"></a> [naming](#module\_naming) | Azure/naming/azurerm | ~> 0.4 |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_nvidia_device_plugin"></a> [nvidia\_device\_plugin](#module\_nvidia\_device\_plugin) | ./modules/nvidia-device-plugin | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_kubernetes_cluster.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager"></a> [cert\_manager](#input\_cert\_manager) | Install the cert-manager helm chart. All other cert\_manager variables are ignored if this variable is false. | `bool` | `true` | no |
| <a name="input_cert_manager_letsencrypt_clusterissuers"></a> [cert\_manager\_letsencrypt\_clusterissuers](#input\_cert\_manager\_letsencrypt\_clusterissuers) | Whether to create letsencrypt-prod and letsencrypt-staging ClusterIssuers | `bool` | `true` | no |
| <a name="input_cert_manager_letsencrypt_email_address"></a> [cert\_manager\_letsencrypt\_email\_address](#input\_cert\_manager\_letsencrypt\_email\_address) | Email address for the certificate owner. Let's Encrypt will use this to contact you about expiring certificates, and issues related to your account. Only required if cert\_manager\_letsencrypt\_clusterissuers is true. | `string` | `"user@example.com"` | no |
| <a name="input_cert_manager_values"></a> [cert\_manager\_values](#input\_cert\_manager\_values) | Path to templatefile containing custom values for the cert-manager helm chart | `string` | `""` | no |
| <a name="input_cert_manager_variables"></a> [cert\_manager\_variables](#input\_cert\_manager\_variables) | Variables passed to the cert\_manager\_values templatefile | `any` | `{}` | no |
| <a name="input_container_registry_ip_allow_list"></a> [container\_registry\_ip\_allow\_list](#input\_container\_registry\_ip\_allow\_list) | List of CIDR blocks to allow access to the container registry. Only IPv4 addresses are allowed | `list(string)` | `[]` | no |
| <a name="input_container_registry_network_rules_default_action"></a> [container\_registry\_network\_rules\_default\_action](#input\_container\_registry\_network\_rules\_default\_action) | Specifies the default action of allow or deny when no other rules match | `string` | `"Allow"` | no |
| <a name="input_container_registry_public_network_access_enabled"></a> [container\_registry\_public\_network\_access\_enabled](#input\_container\_registry\_public\_network\_access\_enabled) | Whether the public network access to the container registry is enabled | `bool` | `true` | no |
| <a name="input_create_app_identity"></a> [create\_app\_identity](#input\_create\_app\_identity) | Create a new user assigned identity for the DataRobot application | `bool` | `true` | no |
| <a name="input_create_container_registry"></a> [create\_container\_registry](#input\_create\_container\_registry) | Create a new Azure Container Registry. Ignored if an existing existing\_container\_registry\_id is specified. | `bool` | `true` | no |
| <a name="input_create_dns_zones"></a> [create\_dns\_zones](#input\_create\_dns\_zones) | Create DNS zones for domain\_name. Ignored if existing\_public\_dns\_zone\_id and existing\_private\_dns\_zone\_id are specified. | `bool` | `true` | no |
| <a name="input_create_kubernetes_cluster"></a> [create\_kubernetes\_cluster](#input\_create\_kubernetes\_cluster) | Create a new Azure Kubernetes Service cluster. All kubernetes and helm chart variables are ignored if this variable is false. | `bool` | `true` | no |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | Create a new Azure Virtual Network. Ignored if an existing existing\_vnet\_id is specified. | `bool` | `true` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Create a new Azure resource group. Ignored if existing existing\_resource\_group\_name is specified. | `bool` | `true` | no |
| <a name="input_create_storage"></a> [create\_storage](#input\_create\_storage) | Create a new Azure Storage account and container. Ignored if an existing\_storage\_account\_id is specified. | `bool` | `true` | no |
| <a name="input_datarobot_namespace"></a> [datarobot\_namespace](#input\_datarobot\_namespace) | Kubernetes namespace in which the DataRobot application will be installed | `string` | `"dr-app"` | no |
| <a name="input_datarobot_service_accounts"></a> [datarobot\_service\_accounts](#input\_datarobot\_service\_accounts) | Names of the Kubernetes service accounts used by the DataRobot application | `set(string)` | <pre>[<br>  "dr",<br>  "build-service",<br>  "build-service-image-builder",<br>  "buzok-account",<br>  "dr-lrs-operator",<br>  "dynamic-worker",<br>  "internal-api-sa",<br>  "nbx-notebook-revisions-account",<br>  "prediction-server-sa",<br>  "tileservergl-sa"<br>]</pre> | no |
| <a name="input_descheduler"></a> [descheduler](#input\_descheduler) | Install the descheduler helm chart to enable rescheduling of pods. All other descheduler variables are ignored if this variable is false | `bool` | `true` | no |
| <a name="input_descheduler_values"></a> [descheduler\_values](#input\_descheduler\_values) | Path to templatefile containing custom values for the descheduler helm chart | `string` | `""` | no |
| <a name="input_descheduler_variables"></a> [descheduler\_variables](#input\_descheduler\_variables) | Variables passed to the descheduler templatefile | `any` | `{}` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the domain to use for the DataRobot application. If create\_dns\_zones is true then zones will be created for this domain. It is also used by the cert-manager helm chart for DNS validation and as a domain filter by the external-dns helm chart. | `string` | `""` | no |
| <a name="input_existing_aks_cluster_name"></a> [existing\_aks\_cluster\_name](#input\_existing\_aks\_cluster\_name) | Name of existing AKS cluster to use. When specified, all other kubernetes variables will be ignored. | `string` | `null` | no |
| <a name="input_existing_container_registry_id"></a> [existing\_container\_registry\_id](#input\_existing\_container\_registry\_id) | ID of existing container registry to use | `string` | `""` | no |
| <a name="input_existing_kubernetes_nodes_subnet_id"></a> [existing\_kubernetes\_nodes\_subnet\_id](#input\_existing\_kubernetes\_nodes\_subnet\_id) | ID of an existing subnet to use for the AKS node pools. Required when an existing\_network\_id is specified. Ignored if create\_network is true and no existing\_network\_id is specified. | `string` | `""` | no |
| <a name="input_existing_private_dns_zone_id"></a> [existing\_private\_dns\_zone\_id](#input\_existing\_private\_dns\_zone\_id) | ID of existing private hosted zone to use for private DNS records created by external-dns. This is required when create\_dns\_zones is false and ingress\_nginx is true with internet\_facing\_ingress\_lb false. | `string` | `""` | no |
| <a name="input_existing_public_dns_zone_id"></a> [existing\_public\_dns\_zone\_id](#input\_existing\_public\_dns\_zone\_id) | ID of existing public hosted zone to use for public DNS records created by external-dns and public LetsEncrypt certificate validation by cert-manager. This is required when create\_dns\_zones is false and ingress\_nginx and internet\_facing\_ingress\_lb are true or when cert\_manager and cert\_manager\_letsencrypt\_clusterissuers are true. | `string` | `""` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Name of existing resource group to use | `string` | `""` | no |
| <a name="input_existing_storage_account_id"></a> [existing\_storage\_account\_id](#input\_existing\_storage\_account\_id) | ID of existing Azure Storage Account to use for DataRobot file storage. When specified, all other storage variables will be ignored. | `string` | `""` | no |
| <a name="input_existing_vnet_id"></a> [existing\_vnet\_id](#input\_existing\_vnet\_id) | ID of an existing VNet to use. When specified, other network variables are ignored. | `string` | `""` | no |
| <a name="input_external_dns"></a> [external\_dns](#input\_external\_dns) | Install the external\_dns helm chart to create DNS records for ingress resources matching the domain\_name variable. All other external\_dns variables are ignored if this variable is false. | `bool` | `true` | no |
| <a name="input_external_dns_values"></a> [external\_dns\_values](#input\_external\_dns\_values) | Path to templatefile containing custom values for the external-dns helm chart | `string` | `""` | no |
| <a name="input_external_dns_variables"></a> [external\_dns\_variables](#input\_external\_dns\_variables) | Variables passed to the external\_dns\_values templatefile | `any` | `{}` | no |
| <a name="input_ingress_nginx"></a> [ingress\_nginx](#input\_ingress\_nginx) | Install the ingress-nginx helm chart to use as the ingress controller for the AKS cluster. All other ingress\_nginx variables are ignored if this variable is false. | `bool` | `true` | no |
| <a name="input_ingress_nginx_values"></a> [ingress\_nginx\_values](#input\_ingress\_nginx\_values) | Path to templatefile containing custom values for the ingress-nginx helm chart | `string` | `""` | no |
| <a name="input_ingress_nginx_variables"></a> [ingress\_nginx\_variables](#input\_ingress\_nginx\_variables) | Variables passed to the ingress\_nginx\_values templatefile | `any` | `{}` | no |
| <a name="input_internet_facing_ingress_lb"></a> [internet\_facing\_ingress\_lb](#input\_internet\_facing\_ingress\_lb) | Determines the type of Standard Load Balancer created for AKS ingress. If true, a public Standard Load Balancer will be created. If false, an internal Standard Load Balancer will be created. | `bool` | `true` | no |
| <a name="input_kubernetes_cluster_endpoint_public_access"></a> [kubernetes\_cluster\_endpoint\_public\_access](#input\_kubernetes\_cluster\_endpoint\_public\_access) | Whether or not the Kubernetes API endpoint should be exposed to the public internet. When false, the cluster endpoint is only available internally to the virtual network. | `bool` | `true` | no |
| <a name="input_kubernetes_cluster_endpoint_public_access_cidrs"></a> [kubernetes\_cluster\_endpoint\_public\_access\_cidrs](#input\_kubernetes\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Kubernetes API server endpoint | `list(string)` | `[]` | no |
| <a name="input_kubernetes_cluster_version"></a> [kubernetes\_cluster\_version](#input\_kubernetes\_cluster\_version) | AKS cluster version | `string` | `null` | no |
| <a name="input_kubernetes_dns_service_ip"></a> [kubernetes\_dns\_service\_ip](#input\_kubernetes\_dns\_service\_ip) | IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns) | `string` | `null` | no |
| <a name="input_kubernetes_gpu_nodepool_labels"></a> [kubernetes\_gpu\_nodepool\_labels](#input\_kubernetes\_gpu\_nodepool\_labels) | A map of Kubernetes labels to apply to the GPU node pool | `map(string)` | <pre>{<br>  "datarobot.com/node-capability": "gpu"<br>}</pre> | no |
| <a name="input_kubernetes_gpu_nodepool_max_count"></a> [kubernetes\_gpu\_nodepool\_max\_count](#input\_kubernetes\_gpu\_nodepool\_max\_count) | Maximum number of nodes in the GPU node pool | `number` | `10` | no |
| <a name="input_kubernetes_gpu_nodepool_min_count"></a> [kubernetes\_gpu\_nodepool\_min\_count](#input\_kubernetes\_gpu\_nodepool\_min\_count) | Minimum number of nodes in the GPU node pool | `number` | `0` | no |
| <a name="input_kubernetes_gpu_nodepool_name"></a> [kubernetes\_gpu\_nodepool\_name](#input\_kubernetes\_gpu\_nodepool\_name) | Name of the GPU node pool | `string` | `"gpu"` | no |
| <a name="input_kubernetes_gpu_nodepool_node_count"></a> [kubernetes\_gpu\_nodepool\_node\_count](#input\_kubernetes\_gpu\_nodepool\_node\_count) | Node count of the GPU node pool | `number` | `0` | no |
| <a name="input_kubernetes_gpu_nodepool_taints"></a> [kubernetes\_gpu\_nodepool\_taints](#input\_kubernetes\_gpu\_nodepool\_taints) | A list of Kubernetes taints to apply to the GPU node pool | `list(string)` | <pre>[<br>  "nvidia.com/gpu=true:NoSchedule"<br>]</pre> | no |
| <a name="input_kubernetes_gpu_nodepool_vm_size"></a> [kubernetes\_gpu\_nodepool\_vm\_size](#input\_kubernetes\_gpu\_nodepool\_vm\_size) | VM size used for the GPU node pool | `string` | `"Standard_NC4as_T4_v3"` | no |
| <a name="input_kubernetes_nodepool_availability_zones"></a> [kubernetes\_nodepool\_availability\_zones](#input\_kubernetes\_nodepool\_availability\_zones) | Availability zones to use for the AKS node pools | `set(string)` | <pre>[<br>  "1",<br>  "2",<br>  "3"<br>]</pre> | no |
| <a name="input_kubernetes_pod_cidr"></a> [kubernetes\_pod\_cidr](#input\_kubernetes\_pod\_cidr) | The CIDR to use for Kubernetes pod IP addresses | `string` | `null` | no |
| <a name="input_kubernetes_primary_nodepool_labels"></a> [kubernetes\_primary\_nodepool\_labels](#input\_kubernetes\_primary\_nodepool\_labels) | A map of Kubernetes labels to apply to the primary node pool | `map(string)` | <pre>{<br>  "datarobot.com/node-capability": "cpu"<br>}</pre> | no |
| <a name="input_kubernetes_primary_nodepool_max_count"></a> [kubernetes\_primary\_nodepool\_max\_count](#input\_kubernetes\_primary\_nodepool\_max\_count) | Maximum number of nodes in the primary node pool | `number` | `10` | no |
| <a name="input_kubernetes_primary_nodepool_min_count"></a> [kubernetes\_primary\_nodepool\_min\_count](#input\_kubernetes\_primary\_nodepool\_min\_count) | Minimum number of nodes in the primary node pool | `number` | `1` | no |
| <a name="input_kubernetes_primary_nodepool_name"></a> [kubernetes\_primary\_nodepool\_name](#input\_kubernetes\_primary\_nodepool\_name) | Name of the primary node pool | `string` | `"primary"` | no |
| <a name="input_kubernetes_primary_nodepool_node_count"></a> [kubernetes\_primary\_nodepool\_node\_count](#input\_kubernetes\_primary\_nodepool\_node\_count) | Node count of the primary node pool | `number` | `1` | no |
| <a name="input_kubernetes_primary_nodepool_taints"></a> [kubernetes\_primary\_nodepool\_taints](#input\_kubernetes\_primary\_nodepool\_taints) | A list of Kubernetes taints to apply to the primary node pool | `list(string)` | `[]` | no |
| <a name="input_kubernetes_primary_nodepool_vm_size"></a> [kubernetes\_primary\_nodepool\_vm\_size](#input\_kubernetes\_primary\_nodepool\_vm\_size) | VM size used for the primary node pool | `string` | `"Standard_D32s_v4"` | no |
| <a name="input_kubernetes_service_cidr"></a> [kubernetes\_service\_cidr](#input\_kubernetes\_service\_cidr) | The CIDR to use for Kubernetes service IP addresses | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location to create resources in | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to use as a prefix for created resources | `string` | n/a | yes |
| <a name="input_network_address_space"></a> [network\_address\_space](#input\_network\_address\_space) | CIDR block to be used for the new VNet. By default, AKS uses 10.0.0.0/16 for services and 10.244.0.0/16 for pods. This should not overlap with the kubernetes\_service\_cidr or kubernetes\_pod\_cidr variables. | `string` | `"10.1.0.0/16"` | no |
| <a name="input_nvidia_device_plugin"></a> [nvidia\_device\_plugin](#input\_nvidia\_device\_plugin) | Install the nvidia-device-plugin helm chart to expose node GPU resources to the AKS cluster. All other nvidia\_device\_plugin variables are ignored if this variable is false. | `bool` | `true` | no |
| <a name="input_nvidia_device_plugin_values"></a> [nvidia\_device\_plugin\_values](#input\_nvidia\_device\_plugin\_values) | Path to templatefile containing custom values for the nvidia-device-plugin helm chart | `string` | `""` | no |
| <a name="input_nvidia_device_plugin_variables"></a> [nvidia\_device\_plugin\_variables](#input\_nvidia\_device\_plugin\_variables) | Variables passed to the nvidia\_device\_plugin\_values templatefile | `any` | `{}` | no |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | Storage account data replication type as described in https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy | `string` | `"ZRS"` | no |
| <a name="input_storage_network_rules_default_action"></a> [storage\_network\_rules\_default\_action](#input\_storage\_network\_rules\_default\_action) | Specifies the default action of the storage firewall to allow or deny when no other rules match | `string` | `"Allow"` | no |
| <a name="input_storage_public_ip_allow_list"></a> [storage\_public\_ip\_allow\_list](#input\_storage\_public\_ip\_allow\_list) | List of public IP or IP ranges in CIDR Format which are allowed to access the storage account. Only IPv4 addresses are allowed. /31 CIDRs, /32 CIDRs, and Private IP address ranges (as defined in RFC 1918), are not allowed. Ignored if storage\_public\_network\_access\_enabled is false. | `list(string)` | `[]` | no |
| <a name="input_storage_public_network_access_enabled"></a> [storage\_public\_network\_access\_enabled](#input\_storage\_public\_network\_access\_enabled) | Whether the public network access to the storage account is enabled | `bool` | `true` | no |
| <a name="input_storage_virtual_network_subnet_ids"></a> [storage\_virtual\_network\_subnet\_ids](#input\_storage\_virtual\_network\_subnet\_ids) | List of resource IDs for subnets which are allowed to access the storage account | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all created resources | `map(string)` | <pre>{<br>  "managed-by": "terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_cluster_id"></a> [aks\_cluster\_id](#output\_aks\_cluster\_id) | ID of the Azure Kubernetes Service cluster |
| <a name="output_container_registry_admin_password"></a> [container\_registry\_admin\_password](#output\_container\_registry\_admin\_password) | Admin password of the container registry |
| <a name="output_container_registry_admin_username"></a> [container\_registry\_admin\_username](#output\_container\_registry\_admin\_username) | Admin username of the container registry |
| <a name="output_container_registry_id"></a> [container\_registry\_id](#output\_container\_registry\_id) | ID of the container registry |
| <a name="output_container_registry_login_server"></a> [container\_registry\_login\_server](#output\_container\_registry\_login\_server) | The URL that can be used to log into the container registry |
| <a name="output_private_zone_id"></a> [private\_zone\_id](#output\_private\_zone\_id) | ID of the private zone |
| <a name="output_public_zone_id"></a> [public\_zone\_id](#output\_public\_zone\_id) | ID of the public zone |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the Resource Group |
| <a name="output_storage_access_key"></a> [storage\_access\_key](#output\_storage\_access\_key) | The primary access key for the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the storage account |
| <a name="output_storage_container_name"></a> [storage\_container\_name](#output\_storage\_container\_name) | Name of the storage container |
| <a name="output_user_assigned_identity_client_id"></a> [user\_assigned\_identity\_client\_id](#output\_user\_assigned\_identity\_client\_id) | Client ID of the user assigned identity |
| <a name="output_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#output\_user\_assigned\_identity\_id) | ID of the user assigned identity |
| <a name="output_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#output\_user\_assigned\_identity\_name) | Name of the user assigned identity |
| <a name="output_user_assigned_identity_principal_id"></a> [user\_assigned\_identity\_principal\_id](#output\_user\_assigned\_identity\_principal\_id) | Principal ID of the user assigned identity |
| <a name="output_user_assigned_identity_tenant_id"></a> [user\_assigned\_identity\_tenant\_id](#output\_user\_assigned\_identity\_tenant\_id) | Tenant ID of the user assigned identity |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The ID of the VNet |
<!-- END_TF_DOCS -->
