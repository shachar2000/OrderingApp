terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }

  backend "s3" {
    bucket = "shachar-terraform-bucket"
    key    = "tfstate.json"
    region = "eu-north-1"
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region  = var.region
  profile = "default"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
}

resource "aws_security_group" "RdsSecurityGroup" {
  name        = var.Rds_security_group_name
  description = "Security group for OrderApp RDS instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = var.Rds_port
    to_port     = var.Rds_port
    protocol    = "tcp"
    cidr_blocks = var.Rds_ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.Rds_egress_cidr_blocks
  }
}

# יצירת DB Subnet Group עם ה-subnet IDs מה-VPC
resource "aws_db_subnet_group" "OrderAppSubnetGroup" {
  name       = var.db_subnet_group_name
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "DB Subnet Group"
  }
}

resource "aws_db_instance" "OrderAppRds" {
  identifier           = var.db_instance_identifier
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  parameter_group_name = var.parameter_group_name
  multi_az             = var.multi_az
  publicly_accessible  = var.publicly_accessible
  skip_final_snapshot  = var.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.RdsSecurityGroup.id]
  db_subnet_group_name  = aws_db_subnet_group.OrderAppSubnetGroup.name  # קישור ל-DB Subnet Group
}

output "rds_endpoint" {
  value = aws_db_instance.OrderAppRds.endpoint
  sensitive = true
}

resource "aws_security_group" "alb_OrderApp_sg" {
  name        = var.alb_sg_name
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = var.alb_ingress_ports[0]
    to_port     = var.alb_ingress_ports[0]
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  ingress {
    from_port   = var.alb_ingress_ports[1]
    to_port     = var.alb_ingress_ports[1]
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  ingress {
    from_port   = var.alb_ingress_ports[2]
    to_port     = var.alb_ingress_ports[2]
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.alb_egress_cidr_blocks
  }
}

resource "aws_lb" "OrderApp_alb" {
  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = var.alb_load_balancer_type
  security_groups    = [aws_security_group.alb_OrderApp_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "OrderApp_target_group" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

resource "aws_acm_certificate" "certificate_manager" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  subject_alternative_names = var.subject_alternative_names
}

resource "aws_route53_record" "cert_validation_record1" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name     = tolist(aws_acm_certificate.certificate_manager.domain_validation_options)[0].resource_record_name
  type     = tolist(aws_acm_certificate.certificate_manager.domain_validation_options)[0].resource_record_type
  ttl      = 60

  records = [tolist(aws_acm_certificate.certificate_manager.domain_validation_options)[0].resource_record_value]
}

data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name     = var.domain_name
  type     = "A"

  alias {
    name                   = aws_lb.OrderApp_alb.dns_name
    zone_id                = aws_lb.OrderApp_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.OrderApp_alb.arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol

  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate.certificate_manager.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.OrderApp_target_group.arn
  }
}


resource "aws_security_group" "instance_sg" {
  name        = var.EC2_sg_name
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = var.sg_ingress_ports[0]
    to_port     = var.sg_ingress_ports[0]
    protocol    = "tcp"
    cidr_blocks = var.sg_ingress_cidr_blocks
  }

  ingress {
    from_port   = var.sg_ingress_ports[1]
    to_port     = var.sg_ingress_ports[1]
    protocol    = "tcp"
    cidr_blocks = var.sg_ingress_cidr_blocks
  }

  ingress {
    from_port              = var.sg_ingress_ports[2]
    to_port                = var.sg_ingress_ports[2]
    protocol               = "tcp"
    cidr_blocks = var.sg_ingress_cidr_blocks
  }

  ingress {
    from_port   = var.sg_ingress_ports[3]
    to_port     = var.sg_ingress_ports[3]
    protocol    = "tcp"
    cidr_blocks = var.sg_ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.sg_egress_cidr_blocks
  }
}

resource "aws_instance" "OrderAppServer1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  availability_zone      = var.azs[0]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  tags = {
    Name = var.instance_name
  }
}



output "OrderAppServer1_public_ip" {
  value = aws_instance.OrderAppServer1.public_ip
  sensitive = true
}

resource "aws_instance" "OrderAppServer2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  availability_zone      = var.azs[1]
  subnet_id              = module.vpc.public_subnets[1]
  associate_public_ip_address = true
  tags = {
    Name = var.instance_name
  }
}



output "OrderAppServer2_public_ip" {
  value = aws_instance.OrderAppServer2.public_ip
  sensitive = true
}

resource "aws_lb_target_group_attachment" "attachment1" {
  target_group_arn = aws_lb_target_group.OrderApp_target_group.arn
  target_id        = aws_instance.OrderAppServer1.id
  port             = var.target_group_port
}

resource "aws_lb_target_group_attachment" "attachment2" {
  target_group_arn = aws_lb_target_group.OrderApp_target_group.arn
  target_id        = aws_instance.OrderAppServer2.id
  port             = var.target_group_port
}

