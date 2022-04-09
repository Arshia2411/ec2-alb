# Set common variables for the region.
# This is automatically pulled in by the root terragrunt.hcl configuration to feed forward to the child modules.
locals {
  aws_region = "us-east-1"
}
