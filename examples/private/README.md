## Example: private
Demonstrates the minimal set of input variables required to create all infrastructure needed to install the DataRobot application in a private, internet-restricted configuration.

In this example:

- Rather than creating a VNet, the name of an existing VNet is passed via `existing_vnet_name`, along with the resource ID of the AKS node subnet (`existing_kubernetes_node_subnet`). The module deploys all resources into that VNet rather than creating a new one.
- The AKS API endpoint has public access disabled, creating a private cluster. `terraform apply` must be run from a host that can reach the private API endpoint (running within the VNet or reachable via VPN/peering).
- The ingress load balancer is internal (`internet_facing_ingress_lb = false`). Access is restricted to the CIDR specified in `ingress_allowed_cidr`.
- TLS is handled by cert-manager using Let's Encrypt. Provide a valid `email_address` for certificate expiry notifications.

## Required variables
| Variable | Description |
|---|---|
| `name` | Name prefix applied to all created resources |
| `environment` | One of `dev`, `staging`, or `prod` |
| `subscription_id` | Azure subscription ID to deploy into |
| `location` | Azure location to deploy into |
| `domain_name` | Domain name for the application (e.g. `datarobot.yourdomain.com`) |
| `email_address` | Email address for Let's Encrypt certificate notifications |
| `existing_vnet_name` | Name of an existing VNet to deploy resources into |
| `existing_kubernetes_node_subnet` | Resource ID of an existing subnet for the AKS node pools |
| `ingress_allowed_cidr` | CIDR block allowed to reach the internal ingress load balancer |

## Usage
1. Copy the example tfvars file and fill in your values:
```bash
cp terraform.tfvars.example terraform.tfvars
```
2. Edit `terraform.tfvars` with your subscription ID, location, domain name, existing VNet details, and other required values.
3. Run Terraform:
```bash
terraform init
terraform apply
```
