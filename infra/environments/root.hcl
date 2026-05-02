locals {
  env_vars            = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars         = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  subscription        = local.env_vars.locals.subscription_id
  environment         = local.env_vars.locals.environment
  location            = local.region_vars.locals.location
}

inputs = {
  environment = local.environment
  location    = local.location
}

remote_state {
  backend = "azurerm"

  config = {
    subscription_id      = "${local.subscription}"
    resource_group_name  = "si-p-weu-rsg-tfstate"
    storage_account_name = "sipweusatfstate"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "azurerm" {
      subscription_id      = "${local.subscription}"
      features {}
    }
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
      }
    }
  }
  EOF
}
