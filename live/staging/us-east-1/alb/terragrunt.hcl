locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
}

terraform {
  #   source = "${path_relative_from_include()}/modules//networking"
  source = "../../../../modules/alb"
}

inputs = {
  environment            = "${local.env}"
  alb_name               = "${local.env}-alb-paa"
  alb_subnets            = ["subnet-0ae224d72a7e6f253", "subnet-0303eae9541046283"]
  alb_facing_internal    = false
  alb_idle_timeout       = 60
  port                   = 80
  protocol               = "HTTP"
  vpc_id                 = "vpc-05b8068f2b568ce78"
  target_group_name      = "${local.env}-tg-paa"
  launch_config          = "${local.env}-launch-configuration"
  ami_id                 = "ami-0e7d48a0f9b93efd1"
  key_name               = "abhay-test"
  instance_type          = "t2.micro"
  autoscaling_group_name = "${local.env}-autoscaling_group-paa"
  desired_instances      = 2
  min_instances          = 1
  max_instances          = 3
  instance_timeout       = "15m"
  vpc_zone_identifier    = ["subnet-0ae224d72a7e6f253", "subnet-0303eae9541046283"]
}
