# Inputs for the nic module

variable "name" { type = string }      # NIC name
variable "location" { type = string }  # Azure region
variable "rg_name" { type = string }   # resource group name
variable "subnet_id" { type = string } # full resource ID of the subnet

# Full resource ID of an existing NSG to associate with the NIC
variable "nsg_id" {
  type    = string
  default = null
}

# Full resource ID of a public IP to attach (null = private only)
variable "public_ip_address_id" {
  type    = string
  default = null
}

# Accelerated networking; only works on VM sizes that support it
variable "accelerated_networking_enabled" {
  type    = bool
  default = false
}

variable "tags" { type = map(string) }
