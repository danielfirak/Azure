variable "bgp_peers" {
  description = "List of BGP peers for route server."
  type        = map(object({
    peer_ip       = string
    peer_asn      = number
  }))
  description = "A map of BGP peers where the key is the peer name and the value is an object containing the peer IP and ASN."
  default     = {}
}