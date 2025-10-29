# Changelog

All notable changes are documented in this file.

## v1.3.5
### Updated
- Added `spark-compute-services-sa` to `datarobot_service_accounts` variable as default

## v1.3.4
### Updated
- Do not create `azurerm_role_assignment` for storage when `existing_storage_account_id` is defined

## v1.3.3
### Updated
- Add redis port to output
- Set postgress auth method to `SCRAM-SHA-256`

## v1.3.2
### Updated
- `external-dns` from bitnami to kubernetes-sigs `1.19.0`

## v1.3.1
### Fixed
- existing vnet address space

## v1.3.0
### Updated
- create `kubernetes_default_node_pool` and `kubernetes_node_pools` variables to make node pools more customizable

## v1.2.0
### Added
- `postgres`, `redis`, and `mongodb` modules
- Azure PrivateLink service pointing at internal kubernetes ingress

## v1.1.9
### Updated
- removed loop with dynamic storage account network rules
- null variables instead of empty strings

## v1.1.8
### Added
- `kubeworker-sa` to `datarobot_service_accounts` default values

## v1.1.7
### Updated
- `helm` provider 3.0

## v1.1.6
### Added
- `install_helm_charts` variable to be able to enable/disable installation of all helm charts

## v1.1.5
### Added
- private endpoint for Azure Data Lake Storage (dfs)

## v1.1.4
### Updated
- use helm_release instead of terraform-module/release/helm

## v1.1.3
### Updated
- README for DataRobot version description

## v1.1.2
### Updated
- update datarobot_service_accounts defaults for 11.0

## v1.1.1
### Updated
- ingress-nginx helm chart version to 4.11.5

## v1.1.0
### Added
- Allow specifying existing AKS cluster via the existing_aks_cluster_name variable
- descheduler amenity
- Improved autoscaler behavior with 1 node group per AZ
### Updated
- AKS cluster to use cilium data plane
- All amenities to latest versions
- Removed public_ip_allow_list variable in favor of most specific network controls for each resource that supports it (storage, kubernetes, container registry)
### Fixed
- Issue where letsencrypt issuers would need to be applied continuously even though they already existed

## v1.0.0
### Added
- Initial module release
