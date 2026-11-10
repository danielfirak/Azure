variable "name" {
  description = "Name of the Public IP address resource."
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group in which to create the Public IP."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Public IP should exist."
  type        = string
}

variable "allocation_method" {
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic."
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.allocation_method)
    error_message = "The allocation_method must be either 'Static' or 'Dynamic'."
  }
}

variable "sku" {
  description = "The SKU of the Public IP. Accepted values are Basic or Standard."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "The sku must be either 'Basic' or 'Standard'."
  }
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for the Public IP. Possible values are Regional or Global."
  type        = string
  default     = "Regional"

  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "The sku_tier must be either 'Regional' or 'Global'."
  }
}

variable "ip_version" {
  description = "The IP Version to use, IPv4 or IPv6."
  type        = string
  default     = "IPv4"

  validation {
    condition     = contains(["IPv4", "IPv6"], var.ip_version)
    error_message = "The ip_version must be either 'IPv4' or 'IPv6'."
  }
}

variable "domain_name_label" {
  description = "Label for the Domain Name. Will be used to make the FQDN relative to the location."
  type        = string
  default     = null
}

variable "zones" {
  description = "A list of Availability Zones in which this Public IP should be allocated."
  type        = list(string)
  default     = null
}

variable "idle_timeout_in_minutes" {
  description = "Specifies the timeout for the TCP idle connection. The value can be set between 4 and 30 minutes."
  type        = number
  default     = 4
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}