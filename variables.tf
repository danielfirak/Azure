variable pips {
  description = "Public IP address for the route server."
  type        = map(object({
    rg_name   = string
    location  = string
    tags      = map(string)
  }))
}


variable "bgp_peers" {
  description = "List of BGP peers for route server."
  type        = map(object({
    peer_ip       = string
    peer_asn      = number
  }))
  default     = {}
}