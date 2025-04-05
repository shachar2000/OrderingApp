# provider variables
variable "region" {
   description = "region"
   type        = string
}

# vpc variables
variable "vpc_name" {
   description = "vpc name"
   type        = string
}


variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
}


# RdsSecurityGroup variables
variable "Rds_security_group_name" {
  description = "The name of the security group"
  type        = string
}

variable "Rds_port" {
  description = "The port for RDS"
  type        = number
}

# aws_db_subnet_group variables
variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}

# aws_db_instance variables
variable "db_instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "The amount of storage to allocate for the RDS instance"
  type        = number
}

variable "storage_type" {
  description = "The storage type for the RDS instance"
  type        = string
}

variable "engine" {
  description = "The engine for the RDS instance"
  type        = string
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "parameter_group_name" {
  description = "The DB parameter group name"
  type        = string
}

variable "multi_az" {
  description = "Whether the RDS instance should be multi-az"
  type        = bool
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot before deleting the DB instance"
  type        = bool
}

# ALB Security Group variables
variable "alb_sg_name" {
  description = "The name of the Security Group for the ALB"
  type        = string
}

variable "alb_ingress_ports" {
  description = "List of ingress ports for the ALB"
  type        = list(number)
}

# LoadBalancer variables
variable "alb_name" {
  description = "The name of the ALB"
  type        = string
}

variable "alb_internal" {
  description = "Whether the ALB is internal or not"
  type        = bool
}

variable "alb_load_balancer_type" {
  description = "The type of load balancer (application or network)"
  type        = string
}

# Target Group variables
variable "target_group_name" {
  description = "The name of the Target Group"
  type        = string
}

variable "target_group_port" {
  description = "The port on which the Target Group listens"
  type        = number
}

variable "target_group_protocol" {
  description = "The protocol for the Target Group (HTTP, HTTPS, etc.)"
  type        = string
}

# aws_acm_certificate variables
variable "domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
}

# aws_lb_listener variables
variable "lb_listener_port" {
  description = "The port on which the ALB listener listens"
  type        = number
}

variable "lb_listener_protocol" {
  description = "The protocol for the ALB listener"
  type        = string
}

variable "ssl_policy" {
  description = "The SSL policy for the ALB listener"
  type        = string
}

# EC2 Security Group variables
variable "EC2_sg_name" {
  description = "The name of the Security Group for the ALB"
  type        = string
}

variable "sg_ingress_ports" {
  description = "List of ingress ports for the ALB"
  type        = list(number)
}

# aws_instance variables
variable "ami" {
  description = "The AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type"
  type        = string
}

variable "key_name" {
  description = "The key name for the instance"
  type        = string
}

variable "instance_name" {
  description = "The name tag for the instance"
  type        = string
}


