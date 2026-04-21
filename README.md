## F5 BIG-IP Terraform Deployment

## The Problem

Standing up new F5 BIG-IP virtual appliances in a VMware vSphere environment is a multi-hour manual process involving VM deployment, network configuration, management IP assignment, initial onboarding, and installation of required RPM packages for features like AS3 and Declarative Onboarding. Done manually, it's inconsistent across engineers and creates undocumented configuration variations between deployments.

## How It Works

This repository uses Terraform and a custom module to deploy F5 BIG-IP virtual appliances into vSphere with a single pipeline run. The process:

1. A GitLab CI/CD pipeline reads a `.tfvars` file describing the deployment (hostname, management IPs, vSphere placement, port groups)
2. Terraform clones the specified F5 VM template in vCenter
3. Network interfaces are attached to the defined port groups
4. Management IP, netmask, and gateway are configured via vApp properties
5. Admin and root passwords are set via the F5 onboarding process
6. F5 RPM packages (AS3, Declarative Onboarding) are pushed and installed automatically via a shell script
7. The pipeline supports multi-VM deployments from a single tfvars file

The pipeline includes separate stages for validate, plan, apply, destroy, and an unlock stage for recovering from failed runs that leave the Terraform state file locked.

## Requirements

- Terraform 1.2.0 or later
- VMware vSphere provider 2.2.0 or later
- Access to a vCenter environment with an existing F5 BIG-IP VM template
- GitLab CI/CD runner with Terraform, Ansible, and SSH tools available (sample image: `alpine/gitlab-ansible-terraform`)
- A remote Terraform state backend (the included `backend.tf` uses HTTP backend — adjust for your environment)
- Credentials for vSphere and the deployed F5 devices (passed via CI/CD variables)
- F5 RPM packages for AS3 and Declarative Onboarding placed in the `modules/bigip_appliance_vm_set/f5_packages/` directory

## Usage

1. Create a new `.tfvars` file in `f5-deployments/tfvars_folder/` — name it after the hostname (e.g., `f5host01.tfvars`)
2. Populate it with your target deployment values (see Variables section below for full schema)
3. Commit and push to the repository
4. In GitLab, run the pipeline with these variables:
   - `INSTANCE`: the name of your tfvars file (without the `.tfvars` extension)
   - `TERRAFORM_STAGE`: `Plan`, `Apply`, or `Destroy`
5. Review the plan output before running Apply
6. If the state file gets locked from a failed run, use `TERRAFORM_STAGE: Unlock` with `LOCK_ID` set to the lock ID shown in the error


### **Code Description**

This code for F5 deployment is made up of a single GitLab CI/CD pipeline using the **bigip_appliance_vm_set** module located in the **modules** folder.

The root of this repository also contains the _.gitlab-ci.yml_ file used for the CI/CD GitLab pipeline. The pipeline file has five available stages:

| Stage | Description |
| :-----| :---------- |
| unlock | This stage is executed if your **tfstate** file has a lock due to a failed job and you provide a value to the **LOCK_ID** variable. [^1] |
| validate | This stage runs a validation of the Terraform code and associated tfvars file every pipeline run |
| plan | This stage will execute and present a Terraform plan response |
| apply | This stage will execute the Terraform apply command |
| destroy | This stage will execute the Terraform destroy command |

### **Variables**


Under the **f5-prod-deployments** folder exists a sub-folder named **tfvars_folder**. This folder contains the tfvars files used for deployments. The files use a naming convention of _hostname.tfvars_. The file to use is defined to the pipeline using the variable name ***INSTANCE*** in the format "_hostname_". The extension **.tfvars** is appended automatically.

These tfvars files define specific variables used by the modules for build-out of the resources. The main variables are:

| Variable | Example | Description |
| :------- | :------ | :---------- |
| vsphere_server | vcenter1.example.com | The vSphere server to deploy to |
| vsphere_datacenter | datacenter01 | The vSphere datacenter where the resources should be built |
| vsphere_cluster | cluster01 | The vSphere cluster where the resources should be built |
| vsphere_datastore | datastore01-vsan | The vSphere datastore used by the VMs |
| vsphere_folder | f5 | The vSphere VM folder where the resources will reside |
| vm_template_name | TMPL-BIGIP-17.1.2.1-0.0.2 | The vSphere template to use when creating the F5 VMs |
| port_groups | ["MGMT_PORT_GROUP", "HA_SYNC_PORT_GROUP", "DATA_PORT_GROUP"] | List of vSphere port groups for VM network interfaces |
| f5_vms | See below | List of objects for each F5 VM to deploy |
| cpus | 8 | Number of vCPUs to assign to each F5 BIG-IP VM |
| memory | 16384 | Amount of memory (in MB) to assign to each F5 BIG-IP VM |
| tags | See below | Map of tags for the VM |

**f5_vms object structure:**

| Key | Example | Description |
| :-- | :------ | :---------- |
| hostname | f5host01 | The hostname of the F5 VM |
| mgmt_ipv4_address | 192.168.100.20 | The management IP address of the F5 VM |
| mgmt_ipv4_netmask | 24 | The management interface netmask (CIDR) |
| mgmt_ipv4_gateway |  192.168.100.1 | The management interface gateway IP address |

**port_groups** is a list of strings, each representing a vSphere port group for a VM network interface.

**tags** is a map of key/value pairs for VM metadata, e.g.:

```
tags = {
	device_function  = "loadbalancer"
}
```

Sensitive variables (set via CI/CD or environment):

| Variable | Description |
| :------- | :---------- |
| vsphere_username | Username for vSphere provider |
| vsphere_password | Password for vSphere provider |
| f5_bigiq_admin_password | Password for F5 BIGIQ admin management account |
| f5_device_admin_password | Password for F5 device admin account |
| f5_device_root_password | Password for F5 device root account |

### **Deployment Steps**

To deploy new F5 instances perform the following steps:

2. Create a new tfvars file under the **tfvars_folder**
3. Populate the new tfvars files with the desired values for the variables defined above and push to the repository.
4. In the Gitlab repository, navigate to **CI/CD** - **Pipelines** and select "Run Pipeline" in the upper right.
5. For the value for the **INSTANCE** variable, enter the name of tfvars file you created (without the *.tfvars* extension.)
6. Select the stage you wish to run from the **TERRAFORM_STAGE** dropdown (plan, apply, destroy)
7. (OPTIONAL) Add an additional variable named **LOCK_ID** along with the value of that lock ID on the state file should the state file have a hung lock.

### **Known Errors and Limitations**
- N/A

### **Change Log**

**v2.0**
- Code updated to support multiple F5 deployments in a single tfvars file
- Support for vCenter tagging

**v1.0**
- Inital launch

### **Footnotes**

[^1]: You will need to apply an additional variable to the pipeline job with the key **LOCK_ID** and value equaling the lock ID in place on the state file