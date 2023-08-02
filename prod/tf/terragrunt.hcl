locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  env_vars    = yamldecode(file("./env_vars.yaml"))
  vars        = merge(local.common_vars, local.env_vars)
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.vars["region"]}"
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.vars["prefix"]}-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.vars["region"]
    encrypt        = true
    dynamodb_table = "${local.vars["prefix"]}-state-lock"
  }
}