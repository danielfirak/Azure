# -----------------------------------------------------------------------------
# Module: route_server
# Creates an Azure Route Server and its BGP peerings with network virtual
# appliances (NVAs) such as the Cisco 8000v.
# -----------------------------------------------------------------------------

resource "azurerm_route_server" "this" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Standard" # only supported SKU
  # Must be a subnet named "RouteServerSubnet" (/27 or larger)
  subnet_id = var.subnet_id
  # Standard SKU, static public IP (used by Azure to manage the Route Server)
  public_ip_address_id = var.public_ip_address_id
  # Exchange routes between ExpressRoute/VPN gateways and the NVAs
  branch_to_branch_traffic_enabled = var.branch_to_branch_traffic_enabled
  tags                             = var.tags
}

# One BGP peering per entry in var.bgp_connections (key = connection name)
resource "azurerm_route_server_bgp_connection" "this" {
  for_each        = var.bgp_connections
  name            = each.key
  route_server_id = azurerm_route_server.this.id
  peer_asn        = each.value.peer_asn
  peer_ip         = each.value.peer_ip
}
