vsphere_server     = "vcenter01.example.com"
vsphere_datacenter = "datacenter01"
vsphere_cluster    = "cluster01"
vsphere_datastore  = "datastore01-vsan"
vsphere_folder     = "f5"
vm_template_name   = "TMPL-BIGIP-17.1.1.3-0.0.5"

f5_vms = [
  {
    hostname          = "f5host1"
    mgmt_ipv4_address = "192.168.30.21"
    mgmt_ipv4_netmask = "24"
    mgmt_ipv4_gateway = "192.168.30.1"
  }
]

port_groups = [
  "MGMT_PORT_GROUP",
  "HA_SYNC_PORT_GROUP",
  "DATA_PORT_GROUP"
]

tags = {
  device_function  = "loadbalancer"
}
