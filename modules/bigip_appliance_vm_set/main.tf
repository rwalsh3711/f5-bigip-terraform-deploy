data "vsphere_datacenter" "this" {
  name = var.vsphere_datacenter
}
data "vsphere_datastore" "this" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.this.id
}
data "vsphere_compute_cluster" "this" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.this.id
}
data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.this.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.this.id
}
data "vsphere_network" "port_groups" {
  count         = length(var.port_groups)
  name          = var.port_groups[count.index]
  datacenter_id = data.vsphere_datacenter.this.id
}
data "vsphere_virtual_machine" "template" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.this.id
}
data "vsphere_tag_category" "category" {
  count = length(var.tags)
  name  = keys(var.tags)[count.index]
}
data "vsphere_tag" "tag" {
  count       = length(var.tags)
  name        = var.tags[keys(var.tags)[count.index]]
  category_id = data.vsphere_tag_category.category[count.index].id
}
resource "vsphere_virtual_machine" "appliance_vms" {
  for_each = {
    for index, vars in var.f5_vms :
  vars.hostname => vars }
  name             = each.value.hostname
  resource_pool_id = data.vsphere_compute_cluster.this.resource_pool_id
  folder           = var.vsphere_folder
  datastore_id     = data.vsphere_datastore.this.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  num_cpus         = var.cpus
  memory           = var.memory

  tags = data.vsphere_tag.tag[*].id
  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_password
    host     = each.value.mgmt_ipv4_address
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  dynamic "network_interface" {
    for_each = var.port_groups
    content {
      network_id = data.vsphere_network.port_groups[network_interface.key].id
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
  provisioner "file" {
    destination = "/var/config/rest/downloads/"
    source      = "${path.module}/f5_packages/"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/config/rest/downloads/rpm_install.sh",
      "export ADMIN_PASS='${var.admin_password}' AS3_RPM='${var.f5_appsvcs_rpm}' DO_RPM='${var.f5_declarative_onboarding_rpm}'",
      "bash /var/config/rest/downloads/rpm_install.sh \"$ADMIN_PASS\" \"$AS3_RPM\" \"$DO_RPM\""
    ]
  }
  vapp {
    properties = {
      "net.mgmt.addr"  = "${each.value.mgmt_ipv4_address}/${each.value.mgmt_ipv4_netmask}"
      "net.mgmt.gw"    = each.value.mgmt_ipv4_gateway
      "user.admin.pwd" = var.admin_password
      "user.root.pwd"  = var.root_password
    }
  }
  lifecycle {
    ignore_changes = [
      vapp[0].properties,
      ept_rvi_mode,
      hv_mode
    ]
  }
}
