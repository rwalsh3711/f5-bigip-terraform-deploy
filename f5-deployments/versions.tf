terraform {
  required_version = ">=1.2.0"
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = ">=2.2.0"
    }
  }
}
