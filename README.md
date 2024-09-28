# terraform-azurerm-dr-infra
Terraform module to create Azure Cloud infrastructure resources required to run DataRobot.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acr"></a> [acr](#module\_acr) | ./modules/acr | n/a |
| <a name="module_aks"></a> [aks](#module\_aks) | ./modules/aks | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./modules/cert-manager | n/a |
| <a name="module_dns"></a> [dns](#module\_dns) | ./modules/dns | n/a |
| <a name="module_external_dns"></a> [external\_dns](#module\_external\_dns) | ./modules/external-dns | n/a |
| <a name="module_ingress_nginx"></a> [ingress\_nginx](#module\_ingress\_nginx) | ./modules/ingress-nginx | n/a |
| <a name="module_naming"></a> [naming](#module\_naming) | Azure/naming/azurerm | ~> 0.4 |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |
| <a name="module_uai"></a> [uai](#module\_uai) | ./modules/uai | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ./modules/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Storage account data replication type as described in https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy | `string` | `"ZRS"` | no |
| <a name="input_aks_node_pool_subnet_id"></a> [aks\_node\_pool\_subnet\_id](#input\_aks\_node\_pool\_subnet\_id) | ID of the subnet to use for the node pools | `string` | `""` | no |
| <a name="input_aks_primary_node_pool_max_count"></a> [aks\_primary\_node\_pool\_max\_count](#input\_aks\_primary\_node\_pool\_max\_count) | Maximum number of nodes in the primary node pool | `number` | `10` | no |
| <a name="input_aks_primary_node_pool_min_count"></a> [aks\_primary\_node\_pool\_min\_count](#input\_aks\_primary\_node\_pool\_min\_count) | Minimum number of nodes in the primary node pool | `number` | `3` | no |
| <a name="input_aks_primary_node_pool_node_count"></a> [aks\_primary\_node\_pool\_node\_count](#input\_aks\_primary\_node\_pool\_node\_count) | Node count of the primary node pool | `number` | `6` | no |
| <a name="input_aks_primary_node_pool_vm_size"></a> [aks\_primary\_node\_pool\_vm\_size](#input\_aks\_primary\_node\_pool\_vm\_size) | VM size used for the primary node pool | `string` | `"Standard_D32s_v4"` | no |
| <a name="input_aks_subnet_id"></a> [aks\_subnet\_id](#input\_aks\_subnet\_id) | ID of the subnet to use for the AKS node pools | `string` | `""` | no |
| <a name="input_cert_manager"></a> [cert\_manager](#input\_cert\_manager) | Install the cert-manager helm chart | `bool` | `true` | no |
| <a name="input_cert_manager_email_address"></a> [cert\_manager\_email\_address](#input\_cert\_manager\_email\_address) | Email address for the certificate owner. Let's Encrypt will use this to contact you about expiring certificates, and issues related to your account. | `string` | `"user@example.com"` | no |
| <a name="input_cert_manager_values"></a> [cert\_manager\_values](#input\_cert\_manager\_values) | Path to templatefile containing custom values for the cert-manager helm chart. | `string` | `""` | no |
| <a name="input_cert_manager_variables"></a> [cert\_manager\_variables](#input\_cert\_manager\_variables) | Variables passed to the cert\_manager\_values templatefile | `map(string)` | `{}` | no |
| <a name="input_container_registry_id"></a> [container\_registry\_id](#input\_container\_registry\_id) | ID of existing container registry to use | `string` | `""` | no |
| <a name="input_create_aks_cluster"></a> [create\_aks\_cluster](#input\_create\_aks\_cluster) | Whether to create an AKS cluster | `bool` | `true` | no |
| <a name="input_create_container_registry"></a> [create\_container\_registry](#input\_create\_container\_registry) | Whether to create a container registry | `bool` | `true` | no |
| <a name="input_create_dns_zones"></a> [create\_dns\_zones](#input\_create\_dns\_zones) | Whether to create a public and private zone for domain\_name | `bool` | `true` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Whether to create an Azure resource group | `bool` | `true` | no |
| <a name="input_create_storage"></a> [create\_storage](#input\_create\_storage) | Whether to create a storage account and container | `bool` | `true` | no |
| <a name="input_create_user_assigned_identity"></a> [create\_user\_assigned\_identity](#input\_create\_user\_assigned\_identity) | Whether to create a user assigned identity | `bool` | `true` | no |
| <a name="input_create_vnet"></a> [create\_vnet](#input\_create\_vnet) | Whether to create an Azure virtual network | `bool` | `true` | no |
| <a name="input_datarobot_namespace"></a> [datarobot\_namespace](#input\_datarobot\_namespace) | Kubernetes namespace in which the DataRobot application will be installed | `string` | `"dr-app"` | no |
| <a name="input_datarobot_service_accounts"></a> [datarobot\_service\_accounts](#input\_datarobot\_service\_accounts) | Names of the Kubernetes service accounts used by the DataRobot application | `set(string)` | <pre>[<br>  "dr",<br>  "build-service",<br>  "build-service-image-builder",<br>  "dr-lrs-operator",<br>  "dynamic-worker"<br>]</pre> | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | n/a | `string` | `""` | no |
| <a name="input_external_dns"></a> [external\_dns](#input\_external\_dns) | Install the external\_dns helm chart | `bool` | `true` | no |
| <a name="input_external_dns_values"></a> [external\_dns\_values](#input\_external\_dns\_values) | Path to templatefile containing custom values for the external\_dns helm chart. | `string` | `""` | no |
| <a name="input_external_dns_variables"></a> [external\_dns\_variables](#input\_external\_dns\_variables) | Variables passed to the external\_dns\_values templatefile | `map(string)` | `{}` | no |
| <a name="input_ingress_nginx"></a> [ingress\_nginx](#input\_ingress\_nginx) | Install the ingress-nginx helm chart to use as the ingress controller for the AKS cluster. Ignored if create\_aks\_cluster is false. | `bool` | `true` | no |
| <a name="input_ingress_nginx_values"></a> [ingress\_nginx\_values](#input\_ingress\_nginx\_values) | Path to templatefile containing custom values for the ingress-nginx helm chart. | `string` | `""` | no |
| <a name="input_ingress_nginx_variables"></a> [ingress\_nginx\_variables](#input\_ingress\_nginx\_variables) | Variables passed to the ingress\_nginx\_values templatefile | `map(string)` | `{}` | no |
| <a name="input_internet_facing_ingress_lb"></a> [internet\_facing\_ingress\_lb](#input\_internet\_facing\_ingress\_lb) | Determines the type of NLB created for AKS ingress. If true, an internet-facing NLB will be created. If false, an internal NLB will be created. Ignored when ingress\_nginx is false. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location to create resources in | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to use as a prefix for created resources | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of existing resource group to use | `string` | `null` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | ID of existing storage account to use | `string` | `""` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of existing storage account to use | `string` | `""` | no |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | Name of existing storage container to use | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all created resources | `map(string)` | <pre>{<br>  "managed-by": "terraform"<br>}</pre> | no |
| <a name="input_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#input\_user\_assigned\_identity\_id) | ID of existing user assigned identity | `string` | `""` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | CIDR block to use for the Azure VNet | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | ID of existing Azure VNet to use | `string` | `""` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | ID of existing zone to use | `string` | `""` | no |

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
