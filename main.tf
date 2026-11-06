#Create a resource group
module rg {
  source = "./rg"
  name = var.rg_name
  location = var.location
  tags = var.tags
}

#Create a public IP for the route server
module pip {
  source = "./pip"
  for_each = var.pips
  name = each.key
  rg_name = module.rg.name
  location = each.value.location
  tags = var.tags
}

#Create a route server
module route_server {
  source = "./route_server"
  name = var.route_server_name
  rg_name = module.rg.name
  location = module.rg.location
  public_ip_address_id = module.pip["tf-rs-pip"].id
  subnet_id = azurerm_subnet.snet-routeserver.id
  bgp_connections = var.bgp_peers
  tags = var.tags
}

#Create a virtual network and subnet for the route server
resource "azurerm_virtual_network" "tf-rs-vnet" {
  name                = "df.tf-rs-vnet"
  address_space       = ["10.0.0.0/24"]
  resource_group_name = module.rg.name
  location            = module.rg.location
  tags = var.tags

}
resource "azurerm_subnet" "snet-routeserver" {
  name                 = "RouteServerSubnet"
  virtual_network_name = azurerm_virtual_network.tf-rs-vnet.name
  resource_group_name  = module.rg.name
  address_prefixes     = ["10.0.0.0/24"]
}


resource "azurerm_route_server_bgp_connection" "rs_peer" {
  for_each = var.bgp_peers
  name = each.key
  route_server_id = module.route_server.id
  peer_asn = each.value.peer_asn
  peer_ip = each.value.peer_ip
}