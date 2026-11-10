# Inputs for the cisco_8000v module

variable "name" { type = string }     # VM name
variable "location" { type = string } # Azure region
variable "rg_name" { type = string }  # resource group name
variable "vm_size" { type = string }  # VM size, e.g. Standard_B2s
variable "zones" { type = list(string) } # only the first zone is used; [] = no zone
variable "admin_username" { type = string }
variable "admin_password" {
  type      = string
  sensitive = true # hidden in plan/apply output
}
variable "network_interface_ids" { type = list(string) } # NIC IDs, primary first
variable "os_disk_type" { type = string }                # e.g. StandardSSD_LRS

# "TrustedLaunch" enables secure boot + vTPM; anything else (e.g. "Standard") disables them
variable "security_type" {
  type    = string
  default = "TrustedLaunch"
}
variable "hibernation_enabled" {
  type    = bool
  default = false
}
variable "tags" { type = map(string) }
