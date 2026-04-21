variable "vsphere_username" {
  type        = string
  description = "Username for vsphere provider"
}
variable "vsphere_password" {
  type        = string
  description = "Password for vsphere provider"
}
variable "vsphere_server" {
  type        = string
  description = "IP address for vcenter server of vsphere provider"
}
variable "vm_template_name" {
  type        = string
  description = "Name of VM template to deploy F5 VMs from."
}
variable "vsphere_datacenter" {
  type        = string
  description = "The Datacenter in the vCenter in which the F5 BIG-IP VMs should be created"
}
variable "vsphere_cluster" {
  type        = string
  description = "The vSphere Cluster in the vCenter in which the F5 BIG-IP VMs should be created"
}
variable "vsphere_datastore" {
  type        = string
  description = "The Datastore in the vCenter on which the F5 BIG-IP VMs' disks should be created"
}
variable "vsphere_folder" {
  type        = string
  description = "The VM folder in the vCenter in which the F5 BIG-IP VMs should be created"
}
variable "f5_bigiq_admin_password" {
  type        = string
  sensitive   = true
  description = "Password for F5 BIGIQ admin management account"
}
variable "f5_device_admin_password" {
  type        = string
  sensitive   = true
  description = "Password for F5 device admin account"
}
variable "f5_device_root_password" {
  type        = string
  sensitive   = true
  description = "Password for F5 device root account"
}
variable "port_groups" {
  type        = list(string)
  description = "A list of port groups for network interfaces"
}
variable "f5_vms" {
  description = "The network configuration to apply to the F5 BIG-IP VMs."
  type = list(object({
    hostname          = string
    mgmt_ipv4_address = string
    mgmt_ipv4_netmask = number
    mgmt_ipv4_gateway = string
  }))
}
variable "cpus" {
  description = "Number of vCPUs to assign to each F5 BIG-IP VM."
  type        = number
  default     = 8
}
variable "memory" {
  description = "Amount of memory (in MB) to assign to each F5 BIG-IP VM."
  type        = number
  default     = 16384
}
variable "tags" {
  type = map(any)
}
