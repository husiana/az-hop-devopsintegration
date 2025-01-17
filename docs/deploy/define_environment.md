# Define the environment
An **az-hop** environment is defined in the `config.yml` configuration file. Before starting, use the `config.tpl.yml` template to build a configuration file that fill your needs.
Here is a template for building such configuration file.

```yml
---
# azure location name as returned by the command : az account list-locations -o table
location: westeurope
# Name of the resource group to create all resources
resource_group: azhop
# Size of the ANF pool and unique volume
homefs_size_tb: 4
# Service level of the ANF volume, can be: Standard, Premium, Ultra
homefs_service_level: Standard
# name of the homedir on the ANF volume
homedir_mountpoint: /anfhome
# dual protocol
dual_protocol: false # true to enable SMB support. false by default
# name of the admin account
admin_user: hpcadmin
# Object ID to grant key vault read access
key_vault_readers: #<object_id>
# Network
network:
  vnet:
    name: hpcvnet # Optional - default to hpcvnet
    id: # If a vnet id is set then no network will be created and the provided vnet will be used
    address_space: "10.0.0.0/16" # Optional - default to "10.0.0.0/16"
    # When using an existing VNET, only the subnet names will be used and not the adress_prefixes
    subnets: # all subnets are optionals
    # name values can be used to rename the default to specific names, address_prefixes to change the IP ranges to be used
    # All values below are the default values
      frontend: 
        name: frontend
        address_prefixes: "10.0.0.0/24"
      admin:
        name: admin
        address_prefixes: "10.0.1.0/24"
      netapp:
        name: netapp
        address_prefixes: "10.0.2.0/24"
      compute:
        name: compute
        address_prefixes: "10.0.16.0/20"
  peering: # This is optional, and can be used to create a VNet Peering in the same subscription.
    vnet_name: #"VNET Name to Peer to"
    vnet_resource_group: #"Resource Group of the VNET to peer to"
# When working in a locked down network, uncomment and fill out this section
# locked_down_network: 
#   enforce: true
#   grant_access_from: [a.b.c.d] # Array of CIDR to grant access from, see https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal#grant-access-from-an-internet-ip-range
# Active directory VM configuration
ad:
  vm_size: Standard_D2s_v3
# On demand VM configuration
ondemand:
  vm_size: Standard_D4s_v3
# Scheduler VM configuration
scheduler:
  vm_size: Standard_D2s_v3
# CycleCloud VM configuration
cyclecloud:
  vm_size: Standard_D2s_v3
  # Azure Image Reference for CycleCloud. Default to 8.2.020210809 if not present
  image: 
    publisher: "azurecyclecloud"
    offer:     "azure-cyclecloud"
    sku:       "cyclecloud-81"
    version:   "8.2.020210809"
  # Azure Image Plan for CycleCloud. Default to 8.1 if not present
  plan: 
    name:      "cyclecloud-81"
    publisher: "azurecyclecloud"
    product:   "azure-cyclecloud"
# uncomment if updated RPMS need to be applied
#  rpms:
    # optional URL to apply a fix on the marketplace image deployed on the ccportal
#    cyclecloud:
    # mandatory URL on the jetpack RPM to be installed on the ccportal and the scheduler
#    jetpack:
# Lustre cluster configuration
lustre:
  rbh_sku: "Standard_D8d_v4"
  mds_sku: "Standard_D8d_v4"
  oss_sku: "Standard_D32d_v4"
  oss_count: 2
  version: "2.12.4"
  hsm_max_requests: 8
  mdt_device: "/dev/sdb"
  ost_device: "/dev/sdb"
  hsm:
    # optional to use existing storage for the archive
    # if not included it will use the azhop storage account that is created
    storage_account: # existing_storage_account_name
    storage_container: #only_used_with_existing_storage_account
# List of users to be created on this environment
users:
  - name: user1
    uid: 10001
    gid: 5000
    shell: /bin/bash
    home: /anfhome/user1
    admin: false # true will allow user to have admin privilege like updating dashboards
    sudo: true # Allow sudo access - false by default
  - name: user2
    uid: 10002
    gid: 5000
    shell: /bin/bash
    home: /anfhome/user2
    admin: false
groups: # Not used today => To be used in the future
  - name: users
    gid: 5000
# List of images to be defined
images:
  - name: image_definition_name # Should match the packer configuration file name, one per packer file
    publisher: azhop
    offer: CentOS
    sku: 7_9-gen2
    hyper_v: V2 # V1 or V2 (V1 is the default)
    os_type: Linux # Linux or Windows
    version: 7.9 # Version of the image to create the image definition in SIG
# List of queues (node arays in Cycle) to be defined
queues:
  - name: execute # name of the Cycle Cloud node array
    # Azure VM Instance type
    vm_size: Standard_F2s_v2
    # maximum number of cores that can be instanciated
    max_core_count: 1024
    # marketplace image name or custom image id
    image: OpenLogic:CentOS-HPC:7_9-gen2:latest
    # Set to true if AccelNet need to be enabled. false is the default value
    EnableAcceleratedNetworking: false
    # spot instance support. Default is false
    spot: true
  - name: hc44rs
    vm_size: Standard_HC44rs
    max_core_count: 1024
    image: OpenLogic:CentOS-HPC:7_9-gen2:latest
  - name: hb60rs
    vm_size: Standard_HB60rs
    max_core_count: 1024
    # The image ID is here built by reusing global ansible variables
    image: /subscriptions/{{subscription_id}}/resourceGroups/{{resource_group}}/providers/Microsoft.Compute/galleries/{{sig_name}}/images/azhop-centos79-v2-rdma-gpgpu/latest
  - name: hb120rs_v2
    vm_size: Standard_HB120rs_v2
    max_core_count: 1024
    image: /subscriptions/{{subscription_id}}/resourceGroups/{{resource_group}}/providers/Microsoft.Compute/galleries/{{sig_name}}/images/azhop-centos79-v2-rdma-gpgpu/latest
  - name: viz3d
    vm_size: Standard_NV6
    max_core_count: 1024
    image: /subscriptions/{{subscription_id}}/resourceGroups/{{resource_group}}/providers/Microsoft.Compute/galleries/{{sig_name}}/images/centos-7.8-desktop-3d/latest
```