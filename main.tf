resource "azurerm_resource_group" "rg1" {
  name     = "df.tf-rg"
  location = "uksouth"
  tags = {
    deployment = "Terraform"
  }
}

