provider "aws" {
    region = var.region
}

#creating VPC
resource "aws_vpc" "test_vpc" {
    cidr_block = var.vpc_cidr_block
    #enable_dns_hostnames = true
}

resource "aws_internet_gateway" "test_vpc_igw" {
    vpc_id = aws_vpc.test_vpc.id
}

# creating a public RT
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.test_vpc.id
    route {
        cidr_block = var.pubRT_cidr_block
        gateway_id = aws_internet_gateway.test_vpc_igw.id
    }
}
#creating a public subnet
#subnet in availaility zone 1
resource "aws_subnet" "public_subnet_1a" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = var.pubSub1_cidr_block
    availability_zone = var.avail_zone1
    map_public_ip_on_launch = "true"

}
# associating the internet gateway
resource "aws_route_table_association" "pubSub_1a_rt" {
    subnet_id = aws_subnet.public_subnet_1a.id
    route_table_id = aws_route_table.public_rt.id
}

# creating a private subnet
resource "aws_subnet" "private_subnet_1c" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = var.privSub_cidr_block
    availability_zone = var.avail_zone2
    map_public_ip_on_launch = false              
}

# elastic IP for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.test_vpc_igw]
}   

# creating NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1a.id  
}

#creating RT for private subnet
resource "aws_route_table" "private-rt" {
    vpc_id = aws_vpc.test_vpc.id
  
    route {
      cidr_block = var.privRT_cidr_block
      gateway_id = aws_nat_gateway.nat.id
    }
}   

resource "aws_route_table_association" "private-rt" {
    subnet_id      = aws_subnet.private_subnet_1c.id
    route_table_id = aws_route_table.private-rt.id
}

#creating an Application Load Balancer.
#attaching the previous availability zones' subnets into this load balancer.
resource "aws_lb" "alb_1" {
    #name = "my-alb"
    internal = true # set lb for public access
    load_balancer_type = "application" # use Application Load Balancer
    security_groups = [aws_security_group.alb_security_group.id]
    subnets = [ # attach the availability zones' subnets.
        aws_subnet.public_subnet_1a.id,
        aws_subnet.private_subnet_1c.id 
    ]
}
# preparing a security group for our load balancer alb_1.
resource "aws_security_group" "alb_security_group" {
    vpc_id = aws_vpc.test_vpc.id
    ingress = [
    {
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "http"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
  egress = [
    {
      description      = "all-open"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
}
resource "aws_lb_listener" "alb_1_listener" {  
    load_balancer_arn = aws_lb.alb_1.arn
    port = 80  
    protocol = "HTTP"
    default_action {    
        target_group_arn = aws_lb_target_group.alb_1_target_group.arn
        type = "forward"
    }
}


resource "aws_lb_target_group" "alb_1_target_group" {
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.test_vpc.id
}
resource "aws_launch_configuration" "my_launch_configuration" {

    image_id = var.ami_id
    key_name = "test"

    instance_type = var.instance_type
    security_groups = [aws_security_group.launch_config_security_group.id]
    associate_public_ip_address = true
    lifecycle {
        # ensuring a new instance is only created before the other one is destroyed.
        create_before_destroy = true
    }

    # to execute bash scripts on EC2
    user_data = file("website.sh")
}
# security group for launch config my_launch_configuration.
resource "aws_security_group" "launch_config_security_group" {
    vpc_id = aws_vpc.test_vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
#creating an autoscaling attachment for alb_1_target_group.
resource "aws_autoscaling_attachment" "my_aws_autoscaling_attachment" {
    alb_target_group_arn = aws_lb_target_group.alb_1_target_group.arn
    autoscaling_group_name = aws_autoscaling_group.my_autoscaling_group.id
}
#define the autoscaling group.
# attaching my_launch_configuration to an created autoscaling group
resource "aws_autoscaling_group" "my_autoscaling_group" {
    name = "my-autoscaling-group"
    desired_capacity = var.alive_instances # ideal number of instance alive
    min_size = var.min_instances # min number of instance alive
    max_size = var.max_instances # max number of instance alive
    health_check_type = "EC2"

    # allows deleting the autoscaling group without waiting
    # for all instances in the pool to terminate
    force_delete = true

    launch_configuration = aws_launch_configuration.my_launch_configuration.id
    vpc_zone_identifier = [
        aws_subnet.public_subnet_1a.id,
        aws_subnet.private_subnet_1c.id 
    ]
    timeouts {
        delete = var.instance_timeout # timeout duration for instances
    }
    lifecycle {
        # ensuring the new instance is only created before the other one is destroyed.
        create_before_destroy = true
    }
}
