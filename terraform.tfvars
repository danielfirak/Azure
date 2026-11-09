#Resource group variables
g_name = "df.tf-rg"
location = "uksouth"

#public ip variables name and location
pips = {
   tf-rs-pip = { rg_name = "df.tf-rg", location = "uksouth" }
}

nics = {
   tf-rtr2-nic1 = { 
      subnet_id = "/subscriptions/xxxx/resourceGroups/df.tf-rg/providers/Microsoft.Network/virtualNetworks/df.tf-vnet/subnets/df.tf-subnet1"
      nsg_id = "/subscriptions/xxxx/resourceGroups/df.tf-rg/providers/Microsoft.Network/networkSecurityGroups/df.tf-nsg"
      pip_key = "tf-rs-pip"
      }
   tf-rtr2-nic2 = { 
      subnet_id = "/subscriptions/xxxx/resourceGroups/df.tf-rg/providers/Microsoft.Network/virtualNetworks/df.tf-vnet/subnets/df.tf-subnet1"
      nsg_id = "/subscriptions/xxxx/resourceGroups/df.tf-rg/providers/Microsoft.Network/networkSecurityGroups/df.tf-nsg"
      }
}

#Route server variables name and BGP peers
route_server_name = "df.tf-rs"
bgp_peers = {
   dmvpn_rt1 = {peer_asn = "65001", peer_ip = "10.10.10.1",  }
   dmvpn_rt2 = {peer_asn = "65001", peer_ip = "10.10.10.2",  }

    }
#Tags for the resources
tags = {
   owner = "owner"
   deployment = "terraformenvironment"
}






