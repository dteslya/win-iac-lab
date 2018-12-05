resource "vsphere_virtual_machine" "02-ReplicaDC" {
  name                 = "${var.ReplicaDC_name}"
  folder               = "${var.vsphere_folder}"
  firmware             = "bios" # must match template vm setting
  resource_pool_id     = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_cluster_id = "${data.vsphere_datastore_cluster.datastore_cluster.id}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.Win2016GUI_template.network_interface_types[0]}"
  }

  num_cpus = "${var.ReplicaDC_cpu_num}"
  memory   = "${var.ReplicaDC_mem}"
  guest_id = "${data.vsphere_virtual_machine.Win2016GUI_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.Win2016GUI_template.scsi_type}"

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.Win2016GUI_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.Win2016GUI_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.Win2016GUI_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.Win2016GUI_template.id}"

    customize {
      windows_options {
        computer_name    = "${var.ReplicaDC_name}"
        admin_password   = "${var.winadmin_password}"
        auto_logon       = true
        auto_logon_count = 1
        
        # Run these commands after autologon. Configure WinRM access and disable windows firewall.
        run_once_command_list = [
          "winrm quickconfig -force",
          "winrm set winrm/config @{MaxEnvelopeSizekb=\"100000\"}",
          "winrm set winrm/config/Service @{AllowUnencrypted=\"true\"}",
          "winrm set winrm/config/Service/Auth @{Basic=\"true\"}",
          "netsh advfirewall set allprofiles state off",
        ]
      }

      network_interface {
        ipv4_address    = "${var.ReplicaDC_IP}"
        ipv4_netmask    = "${var.netmask}"
        dns_server_list = ["${var.dns_server}"]
      }

      ipv4_gateway = "${var.def_gw}"
    }
  }
}