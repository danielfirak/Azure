output "id" {
  description = "The resource ID of the Azure Route Server."
  value       = azurerm_route_server.this.id
}

output "name" {
  description = "The name of the Azure Route Server."
  value       = azurerm_route_server.this.name
}

output "routing_state" {
  description = "The routing state of the Azure Route Server."
  value       = azurerm_route_server.this.routing_state
}

output "virtual_hub_asn" {
  description = "The Autonomous System Number (ASN) of the Azure Route Server."
  value       = azurerm_route_server.this.virtual_hub_asn
}