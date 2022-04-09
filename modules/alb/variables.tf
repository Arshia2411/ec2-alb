# ALB
variable "environment" {
  type    = string
  default = null
}

variable "alb_name" {
  type        = string
  description = "ALB Name"
  default     = null
}

variable "alb_subnets" {
  type        = list(string)
  description = "ALB subents"
  default     = null
}

variable "alb_facing_internal" {
  type        = bool
  description = "Set ALB to internet or internal facing"
  default     = null
}

variable "alb_idle_timeout" {
  type        = number
  description = "set alb idle timeout"
  default     = null
}

variable "port" {
  type        = number
  description = "alb listener port"
  default     = null
}

variable "protocol" {
  type        = string
  description = "alb listener protocol"
  default     = null
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "target_group_name" {
  type        = string
  description = "alb target group name"
  default     = null
}


# Launch configurations
variable "launch_config" {
  type        = string
  description = "launch config name"
  default     = null
}

variable "ami_id" {
  type        = string
  description = "ec2 ami id"
  default     = null
}

variable "key_name" {
  type        = string
  description = "ec2 key"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "ec2 instance type"
  default     = null
}

variable "autoscaling_group_name" {
  type    = string
  default = null
}

variable "desired_instances" {
  type    = number
  default = null
}

variable "min_instances" {
  type    = number
  default = null
}

variable "max_instances" {
  type    = number
  default = null
}

variable "instance_timeout" {
  type    = string
  default = null
}

variable "vpc_zone_identifier" {
  type    = list(string)
  default = null

}
