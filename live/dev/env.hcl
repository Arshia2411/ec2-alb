# Set common variables for the environment.
# This is automatically pulled in by the root terragrunt.hcl configuration to feed forward to the child modules.
locals {
  environment = "dev"
}