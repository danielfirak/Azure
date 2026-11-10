# Resource ID of the NIC (used by the router VM's network_interface_ids)
output "id" {
  value = azurerm_network_interface.this.id
}
