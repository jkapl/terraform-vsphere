provider "vsphere" {
  user           = ""
  password       = ""
  vsphere_server = "vcsa.csplab.local"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "CSPLAB"
}

# data "vsphere_folder" "folder" {
#   path = "cpat-ocp3"
# }

resource "vsphere_folder" "folder" {

  path          = "./Sandbox/cpat-enablement/cpat-sf/cpat-ocp3/terraform"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = "SANDBOX-1-11"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "cpat-ocp"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "OCP"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "rhcos-4.2.0-x86_64-vmware-template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = "./Sandbox/cpat-enablement/cpat-sf/cpat-ocp3/terraform"

  num_cpus = 2
  memory   = 1024
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    datastore_id = data.vsphere_datastore.datastore.id
    size  = 200
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
      template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }
}
