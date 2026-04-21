variable "vsphere_datacenter" {
  type        = string
  description = "The Datacenter in vCenter in which the F5 BIG-IP VMs should be created"
}
variable "vsphere_datastore" {
  type        = string
  description = "The Datastore on which the F5 BIG-IP VMs' disks should be created"
}
variable "vsphere_cluster" {
  type        = string
  description = "The vSphere Cluster in vCenter in which the F5 BIG-IP VMs should be created"
}
variable "vsphere_folder" {
  type        = string
  description = "The VM folder in vCenter in which the F5 BIG-IP VMs should be created"
}
variable "root_password" {
  type        = string
  sensitive   = true
  description = "root password for the F5 BIG-IP VM's OS."
}
variable "bigiq_admin_password" {
  type        = string
  sensitive   = true
  description = "BIGIQ Admin password for licensing"
}
variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Admin password for the F5 BIG-IP VM's UI/API."
}
variable "vm_template_name" {
  type        = string
  description = "The name of the VM template in vCenter to clone when creating an F5 BIG-IP VM."
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
variable "f5_appsvcs_rpm" {
  description = "F5 Appsvcs package name"
  type        = string
  default     = "f5-appsvcs-3.54.0-7.noarch.rpm"
}
variable "f5_declarative_onboarding_rpm" {
  description = "F5 Declarative Onboarding package name"
  type        = string
  default     = "f5-declarative-onboarding-1.46.0-7.noarch.rpm"
}
variable "tags" {
  type = map(any)
}
