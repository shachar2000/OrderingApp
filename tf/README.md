# Terraform AWS Infrastructure for OrderApp

This Terraform configuration deploys a complete AWS infrastructure for the **OrderApp** application. It includes VPC setup, S3 bucket configuration, RDS database instance, EC2 instances, Application Load Balancer (ALB), security groups, and ACM certificate with DNS validation.

---

## Features

- **VPC module** with public subnets across multiple availability zones
- **S3 bucket** configured for Flutter app builds with proper public access policies
- **RDS instance** with subnet group and security groups for secure database access
- **Application Load Balancer** with target groups and HTTPS listener using ACM certificates
- **EC2 instances** deployed across AZs with security groups and public IPs
- **Security groups** for RDS, ALB, EC2, and monitoring tools
- **Route53 DNS records** for domain and ACM certificate validation

---

## Prerequisites

- Terraform >= 1.7.0
- AWS CLI configured with appropriate credentials (profile named `default`)
- An existing Route53 Hosted Zone matching your domain name
- AWS S3 bucket for storing Terraform state (`shachar-terraform-bucket` in `eu-north-1` region)
- Domain name and ACM certificate validation setup

---

## Variables

The configuration relies on the following variables (you should define them in a `terraform.tfvars` or via other variable files):

- `region` - AWS region (e.g., `eu-north-1`)
- `vpc_name` - Name for the VPC
- `cidr` - CIDR block for the VPC
- `azs` - List of Availability Zones (e.g., `["eu-north-1a", "eu-north-1b"]`)
- `public_subnets` - List of CIDRs for public subnets
- RDS related variables:  
  `Rds_security_group_name`, `Rds_port`, `Rds_ingress_cidr_blocks`, `Rds_egress_cidr_blocks`, `db_subnet_group_name`, `db_instance_identifier`, `db_name`, `db_username`, `db_password`, `allocated_storage`, `storage_type`, `engine`, `engine_version`, `instance_class`, `parameter_group_name`, `multi_az`, `publicly_accessible`, `skip_final_snapshot`
- ALB related variables:  
`alb_sg_name`, `alb_ingress_ports`, `alb_ingress_cidr_blocks`, `alb_egress_cidr_blocks`, `alb_name`, `alb_internal`, `alb_load_balancer_type`, `target_group_name`, `target_group_port`, `target_group_protocol`, `lb_listener_port`, `lb_listener_protocol`, `ssl_policy`, `domain_name`, `subject_alternative_names`
- EC2 related variables such as `EC2_sg_name`, `ami`, `instance_type`, `key_name`, `sg_ingress_cidr_blocks`, `sg_ingress_ports`, `sg_egress_cidr_blocks`, `instance_name`
- Any other variables used in the script

---

## How to Use

1. **Initialize Terraform:**

   ```bash
   terraform init

2. **Check the execution plan:**

   ```bash
   terraform plan -var-file="terraform.tfvars"

2. **Apply the configuration:**

   ```bash
   terraform apply -var-file="terraform.tfvars"


2. **Destroy the infrastructure:**

   ```bash
   terraform destroy -var-file="terraform.tfvars"

