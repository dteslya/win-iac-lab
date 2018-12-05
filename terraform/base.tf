# Base config
# Vcenter connection parameters
provider "vsphere" {
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
  vsphere_server       = "${var.vsphere_server}"
  allow_unverified_ssl = true
}

# Fetch datacenter data
data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_dc_name}"
}

# Fetch datastore cluster data
data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = "${var.vsphere_dscluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Fetch compute cluster data
data "vsphere_compute_cluster" "cluster" {
  name          = "${var.vsphere_compute_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Fetch port group data
data "vsphere_network" "network" {
  name          = "${var.vsphere_portgroup_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Fetch template vm data
data "vsphere_virtual_machine" "Win2016GUI_template" {
  name          = "${var.vsphere_template_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
