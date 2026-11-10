variable "name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the resource group"
  default     = "uksouth"
}
variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resource group"
  default     = {}
}