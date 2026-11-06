variable "name" {
  type        = string
  description = "The name of the Azure Route Server."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Route Server will be deployed."
}

variable "location" {
  type        = string
  description = "The Azure region for the Route Server."
}

variable "subnet_id" {
  type        = string
  description = "The resource ID of the dedicated RouteServerSubnet."
}

variable "public_ip_address_id" {
  type        = string
  description = "The resource ID of the Standard Public IP address."
}

variable "branch_to_branch_traffic_enabled" {
  type        = bool
  description = "Enable or disable branch-to-branch traffic routing."
  default     = true
}

variable "bgp_connections" {
  type = map(object({
    peer_asn = number
    peer_ip  = string
  }))
  description = "A map of BGP peer connections to associate with the Route Server."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Route Server resources."
  default     = {}
}