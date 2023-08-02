terraform {
  source = "git::ssh://git@github.com/elasticscale/elasticscale_infrastructure_modules.git//security?ref=1.0.0"
}

// include the terraform configuration like provider and backend blocks
include "root" {
  path = find_in_parent_folders()
}

// terragrunt does not support globally defined locals
// this means we must define them in every terragrunt file we want to use before we can use them
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  env_vars    = yamldecode(file(find_in_parent_folders("env_vars.yaml")))
  vars        = merge(local.common_vars, local.env_vars)
}

inputs = {
  prefix = local.vars["prefix"]
  account_ids = {
    infra   = "136431940157"
    prod    = "540259191132"
    staging = "257804771987"
  }
  users = [{
    username = "alex"
    email    = "alex@elasticscale.cloud"
  }]
}