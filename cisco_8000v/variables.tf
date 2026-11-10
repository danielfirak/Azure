variable "name" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "vm_size" { type = string }
variable "zones" { type = list(string) }
variable "admin_username" { type = string }
variable "admin_password" { 
    type = string
    sensitive = true 
    }
variable "network_interface_ids" { type = list(string) }
variable "os_disk_type" { type = string }
variable "os_disk_delete_option" { 
    type = string 
    default = "Delete"
    }
variable "security_type" { 
    type = string 
    default = "TrustedLaunch"
    }
variable "hibernation_enabled" { 
    type = bool
    default = false
    }
variable "tags" { type = map(string) }