terraform {
  backend "artifactory" {
    url      = "https://artifactory.company.com/artifactory"
    repo     = "pta-terraform"
    subpath  = "PTAController"
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = "vc.company.com"

  # The released versions are listed here: https://github.com/terraform-providers/terraform-provider-vsphere/releases
  version        = "~> 1.15.0"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

module "PTAController" {
  source                    = "git::https://github.com/Forcepoint/fp-pta-terraform-vsphere-vm-linux-datastore-second-disk.git?ref=master"
  name                      = "PTAController"
  folder                    = "PTA/Prod"
  vm_clone_from             = "PTA/Prod/template-centos-7-prod"
  num_cpus                  = 2
  memory                    = 16384
  ipv4_address              = "192.168.0.12"
  ipv4_netmask              = 24
  ipv4_gateway              = "192.168.0.1"
  dns_suffix_list           = ["company.com"]
  dns_server_list           = ["192.168.0.2"]
  domain                    = "company.com"
  time_zone                 = "MST7MDT"
  vlan_main                 = "VLAN-192"
  vsphere_datastore         = "DS01"
  vsphere_compute_cluster   = "General Cluster"
  vsphere_datacenter        = "DC"
}
