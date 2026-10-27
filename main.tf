resource "azurerm_resource_group" "rg1" {
  name     = "df.tf-rg"
  location = "uksouth"
  tags = {
    deployment = "Terraform"
    env = "devops"
    owner = "df"
  }
}

resource "azurerm_resource_group" "tf-rs-rg" {
  name     = "df.tf-rs-rg"
  location = "uksouth"
}

resource "azurerm_virtual_network" "tf-rs-vnet" {
  name                = "df.tf-rs-vnet"
  address_space       = ["10.0.0.0/24"]
  resource_group_name = azurerm_resource_group.tf-rs-rg.name
  location            = azurerm_resource_group.tf-rs-rg.location

  tags = {
    deployment = "Terraform"
    env = "devops"
    owner = "df"
  }
}

resource "azurerm_subnet" "snet-routeserver" {
  name                 = "snet-routeserver"
  virtual_network_name = azurerm_virtual_network.tf-rs-vnet.name
  resource_group_name  = azurerm_resource_group.tf-rs-rg.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "tf-rs-pip" {
  name                = "df.tf-rs-pip"
  resource_group_name = azurerm_resource_group.tf-rs-rg.name
  location            = azurerm_resource_group.tf-rs-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    deployment = "Terraform"
    env = "devops"
    owner = "df"
}

resource "azurerm_route_server" "tf-rs" {
  name                             = "df.tf-rs"
  resource_group_name = azurerm_resource_group.tf-rs-rg.name
  location            = azurerm_resource_group.tf-rs-rg.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.tf-rs-pip.id
  subnet_id                        = azurerm_subnet.snet-routeserver.id
  branch_to_branch_traffic_enabled = false
  tags = {
    deployment = "Terraform"
    env = "devops"
    owner = "df"
  }
}
