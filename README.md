# Azure Route Server + Cisco Catalyst 8000v (Terraform)

Terraform code that deploys an **Azure Route Server** and a **Cisco Catalyst 8000v** router (Azure Marketplace image) into one resource group. GitHub Actions runs it, logging in to Azure with **OIDC** (no stored client secrets).

## What gets deployed

| Resource | Where | Notes |
|---|---|---|
| Resource group | `module.rg` | Holds everything below |
| Public IP(s) | `module.pip` | One per entry in `pips`; Static / Standard SKU |
| Virtual network `df.tf-rs-vnet` (10.0.0.0/24) | `main.tf` | |
| Subnet `RouteServerSubnet` | `main.tf` | Name required by Azure, /27 or larger |
| Azure Route Server | `module.route_server` | Uses the `tf-rs-pip` public IP |
| BGP peerings | `module.route_server` and `main.tf` | One per entry in `bgp_peers` (see [Known issues](#known-issues)) |
| Network interfaces | `module.nic` | One per entry in `nics`; optional public IP and NSG |
| Cisco 8000v VM | `module.cisco_8000v` | NICs chosen with `router_nic_keys` |

```
resource group
├── public IP (tf-rs-pip) ─────────────┬──> Route Server ── BGP ──> peers (bgp_peers)
├── VNet df.tf-rs-vnet                 │
│   └── RouteServerSubnet ─────────────┘
└── NICs (nics) ──> Cisco 8000v VM (router_nic_keys, first = primary)
```

## Repository layout

```
.
├── providers.tf          # Terraform/azurerm versions, remote state backend, OIDC
├── main.tf               # Root module: wires all modules together
├── variables.tf          # Root input variables
├── terraform.tfvars      # Values for the root variables
├── rg/                   # Resource group module
├── pip/                  # Public IP module
├── nic/                  # Network interface (+ NSG association) module
├── route_server/         # Azure Route Server + BGP connections module
├── cisco_8000v/          # Cisco Catalyst 8000v VM module
└── .github/workflows/
    ├── plan.yaml         # PR to main  -> init, validate, plan
    ├── apply.yaml        # push to main -> init, validate, plan, apply
    └── destroy.yaml      # manual       -> plan -destroy, apply
```

Each module has `main.tf` (resources), `variables.tf` (inputs) and `outputs.tf` (outputs, mainly `id`). The route server module's resources are in `route_server/maint.tf`.

## Requirements

- Terraform **>= 1.5.0**
- azurerm provider **~> 5.0**
- An existing storage account for remote state (configured in `providers.tf`):
  resource group `RG.DFvLAB`, account `dftestaccount2568`, container `tfstate`, key `prod.terraform.tfstate`
- An Entra ID app registration / managed identity with:
  - federated credentials for this repo (GitHub environments `tf-plan` and `production`)
  - rights to deploy into the subscription, plus **Storage Blob Data Contributor** on the state storage account
- Accepted Marketplace terms for the Cisco image (once per subscription):

```bash
az vm image terms accept --publisher cisco --offer cisco-c8000v-payg --plan 26_02_payg-advantage
```

## Configuration (`terraform.tfvars`)

### General
| Variable | Example | Description |
|---|---|---|
| `rg_name` | `"df.tf-rg"` | Resource group name |
| `location` | `"uksouth"` | Azure region |
| `tags` | `{ owner = "owner" }` | Tags applied to all resources |

### Public IPs (`pips`)
A map. Each **key is the public IP name** and is also how other resources refer to it.

```hcl
pips = {
  tf-rs-pip = { location = "uksouth" }
}
```

The route server always uses the key `tf-rs-pip`.

### Network interfaces (`nics`)
A map. Each **key is the NIC name**.

| Attribute | Required | Description |
|---|---|---|
| `subnet_id` | yes | Full resource ID of an existing subnet |
| `pip_key` | no | Key from `pips` to attach a public IP; omit for none |
| `nsg_id` | no* | Full resource ID of an existing NSG |
| `accelerated_networking_enabled` | no (default `false`) | Needs a VM size that supports it |

\* The `nic` module currently always creates the NSG association, so in practice `nsg_id` is required. See [Known issues](#known-issues).

```hcl
nics = {
  tf-rtr2-nic1 = {
    subnet_id = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
    nsg_id    = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Network/networkSecurityGroups/<nsg>"
    pip_key   = "tf-rs-pip"
  }
}
```

### Router VM
| Variable | Example | Description |
|---|---|---|
| `router_name` | `"df.tf-rtr2"` | VM name |
| `router_vm_size` | `"Standard_B2s"` | VM size |
| `router_zone` | `["3"]` | Availability zone; `[]` = no zone |
| `router_admin_username` | `"sysadmin"` | Admin user |
| `router_admin_password` | *(secret)* | Admin password; see [Secrets](#secrets) |
| `router_security_type` | `"Standard"` | `"TrustedLaunch"` enables secure boot + vTPM |
| `router_os_disk_type` | `"StandardSSD_LRS"` | OS disk storage type |
| `router_nic_keys` | `["tf-rtr2-nic1", "tf-rtr2-nic2"]` | Keys from `nics`; **first = primary NIC** |

`router_nic_keys` lists NIC *keys* rather than resource IDs, because the NIC IDs don't exist until Terraform creates them. `main.tf` turns the keys into IDs:

```hcl
network_interface_ids = [for nic in var.router_nic_keys : module.nic[nic].id]
```

### Route Server
| Variable | Example | Description |
|---|---|---|
| `route_server_name` | `"df.tf-rs"` | Route Server name |
| `bgp_peers` | see below | Map of BGP peers; the key is the connection name |

```hcl
bgp_peers = {
  dmvpn_rt1 = { peer_asn = 65001, peer_ip = "10.10.10.1" }
}
```

Don't use ASN 65515 for a peer, because Azure reserves it for the Route Server.

## Secrets

Do not commit passwords. Remove `router_admin_password` from `terraform.tfvars`, create a GitHub secret (e.g. `ROUTER_ADMIN_PASSWORD`) and pass it to the Plan / Apply steps:

```yaml
env:
  TF_VAR_router_admin_password: ${{ secrets.ROUTER_ADMIN_PASSWORD }}
```

## CI/CD (GitHub Actions)

| Workflow | Trigger | GitHub environment | Steps |
|---|---|---|---|
| `plan.yaml` | Pull request to `main` | `tf-plan` | init → validate → plan |
| `apply.yaml` | Push to `main` | `production` | init → validate → plan → apply |
| `destroy.yaml` | Manual (`workflow_dispatch`) | `tf-plan` | plan -destroy → apply |

Repository secrets used for the OIDC login:

| Secret | Description |
|---|---|
| `AZURE_CLIENT_ID` | Client ID of the app registration / managed identity |
| `AZURE_TENANT_ID` | Entra ID tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID |

azurerm v4 and later require a subscription ID. If `plan` fails with *"subscription ID could not be determined"*, add this to the Terraform steps:

```yaml
env:
  ARM_USE_OIDC: true
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Running locally

```bash
az login
```

```bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

```bash
terraform init
```

```bash
terraform validate
```

```bash
terraform plan
```

`providers.tf` sets `use_oidc = true`. That only works inside GitHub Actions; for a local run, temporarily set `use_oidc = false` in the provider and backend blocks so Terraform falls back to your Azure CLI login.

## Known issues

- **Duplicate BGP peerings:** `module.route_server` creates a BGP connection for each `bgp_peers` entry, and so does `azurerm_route_server_bgp_connection.rs_peer` in `main.tf`. Both use the same names, so `apply` will fail with a conflict. Keep only one: either remove the `rs_peer` resource from `main.tf`, or stop passing `bgp_connections` to the module.
- **NSG not optional:** `nic/main.tf` always creates the NSG association. To allow NICs without an NSG, add `count = var.nsg_id == null ? 0 : 1` to `azurerm_network_interface_security_group_association.this`.
- **Placeholder IDs:** `subnet_id` and `nsg_id` in `terraform.tfvars` contain `xxxx` and point to a VNet/NSG this code doesn't create. Replace them with real resource IDs.
- **Password in tfvars:** see [Secrets](#secrets).
