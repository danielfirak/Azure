variable "name" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "subnet_id" { type = string }
variable "nsg_id" { 
    type = string 
    default = null 
    }
variable "public_ip_address_id" { 
    type = string 
    default = null 
    }
variable "enable_accelerated_networking" { 
    type = bool
    default = false
    }
variable "tags" { type = map(string) }