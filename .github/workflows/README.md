# Project CI/CD Workflows

This repository contains GitHub Actions workflows for building, deploying, and managing infrastructure and applications.

---

## 1. Build And Push Docker Image

This workflow triggers on push to the `main` branch and changes under the `my-server/` directory.  
It performs the following steps:  
- Checks out the repository code  
- Logs in to Docker Hub using secrets  
- Builds a Docker image from the `my-server` directory  
- Tags the image and pushes it to Docker Hub  

---

## 2. Infrastructure Deployment

This workflow triggers on push to the `main` branch.  
It performs the following tasks:  
- Checks out the repository code  
- Installs Terraform on the runner  
- Configures AWS CLI with secrets  
- Creates a `.tfvars` file using a secret  
- Applies Terraform to create the infrastructure  
- Extracts IP addresses and sensitive information from Terraform output and masks them  
- Creates an Ansible inventory file dynamically  
- Installs Ansible on the runner  
- Replaces Elasticsearch IP in Logstash config file  
- Runs Ansible playbook on created EC2 instances using a private key  
- Updates Prometheus config with the new IPs using `yq`  
- Copies Prometheus-Grafana and Elasticsearch-Kibana directories to the Prometheus-Grafana EC2 instance  
- Runs Docker Compose on the Prometheus-Grafana EC2 instance for both Prometheus-Grafana and Elasticsearch-Kibana  
- Waits for Kibana to become available  
- Imports Kibana index patterns  

---

## 3. Build & Upload Flutter App to S3

This workflow runs after the successful completion of the Infrastructure Deployment workflow.  
Steps include:  
- Checkout code  
- Set up Flutter environment  
- Install dependencies needed for building the app  
- Generate app icons  
- Build the APK for Android release  
- Build the Linux release version  
- Zip the Linux build folder  
- Configure AWS CLI with secrets  
- Upload the Android APK and Linux zipped build to a specified S3 bucket  

---

## Required GitHub Secrets

Make sure to add the following secrets in your GitHub repository settings:

- `DOCKER_HUB_PASSWORD` – Your Docker Hub password  
- `AWS_ACCESS_KEY_ID` – Your AWS access key  
- `AWS_SECRET_ACCESS_KEY` – Your AWS secret key  
- `AWS_SECRET_REGION` – AWS region (e.g., `eu-north-1`)  
- `TFVARS_SECRET` – The content of your `.tfvars` file (see example below)  
- `SECRET_KEY` – Your application secret  
- `KEY_PEM` – Your private SSH key for Ansible (PEM format)  

---

## Example Format for `TFVARS_SECRET`

Use this format **exactly** (with escaped quotes `\"`) in the `TFVARS_SECRET` secret to prevent GitHub from stripping quotes:

```hcl
# provider variables
region = \"eu-north-1\"

# vpc variables
vpc_name       = \"OrderAppVpc\"
cidr           = \"10.0.0.0/16\"
azs            = [\"eu-north-1a\", \"eu-north-1b\"]
public_subnets = [\"10.0.1.0/24\", \"10.0.2.0/24\"]

# RdsSecurityGroup variables
Rds_security_group_name = \"RdsSecurityGroup\"
Rds_port                = 3306
Rds_ingress_cidr_blocks = [\"0.0.0.0/0\"]
Rds_egress_cidr_blocks  = [\"0.0.0.0/0\"]

# OrderAppSubnetGroup variables
db_subnet_group_name = \"orderapp-subnet-group\"

# aws_db_instance variables
db_instance_identifier = \"mydb\"
db_name                = \"OrderAppDatabase\"
db_username            = \"admin\"
db_password            = \"REPLACE_WITH_STRONG_PASSWORD\"
allocated_storage      = 20
storage_type           = \"gp2\"
engine                 = \"mysql\"
engine_version         = \"8.0.40\"
instance_class         = \"db.t3.micro\"
parameter_group_name   = \"default.mysql8.0\"
multi_az               = false
publicly_accessible    = true
skip_final_snapshot    = true

# ALB Security Group variables
alb_sg_name             = \"alb_OrderApp_sg\"
alb_ingress_ports       = [443, 80, 3000]
alb_ingress_cidr_blocks = [\"0.0.0.0/0\"]
alb_egress_cidr_blocks  = [\"0.0.0.0/0\"]

# LoadBalancer variables
alb_name               = \"orderappalb\"
alb_internal           = false
alb_load_balancer_type = \"application\"

# Target Group variables
target_group_name     = \"orderapptargetgroup\"
target_group_port     = 3000
target_group_protocol = \"HTTP\"

# aws_acm_certificate variables
domain_name               = \"your-domain-name\"
subject_alternative_names = [\"*.your-domain-name\"]

# aws_lb_listener variables
lb_listener_port     = 3000
lb_listener_protocol = \"HTTPS\"
ssl_policy           = \"ELBSecurityPolicy-2016-08\"

# EC2 Security Group variables
EC2_sg_name            = \"InstansSecurityGroup\"
sg_ingress_ports       = [22, 3000, 80, 443]
sg_ingress_cidr_blocks = [\"0.0.0.0/0\"]
sg_egress_cidr_blocks  = [\"0.0.0.0/0\"]

# aws_instance variables
ami           = \"ami-0c1ac8a41498c1a9c\"
instance_type = \"t3.medium\"
key_name      = \"your-key-name\"
instance_name = \"AppOrderServer\"
