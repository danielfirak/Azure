variable pips {
  description = "Public IP address for the route server."
  type        = map(object({
    location  = string
 #   tags      = map(string)
  }))
}

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

variable "nics" {
  description = "Network interfaces for the route server."
  type        = map(object({
    subnet_id = string
    pip_key = optional(string)
    nsg_id = optiona(string)
    accelerated_networking_enabled = optional(bool, false)
  }))
}

variable "route_server_name" {
  description = "Name of the route server."
  type        = string
}

variable "bgp_peers" {
  description = "List of BGP peers for route server."
  type        = map(object({
    peer_ip       = string
    peer_asn      = number
  }))
  default     = {}
}