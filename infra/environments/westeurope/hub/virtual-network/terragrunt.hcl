include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//virtual-network"
}

inputs = {
  vnet_name_suffix = "hub"
  vnet_address_space = ["10.0.0.0/24"]
  subnets =[
    {
      subnet_suffix     = "avd"
      address_prefixes  = ["10.0.0.0/26"]
    },
    {
      subnet_suffix     = "cr"
      address_prefixes  = ["10.0.0.64/26"]
    }
  ]

}