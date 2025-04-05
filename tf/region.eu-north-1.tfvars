# provider variables
region = "eu-north-1"

# vpc variables
vpc_name       = "OrderAppVpc"
cidr           = "10.0.0.0/16"
azs            = ["eu-north-1a", "eu-north-1b"]
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

# RdsSecurityGroup variables
Rds_security_group_name = "RdsSecurityGroup"
Rds_port                = 3306
Rds_ingress_cidr_blocks = ["0.0.0.0/0"]
Rds_egress_cidr_blocks  = ["0.0.0.0/0"]

# OrderAppSubnetGroup variables
db_subnet_group_name = "orderapp-subnet-group"

# aws_db_instance variables
db_instance_identifier = "mydb"
db_name                = "OrderAppDatabase"
db_username            = "admin"
db_password            = "0542271009"
allocated_storage      = 20
storage_type           = "gp2"
engine                 = "mysql"
engine_version         = "8.0.40"
instance_class         = "db.t3.micro"
parameter_group_name   = "default.mysql8.0"
multi_az               = false
publicly_accessible    = true
skip_final_snapshot    = true

# ALB Security Group variables
alb_sg_name             = "alb_OrderApp_sg"
alb_ingress_ports       = [443, 80, 3000]
alb_ingress_cidr_blocks = ["0.0.0.0/0"]
alb_egress_cidr_blocks  = ["0.0.0.0/0"]

# LoadBalancer variables
alb_name               = "orderappalb"
alb_internal           = false
alb_load_balancer_type = "application"

# Target Group variables
target_group_name     = "orderapptargetgroup"
target_group_port     = 3000
target_group_protocol = "HTTP"

# aws_acm_certificate variables
domain_name               = "shachar.online"
subject_alternative_names = ["*.shachar.online"]

# aws_lb_listener variables
lb_listener_port     = 3000
lb_listener_protocol = "HTTPS"
ssl_policy           = "ELBSecurityPolicy-2016-08"

# EC2 Security Group variables
EC2_sg_name            = "InstansSecurityGroup"
sg_ingress_ports       = [22, 3000, 80, 443]
sg_ingress_cidr_blocks = ["0.0.0.0/0"]
sg_egress_cidr_blocks  = ["0.0.0.0/0"]

# aws_instance variables
ami           = "ami-0c1ac8a41498c1a9c"
instance_type = "t3.micro"
key_name      = "ServerKeyPair"
instance_name = "AppOrderServer"