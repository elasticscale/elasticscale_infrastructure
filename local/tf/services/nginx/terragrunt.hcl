terraform {
  source = "git::ssh://git@github.com/elasticscale/elasticscale_infrastructure_modules.git//service?ref=1.0.0"
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

dependency "vpc" {
  // there are two ways to deal with dependency outputs for the VERY FIRST run (when the dependency is not yet deployed)
  // you might run into the error "Either the target module has not been applied yet, or the module has no outputs. If this is expected, set the skip_outputs flag to true on the dependency block."
  // when everything is deployed and the state is managed by Terraform / Terragrunt, you do not need any mock_outputs anymore unless you add a new module later on that other modules depend on
  // 1. for the environment in the module set the initial_auto_apply to true, if you deploy to an empty AWS account this is fine
  //    however, you will not get a plan in for the full deployment, after approving, it will deploy everything directly
  // 2. use mock outputs in the dependency, then you can get an initial plan from the module on what it will deploy
  //    until this issue fixed: https://github.com/gruntwork-io/terragrunt/issues/1330
  //    but probably will never be fixed as its impossible to do without mocks    
  //    mock_outputs = {
  // vpc_id = "vpc-12345678"
  // }
  config_path = "../../vpc"
}

dependency "ecs" {
  // see above    
  config_path = "../../ecs"
}

inputs = {
  prefix                = local.vars["prefix"]
  cluster_name          = dependency.ecs.outputs.cluster_name
  service_name          = "nginx"
  is_production         = local.vars["environment"] == "production"
  vpc_id                = dependency.vpc.outputs.vpc.vpc_id
  subnets               = dependency.vpc.outputs.vpc.private_subnets
  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "nginx",
    "image": "nginx",
    "essential": true
  }
]
TASK_DEFINITION

}