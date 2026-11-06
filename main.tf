module rg {
  source = "./rg"
  name = var.rg_name
  location = var.location
  tags = var.tags
}

module pip {
  source = "./pip"
  for_each = var.pips
  name = each.key
  rg_name = module.rg.name
  location = each.value.location
  tags = each.value.tags
}

resource "azurerm_virtual_network" "tf-rs-vnet" {
  name                = "df.tf-rs-vnet"
  address_space       = ["10.0.0.0/24"]
  resource_group_name = module.rg.name
  location            = azurerm_resource_group.tf-rs-rg.location

  tags = {
    deployment = "Terraform"
    env = "devops"
    owner = "df"
  }

}

resource "azurerm_subnet" "snet-routeserver" {
  name                 = "RouteServerSubnet"
  virtual_network_name = azurerm_virtual_network.tf-rs-vnet.name
  resource_group_name  = azurerm_resource_group.tf-rs-rg.name
  address_prefixes     = ["10.0.0.0/24"]
}





resource "azurerm_route_server" "tf-rs" {
  name                             = "df.tf-rs"
  resource_group_name = azurerm_resource_group.tf-rs-rg.name
  location            = azurerm_resource_group.tf-rs-rg.location
  sku                              = "Standard"
  public_ip_address_id             = module.pip["tf-rs-pip"].id
  subnet_id                        = azurerm_subnet.snet-routeserver.id
  branch_to_branch_traffic_enabled = false
  tags = {
    deployment = "Terraform"
    env = "devops"
    owner = "df"
  }
}

resource "azurerm_route_server_bgp_connection" "rs_peer" {
  for_each = var.bgp_peers
  name = each.key
  route_server_id = azurerm_route_server.tf-rs.id
  peer_asn = each.value.peer_asn
  peer_ip = each.value.peer_ip
}