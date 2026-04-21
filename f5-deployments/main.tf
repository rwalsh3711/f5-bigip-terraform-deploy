module "f5_vm_instances" {
  source               = "../modules/bigip_appliance_vm_set"
  vsphere_datacenter   = var.vsphere_datacenter
  vsphere_datastore    = var.vsphere_datastore
  vsphere_cluster      = var.vsphere_cluster
  vsphere_folder       = var.vsphere_folder
  vm_template_name     = var.vm_template_name
  f5_vms               = var.f5_vms
  cpus                 = var.cpus
  memory               = var.memory
  root_password        = var.f5_device_root_password
  admin_password       = var.f5_device_admin_password
  bigiq_admin_password = var.f5_bigiq_admin_password
  port_groups          = var.port_groups
  tags                 = var.tags
}
