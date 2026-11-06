rg_name = "df.tf-rg"
location = "uksouth"

route_server_name = "df.tf-rs"


tags = {
   owner = "owner"
   deployment = "terraformenvironment"
}

pips = {
   tf-rs-pip = { rg_name = "df.tf-rg", location = "uksouth" }
}

bgp_peers = {
   dmvpn_rt1 = {peer_asn = "65001", peer_ip = "10.10.10.1",  }
   dmvpn_rt2 = {peer_asn = "65001", peer_ip = "10.10.10.2",  }

    }


