provider "aws" {
  region = "us-west-2" # Change to your desired region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Subnets
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true
}

# Security Group
resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Application Load Balancer (ALB)
resource "aws_lb" "application" {
  name                             = "my-alb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.eks_sg.id]
  subnets                          = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id, aws_subnet.subnet_c.id]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    Environment = "dev"
  }
}

# Elastic Kubernetes Service (EKS)
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 19.0"
  cluster_name                   = "my-eks-cluster"
  cluster_version                = "1.21"
  subnet_ids                     = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id, aws_subnet.subnet_c.id]
  vpc_id                         = aws_vpc.main.id
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    eks_nodes = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }
  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "777777777777",
    "888888888888",
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_launch_template" "greet_template" {
  name_prefix   = "greet"
  image_id      = "ami-1a2b3c" # AMI ID
  instance_type = "t3.large"
}

# Auto Scaling Group
resource "aws_autoscaling_group" "eks_nodes" {
  desired_capacity    = 1
  max_size            = 10
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id, aws_subnet.subnet_c.id]

  launch_template {
    id      = aws_launch_template.greet_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "eks-node"
    propagate_at_launch = true
  }
}

# Target Group for EKS Nodes
resource "aws_lb_target_group" "eks_nodes_target_group" {
  name     = "eks-nodes-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/health"
  }

  target_health_state {
    enable_unhealthy_connection_termination = false
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 3600
  }
}

# Listener Rule to Forward Traffic to EKS Nodes Target Group
resource "aws_lb_listener_rule" "eks_nodes_listener_rule" {
  listener_arn = aws_lb.application.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_nodes_target_group.arn
  }

  condition {
    host_header {
      values = ["*.acme.co"]
    }
  }
}

# Relational Database Service (RDS)
resource "aws_db_instance" "main" {
  identifier             = "my-rds-instance"
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  db_name                = "mydatabase"
  username               = "admin"
  password               = "password"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.eks_sg.id]
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
}

# Elastic Container Registry (ECR)
resource "aws_ecr_repository" "main" {
  name                 = "my-container-repo"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Route 53
resource "aws_route53_zone" "main" {
  name = "acme.co"
}

# DNS Records
resource "aws_route53_record" "alb_record" {
  zone_id = aws_route53_zone.main.id
  name    = "greeting-api.acme.co"
  type    = "A"
  ttl     = "300"
  records = [aws_lb.application.dns_name]
}
