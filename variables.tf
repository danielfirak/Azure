# -----------------------------------------------------------------------------
# Root input variables. Values are set in terraform.tfvars.
# -----------------------------------------------------------------------------

# ---- Public IPs --------------------------------------------------------------

# Map of public IPs to create. The key is the public IP name and the key other
# resources use to reference it (route server, NICs via pip_key).
variable pips {
  description = "Public IP address for the route server."
  type = map(object({
    location = string
    #   tags      = map(string)
  }))
}

# ---- General -----------------------------------------------------------------

variable "rg_name" {
  description = "Resource group name for the route server."
  type        = string
}
variable "location" {
  description = "Location for the route server."
  type        = string
}
variable "tags" {
  description = "Tags for the route server."
  type        = map(string)
  default     = {}
}

# ---- Network interfaces ------------------------------------------------------

# Map of NICs to create. The key is the NIC name and the key used by
# router_nic_keys to attach NICs to the router VM.
variable "nics" {
  description = "Network interfaces for the route server."
  type = map(object({
    subnet_id                      = string                # full resource ID of the subnet
    pip_key                        = optional(string)      # key from var.pips, or omit for no public IP
    nsg_id                         = optional(string)      # full resource ID of an existing NSG, or omit
    accelerated_networking_enabled = optional(bool, false) # needs a VM size that supports it
  }))
}

# ---- Cisco 8000v router VM ---------------------------------------------------

variable "router_name" { type = string }    # VM name
variable "router_vm_size" { type = string } # e.g. Standard_B2s
variable "router_zone" { type = list(string) } # availability zone, e.g. ["3"]; [] = no zone
variable "router_admin_username" { type = string }
# Do not commit a real password: prefer TF_VAR_router_admin_password from a CI secret
variable "router_admin_password" {
  type      = string
  sensitive = true
}
variable "router_security_type" { type = string }    # "TrustedLaunch" or "Standard"
variable "router_os_disk_type" { type = string }     # e.g. StandardSSD_LRS, Premium_LRS
variable "router_nic_keys" { type = list(string) } # keys from var.nics, primary NIC first

# ---- Route Server ------------------------------------------------------------

variable "route_server_name" {
  description = "Name of the route server."
  type        = string
}

# Map of BGP peers. The key is the BGP connection name.
variable "bgp_peers" {
  description = "List of BGP peers for route server."
  type = map(object({
    peer_ip  = string # IP of the NVA/router that peers with the Route Server
    peer_asn = number # ASN of that router (must not be 65515, used by Azure)
  }))
  default = {}
}
