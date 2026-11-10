# -----------------------------------------------------------------------------
# Root module: Azure Route Server + Cisco Catalyst 8000v router
#
# Build order (Terraform works this out from the references below):
#   resource group -> public IPs -> VNet/subnet -> route server (+ BGP peers)
#                                -> NICs -> Cisco 8000v VM
# -----------------------------------------------------------------------------

# Create a resource group that holds every resource in this deployment
module rg {
  source   = "./rg"
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

# Create one public IP per entry in var.pips.
# The map key (e.g. "tf-rs-pip") becomes the resource name and is also the key
# other resources use to look the IP up: module.pip["<key>"].id
module pip {
  source   = "./pip"
  for_each = var.pips
  name     = each.key
  rg_name  = module.rg.name
  location = each.value.location
  tags     = var.tags
}

# Create the Azure Route Server.
# It must live in a subnet named exactly "RouteServerSubnet" and needs a
# Standard SKU public IP (here the "tf-rs-pip" entry from var.pips).
module route_server {
  source               = "./route_server"
  name                 = var.route_server_name
  rg_name              = module.rg.name
  location             = module.rg.location
  public_ip_address_id = module.pip["tf-rs-pip"].id
  subnet_id            = azurerm_subnet.snet-routeserver.id
  bgp_connections      = var.bgp_peers
  tags                 = var.tags
}

# Create one network interface per entry in var.nics.
# Optional settings per NIC:
#   pip_key -> attach the public IP with that key from var.pips (null = no public IP)
#   nsg_id  -> associate an existing NSG with the NIC
module nic {
  source    = "./nic"
  for_each  = var.nics
  name      = each.key
  rg_name   = module.rg.name
  location  = module.rg.location
  subnet_id = each.value.subnet_id
  # Only look up a public IP when pip_key is set; otherwise pass null
  public_ip_address_id           = each.value.pip_key == null ? null : module.pip[each.value.pip_key].id
  nsg_id                         = each.value.nsg_id
  accelerated_networking_enabled = each.value.accelerated_networking_enabled
  tags                           = var.tags
}

# Create the Cisco Catalyst 8000v router VM (marketplace image)
module cisco_8000v {
  source         = "./cisco_8000v"
  name           = var.router_name
  rg_name        = module.rg.name
  location       = module.rg.location
  vm_size        = var.router_vm_size
  zones          = var.router_zone
  admin_username = var.router_admin_username
  admin_password = var.router_admin_password
  security_type  = var.router_security_type
  os_disk_type   = var.router_os_disk_type
  # Turn the NIC keys from tfvars (e.g. ["tf-rtr2-nic1", "tf-rtr2-nic2"]) into
  # the list of NIC IDs created by module.nic. The first NIC is the primary.
  network_interface_ids = [for nic in var.router_nic_keys : module.nic[nic].id]
  tags                  = var.tags
}

# Create a virtual network and subnet for the route server
resource "azurerm_virtual_network" "tf-rs-vnet" {
  name                = "df.tf-rs-vnet"
  address_space       = ["10.0.0.0/24"]
  resource_group_name = module.rg.name
  location            = module.rg.location
  tags                = var.tags

}

# Dedicated Route Server subnet. Azure requires this exact name and at least a /27.
resource "azurerm_subnet" "snet-routeserver" {
  name                 = "RouteServerSubnet"
  virtual_network_name = azurerm_virtual_network.tf-rs-vnet.name
  resource_group_name  = module.rg.name
  address_prefixes     = ["10.0.0.0/24"]
}

# BGP peerings between the Route Server and the routers listed in var.bgp_peers.
# NOTE: module.route_server also creates the same peerings from bgp_connections,
# so each peer is defined twice. Keep only one of the two (see README).
resource "azurerm_route_server_bgp_connection" "rs_peer" {
  for_each        = var.bgp_peers
  name            = each.key
  route_server_id = module.route_server.id
  peer_asn        = each.value.peer_asn
  peer_ip         = each.value.peer_ip
}
