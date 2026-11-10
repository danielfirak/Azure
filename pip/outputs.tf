output "id" {
  description = "The ID of the Public IP resource."
  value       = azurerm_public_ip.this.id
}

output "ip_address" {
  description = "The IP address value assigned to the resource."
  value       = azurerm_public_ip.this.ip_address
}

output "fqdn" {
  description = "The Fully Qualified Domain Name (FQDN) associated with the Public IP."
  value       = azurerm_public_ip.this.fqdn
}

output "name" {
  description = "The name of the Public IP resource."
  value       = azurerm_public_ip.this.name
}

output "resource_group_name" {
  description = "The name of the resource group containing the Public IP."
  value       = azurerm_public_ip.this.resource_group_name
}