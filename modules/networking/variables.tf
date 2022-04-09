variable "environment" {
  description = "The Deployment environment"
  default     = null
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  default     = null
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
  default     = null
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
  default     = null
}

variable "region" {
  description = "The region to launch the bastion host"
  default     = null
}

variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
  default     = null
}

