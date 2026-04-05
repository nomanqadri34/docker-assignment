# AWS Terraform Deployment — Flask Backend + Express Frontend

**Student Assignment** | Docker, AWS, Terraform  
A full-stack student registration app (Flask + Express) deployed across three configurations on AWS.

---

## 📁 Repository Structure

```
docker-assignment/
├── backend/                          # Flask REST API (Python)
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/                         # Express frontend (Node.js + EJS)
│   ├── server.js
│   ├── package.json
│   ├── views/
│   └── Dockerfile
├── docker-compose.yml                # Local development
└── terraform/
    ├── backend-bootstrap/            # S3 + DynamoDB state backend (run first)
    │   └── main.tf
    ├── part1-single-ec2/             # Part 1 — single EC2
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── user_data.sh
    ├── part2-separate-ec2/           # Part 2 — two EC2 instances
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── flask_userdata.sh
    │   └── express_userdata.sh
    └── part3-ecs-fargate/            # Part 3 — ECS Fargate + ECR + ALB
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── push-to-ecr.sh
```

---

## ⚙️ Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| AWS CLI | v2+ | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| Terraform | v1.3+ | [terraform.io](https://developer.hashicorp.com/terraform/downloads) |
| Docker | 24+ | [docker.com](https://www.docker.com/products/docker-desktop/) |
| Git | any | [git-scm.com](https://git-scm.com/) |

**AWS Configuration:**
```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output (json)
```

**Create EC2 Key Pair** (for Parts 1 & 2):
```bash
aws ec2 create-key-pair \
  --key-name docker-assignment-key \
  --query 'KeyMaterial' \
  --output text > docker-assignment-key.pem

chmod 400 docker-assignment-key.pem
```

---

## 🗄️ Step 0 — Bootstrap Terraform Remote State (Run Once)

Before deploying any part, create the shared S3 + DynamoDB backend:

```bash
cd terraform/backend-bootstrap
terraform init
terraform plan
terraform apply -auto-approve
```

**What this creates:**
- S3 bucket: `docker-assignment-tfstate` (versioned + encrypted)
- DynamoDB table: `terraform-lock` (state locking)

---

## 🟢 Part 1 — Both Apps on a Single EC2 Instance

### Architecture
```
Internet
   │
   ▼
EC2 (Ubuntu 22.04 — t2.micro)
   ├── Flask Backend  :5000  (PM2 process)
   └── Express Frontend :3000  (PM2 process)
```

### Resources Created
- Security Group (ports 22, 3000, 5000)
- EC2 Instance with Cloud-Init user data
- PM2 process manager (auto-restart on crash/reboot)

### Deploy

```bash
cd terraform/part1-single-ec2
terraform init
terraform plan
terraform apply
```

### Expected Output
```
instance_public_ip = "54.x.x.x"
flask_url          = "http://54.x.x.x:5000"
express_url        = "http://54.x.x.x:3000"
ssh_command        = "ssh -i docker-assignment-key.pem ubuntu@54.x.x.x"
```

### Verify
```bash
# Health check Flask
curl http://54.x.x.x:5000/health
# → {"status":"ok"}

# Open Express frontend in browser
open http://54.x.x.x:3000

# SSH and check PM2 processes
ssh -i docker-assignment-key.pem ubuntu@54.x.x.x
pm2 list
pm2 logs
```

### Destroy
```bash
terraform destroy -auto-approve
```

---

## 🔵 Part 2 — Flask and Express on Separate EC2 Instances

### Architecture
```
Internet
   │
   ├──► Express EC2 (Subnet B) :3000
   │         │  FLASK_URL=http://<private-ip>:5000
   │         ▼  (internal VPC traffic)
   └──► Flask EC2   (Subnet A) :5000
```

### Resources Created
- **VPC** (`10.0.0.0/16`) with 2 public subnets across 2 AZs
- **Internet Gateway** + Route Tables
- **2 Security Groups** (Flask SG allows 5000 from Express SG)
- **2 EC2 Instances** (Flask in subnet-a, Express in subnet-b)
- **Systemd services** for auto-restart

### Deploy

```bash
cd terraform/part2-separate-ec2
terraform init
terraform plan
terraform apply
```

### Expected Output
```
flask_public_ip   = "54.x.x.x"
express_public_ip = "3.y.y.y"
flask_url         = "http://54.x.x.x:5000"
express_url       = "http://3.y.y.y:3000"
flask_health_check = "http://54.x.x.x:5000/health"
```

### Verify
```bash
# Flask health check (public)
curl http://54.x.x.x:5000/health

# Express frontend (reaches Flask via private IP internally)
open http://3.y.y.y:3000

# Check Flask systemd service
ssh -i docker-assignment-key.pem ubuntu@54.x.x.x
sudo systemctl status flask-backend
sudo journalctl -u flask-backend -n 50

# Check Express systemd service
ssh -i docker-assignment-key.pem ubuntu@3.y.y.y
sudo systemctl status express-frontend
sudo journalctl -u express-frontend -n 50
```

### Security Group Flow
```
Internet ──► express_sg (3000/tcp) ──► Express EC2
Express EC2 ──► flask_sg (5000/tcp, source: express_sg) ──► Flask EC2
```

### Destroy
```bash
terraform destroy -auto-approve
```

---

## 🟣 Part 3 — Docker on ECS Fargate with ECR + ALB

### Architecture
```
Internet
   │
   ▼  port 80
Application Load Balancer (ALB)
   │
   ├────── /api/* ──────► ECS Service: Flask  (Fargate) :5000
   │                       (ECR: docker-assignment-flask-backend)
   │
   └────── /* ──────────► ECS Service: Express (Fargate) :3000
                           (ECR: docker-assignment-express-frontend)
```

### Resources Created
| Resource | Count | Detail |
|----------|-------|--------|
| ECR Repositories | 2 | flask-backend, express-frontend |
| VPC | 1 | 10.0.0.0/16 |
| Public Subnets | 2 | Multi-AZ |
| Internet Gateway | 1 | |
| Security Groups | 3 | ALB, flask-sg, express-sg |
| IAM Role | 1 | ECS Task Execution |
| CloudWatch Log Groups | 2 | 7-day retention |
| ECS Cluster | 1 | Container Insights enabled |
| ECS Task Definitions | 2 | |
| ECS Services | 2 | Fargate launch type |
| ALB | 1 | |
| Target Groups | 2 | |
| ALB Listener Rules | 2 | Path-based routing |

### Step 1 — Deploy Infrastructure

```bash
cd terraform/part3-ecs-fargate
terraform init
terraform plan
terraform apply
```

### Step 2 — Push Docker Images to ECR

```bash
# From project root (where backend/ and frontend/ folders live)
chmod +x terraform/part3-ecs-fargate/push-to-ecr.sh
./terraform/part3-ecs-fargate/push-to-ecr.sh us-east-1
```

**What this does:**
1. Authenticates Docker to ECR
2. Builds `backend/Dockerfile` → pushes to ECR flask repo
3. Builds `frontend/Dockerfile` → pushes to ECR express repo

### Step 3 — Force ECS to Pull New Images

```bash
aws ecs update-service \
  --cluster docker-assignment-cluster \
  --service docker-assignment-flask-service \
  --force-new-deployment \
  --region us-east-1

aws ecs update-service \
  --cluster docker-assignment-cluster \
  --service docker-assignment-express-service \
  --force-new-deployment \
  --region us-east-1
```

### Expected Output
```
ecr_flask_url   = "123456789.dkr.ecr.us-east-1.amazonaws.com/docker-assignment-flask-backend"
ecr_express_url = "123456789.dkr.ecr.us-east-1.amazonaws.com/docker-assignment-express-frontend"
alb_dns_name    = "docker-assignment-alb-123456.us-east-1.elb.amazonaws.com"
frontend_url    = "http://docker-assignment-alb-123456.us-east-1.elb.amazonaws.com"
flask_api_url   = "http://docker-assignment-alb-123456.us-east-1.elb.amazonaws.com/api"
flask_health_url = "http://docker-assignment-alb-123456.us-east-1.elb.amazonaws.com/health"
```

### Verify
```bash
# Flask health check (via ALB)
curl http://<alb-dns-name>/health
# → {"status":"ok"}

# Flask submit endpoint
curl -X POST http://<alb-dns-name>/submit \
  -H "Content-Type: application/json" \
  -d '{"name":"John","student_id":"S001","email":"j@uni.edu","course":"CS","grade":"A"}'

# Express frontend
open http://<alb-dns-name>

# Check ECS task status
aws ecs describe-services \
  --cluster docker-assignment-cluster \
  --services docker-assignment-flask-service docker-assignment-express-service \
  --region us-east-1

# View CloudWatch logs
aws logs tail /ecs/docker-assignment/flask-backend --follow
aws logs tail /ecs/docker-assignment/express-frontend --follow
```

### Destroy
```bash
terraform destroy -auto-approve
```

---

## 🚀 Local Development

Run both apps locally with Docker Compose:

```bash
# Build and start
docker compose up --build

# Access
# Express frontend: http://localhost:3000
# Flask backend:    http://localhost:5000/health

# Stop
docker compose down
```

---

## 🔑 General Requirements Checklist

| Requirement | Status |
|------------|--------|
| `variables.tf` in all parts | ✅ |
| `outputs.tf` in all parts | ✅ |
| S3 remote state backend | ✅ |
| DynamoDB state locking | ✅ |
| `terraform plan` before apply | ✅ |
| Security groups with least privilege | ✅ |
| User data / Cloud-Init automation | ✅ |
| ECR repositories for Docker images | ✅ |
| ECS Fargate cluster + services | ✅ |
| ALB with path-based routing | ✅ |
| CloudWatch logs for ECS | ✅ |
| Resource tagging | ✅ |

---

## 🌐 API Reference

### Flask Backend Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check → `{"status":"ok"}` |
| `POST` | `/submit` | Submit student registration |

**Sample POST `/submit`:**
```json
{
  "name": "John Doe",
  "student_id": "S12345",
  "email": "john@uni.edu",
  "course": "Computer Science",
  "grade": "A"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Student 'John Doe' submitted successfully!",
  "data": {
    "name": "John Doe",
    "student_id": "S12345",
    "email": "john@uni.edu",
    "course": "Computer Science",
    "grade": "A",
    "grade_status": "Excellent"
  }
}
```

---

## 👤 Author

**Mohammad Noman Qadri**  
Docker + AWS + Terraform Assignment  
GitHub: [nomanqadri34/docker-assignment](https://github.com/nomanqadri34/docker-assignment)
