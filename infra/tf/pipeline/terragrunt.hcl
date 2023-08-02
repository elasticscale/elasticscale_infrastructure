terraform {
  source = "git::ssh://git@github.com/elasticscale/elasticscale_infrastructure_modules.git//pipeline?ref=1.0.0"
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


dependency "infrastructure" {
  // see above    
  config_path = "../infrastructure"
}


inputs = {
  environments = {
    infra = {
      account_id         = "136431940157"
      initial_auto_apply = true
    },
    staging = {
      account_id         = "257804771987"
      initial_auto_apply = true
    },
    prod = {
      account_id         = "540259191132"
      initial_auto_apply = true
    },
    security = {
      account_id         = "689298222225"
      initial_auto_apply = true
    }
  }
  enable_tfsec                   = false
  codestar_connection_arn        = dependency.infrastructure.outputs.codestar_connection_arn
  repository_name_infrastructure = "elasticscale/acmesystems_infrastructure"
  repository_name_modules        = "elasticscale/acmesystems_infrastructure_modules"
  full_modules_url               = "git::ssh://git@github.com/elasticscale/elasticscale_infrastructure_modules.git"
  terragrunt_docker_image        = "${dependency.infrastructure.outputs.image_base_url}devopsinfra/docker-terragrunt:aws-tf-1.5.5-tg-0.50.1"
  tfsec_docker_image             = "${dependency.infrastructure.outputs.image_base_url}aquasec/tfsec:v1.28"
}