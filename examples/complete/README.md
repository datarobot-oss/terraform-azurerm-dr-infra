## Example: complete
This example is not intended to represent a production-ready or typical deployment. Its purpose is to demonstrate the full breadth of customization available in this module — every major input variable is set explicitly, and several optional features are enabled together that would not normally be combined (e.g., a Private Link service alongside an internet-facing load balancer, network access rules locking storage and the container registry to a single IP, custom helm value overrides for every chart, and all optional helm charts enabled at once).

Use this example as a reference for what is possible, not as a starting point for a real deployment.

Notable patterns shown in this example:

- **Restricted API endpoint access**: The AKS API endpoint is publicly accessible, but `kubernetes_cluster_endpoint_public_access_cidrs` restricts access to the provisioner host's IP (`local.provisioner_public_ip`).
- **Locked-down storage and registry**: `storage_network_rules_default_action` and `container_registry_network_rules_default_action` are set to `Deny`, with the provisioner IP added to the respective allow lists.
- **Private Link service**: `create_ingress_pl_service = true` exposes the ingress load balancer as an Azure Private Link service so consumers in other subscriptions can reach it without traversing the public internet.
- **Custom helm values**: Each helm chart accepts a `*_values_overrides` input. This example loads those overrides from files in `templates/`. The ingress-nginx override is a `templatefile()`, allowing Terraform variables (such as `lb_source_ranges`) to be interpolated into the YAML.
- **GPU node pool**: A dedicated GPU node pool is defined alongside the CPU pool, tainted so only GPU workloads schedule onto it.

## Usage
```
terraform init
terraform apply
```
