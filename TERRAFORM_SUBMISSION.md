# AWS & Terraform Full-Stack Deployment Assignment

This document outlines the provisioning and deployment of the Flask backend and Express frontend across three different AWS topologies using infrastructure as code (Terraform).

---

## Part 1: Deploy Both Flask and Express on a Single EC2 Instance

### Objective
Provision a single EC2 instance using Terraform. A user data Cloud-Init script automatically configures the server, installs Node.js and Python dependencies, and deploys both the Flask API (port 5000) and the Express Frontend (port 3000) simultaneously. 

### Commands Executed
```powershell
cd terraform/part1-single-ec2
terraform init
terraform plan
terraform apply -auto-approve
```

### Execution & Verification Screenshots
<img src="teraform/Screenshot 2026-04-05 190634.png" width="800">
<img src="teraform/Screenshot 2026-04-05 190643.png" width="800">
<img src="teraform/Screenshot 2026-04-05 190650.png" width="800">
<img src="teraform/Screenshot 2026-04-05 190658.png" width="800">
<img src="teraform/Screenshot 2026-04-05 190710.png" width="800">
<img src="teraform/Screenshot 2026-04-05 190931.png" width="800">
<img src="teraform/Screenshot 2026-04-05 190938.png" width="800">
<img src="teraform/Screenshot 2026-04-05 190947.png" width="800">
<img src="teraform/Screenshot 2026-04-05 190955.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191001.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191008.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191017.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191023.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191029.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191042.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191051.png" width="800">

---

## Part 2: Deploy Flask and Express on Separate EC2 Instances

### Objective
Provision two isolated EC2 instances in a custom VPC using Terraform. One instance acts exclusively as the backend (Flask), and the other acts as the public frontend (Express). Security groups are configured to only allow the Express server to communicate with the Flask API via local port configurations.

### Commands Executed
```powershell
cd terraform/part2-separate-ec2
terraform init
terraform plan
terraform apply -auto-approve
```

### Execution & Verification Screenshots
<img src="teraform/Screenshot 2026-04-05 191338.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191345.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191353.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191405.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191415.png" width="800">
<img src="teraform/Screenshot 2026-04-05 191431.png" width="800">

---

## Part 3: Deploy Flask and Express Using Docker and AWS ECS Fargate

### Objective
A scalable, decoupled container architecture. Uses Terraform to create a VPC, two Elastic Container Registries (ECR), an Application Load Balancer (ALB), and an ECS Cluster. The backend and frontend are built into Docker images, pushed to AWS ECR, and then executed as Serverless Fargate tasks behind the ALB.

### Commands Executed
```powershell
cd terraform/part3-ecs-fargate
terraform init
terraform plan
terraform apply -auto-approve
```

### Execution & Verification Screenshots
<img src="teraform/Screenshot 2026-04-05 191942.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192053.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192101.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192108.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192120.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192128.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192135.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192147.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192155.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192203.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192216.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192224.png" width="800">
<img src="teraform/Screenshot 2026-04-05 192230.png" width="800">

