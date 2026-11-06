resource "azurerm_route_server" "this" {
  name                             = var.name
  resource_group_name              = var.rg_name
  location                         = var.location
  sku                              = "Standard"
  subnet_id                        = var.subnet_id
  public_ip_address_id             = var.public_ip_address_id
  branch_to_branch_traffic_enabled = var.branch_to_branch_traffic_enabled
  tags                             = var.tags
}

resource "azurerm_route_server_bgp_connection" "this" {
  for_each        = var.bgp_connections
  name            = each.key
  route_server_id = azurerm_route_server.this.id
  peer_asn        = each.value.peer_asn
  peer_ip         = each.value.peer_ip
}