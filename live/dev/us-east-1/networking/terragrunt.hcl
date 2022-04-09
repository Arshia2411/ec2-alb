locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
}

terraform {
  #   source = "${path_relative_from_include()}/modules//networking"
  source = "../../../../modules/networking"
}

inputs = {
  environment          = "${local.env}"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets_cidr = ["10.0.2.0/24"]
  region               = "us-east-1"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  cidr_block_sg        = ["0.0.0.0/0"]
}
