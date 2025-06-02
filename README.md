# OrderApp - Complete Ordering System Project

OrderApp is a microservices-based ordering system leveraging cloud technologies, featuring a cross-platform Flutter app, a powerful Node.js server, secure AWS infrastructure, and advanced monitoring and logging tools.

---

## Project Structure

The project is divided into several main components, each serving a key role:

### 1. my-server  
A Node.js server using Express to manage users and orders, including:  
- API with JWT authentication and authorization  
- MySQL database hosted on AWS RDS  
- Logging management with Winston  
- Integration with Prometheus for monitoring  

### 2. ordivo  
A cross-platform Flutter app (Android, iOS, Linux, Windows, macOS, Web):  
- Login and registration screens  
- Order display and management actions  
- Automated build and deployment with GitHub Actions to AWS S3  

### 3. tf (Terraform)  
Infrastructure as Code for provisioning and managing AWS resources:  
- Creating VPC, RDS, EC2, ALB, S3, and more  
- Network and security configurations  
- Management with secret variable files  

### 4. ansible  
Automation tool for server and container service deployment:  
- Installing Docker and deploying OrderAppServer containers  
- Installing node_exporter and Logstash for monitoring and logging  
- Dynamic updating of configuration files according to IP addresses  

### 5. prometheus-grafana  
Monitoring system for services and servers:  
- Deploying Prometheus and Grafana with ready dashboards  
- Modern and user-friendly real-time monitoring interface  

### 6. elasticsearch-kibana  
Log collection and monitoring system for development environments:  
- Elasticsearch + Kibana with Docker Compose  
- Interactive log viewing, searching, and analysis capabilities  

---

## CI/CD – GitHub Actions

The project uses GitHub Actions for automation of:  
- Building Docker images and pushing them to Docker Hub  
- Deploying AWS infrastructure with Terraform and running Ansible  
- Building the Flutter app and deploying it to AWS S3  

---

## Secrets and Environment Setup

To run the project, set the following secrets in your GitHub repository settings:  
- `DOCKER_HUB_PASSWORD`  
- `AWS_ACCESS_KEY_ID`  
- `AWS_SECRET_ACCESS_KEY`  
- `AWS_SECRET_REGION`  
- `TFVARS_SECRET`  (example in .github/workflows/README.md)
- `SECRET_KEY` (secret key used to sign and verify JWT tokens for authentication)
- `KEY_PEM`  (your instance key pair from AWS)

Additionally, ensure you have a valid Hosted Zone with an active domain configured in AWS Route 53 to allow the system to operate with the correct domain.

---

## Quick Start

1. **Clone the repository:**  
```bash
git clone https://github.com/shachar2000/OrderingApp.git
cd OrderApp
```

2. **Make sure all required environment variables and secrets are configured in GitHub, and that a valid Hosted Zone with an active domain is set up in AWS Route 53.**


3. **Commit and push your changes to the main branch:**  
```bash
git add .
git commit -m "Your commit message"
git push origin main
```
---

## Running and Managing Individual Components Independently
Each component can be run and managed independently depending on your needs:

- my-server: Node.js backend server

- ordivo: Flutter cross-platform app

- tf: AWS infrastructure provisioning with Terraform

- ansible: Configuration management and deployment automation

- prometheus-grafana: Monitoring stack

- elasticsearch-kibana: Logging stack

Each folder contains its own README file with detailed instructions for usage and management of that specific component.




