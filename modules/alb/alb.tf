# ALB

resource "aws_alb" "alb" {
  name            = var.alb_name
  subnets         = var.alb_subnets
  security_groups = [aws_security_group.alb_security_group.id]
  internal        = var.alb_facing_internal
  idle_timeout    = var.alb_idle_timeout
  tags = {
    Name        = "${var.environment}-${var.alb_name}"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = var.target_group_name
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id
  tags = {
    name = "${var.environment}-${var.target_group_name}"
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix                 = var.launch_config
  image_id                    = var.ami_id
  key_name                    = var.key_name
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.launch_config_security_group.id]
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "aws_autoscaling_attachment" {
  alb_target_group_arn   = aws_alb_target_group.alb_target_group.arn
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name              = var.autoscaling_group_name
  desired_capacity  = var.desired_instances # ideal number of instance alive
  min_size          = var.min_instances     # min number of instance alive
  max_size          = var.max_instances     # max number of instance alive
  health_check_type = "EC2"

  force_delete = true

  launch_configuration = aws_launch_configuration.launch_configuration.id
  vpc_zone_identifier  = var.vpc_zone_identifier
  timeouts {
    delete = var.instance_timeout # timeout duration for instances
  }
  lifecycle {
    # ensuring the new instance is only created before the other one is destroyed.
    create_before_destroy = true
  }
}
