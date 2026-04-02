# 🚀 AWS Deployment Guide — Method 3 (ECR + ECS + VPC)

This document explains the fully managed AWS containerized deployment of the project, completely eliminating the need to manage EC2 servers manually.

---

## 🏗️ Architecture Stack

| Component | AWS Service | Role |
| :--- | :--- | :--- |
| **Image Registry** | **Amazon ECR** | Stores the Docker Images privately (`flask-backend` & `express-frontend`). |
| **Orchestration** | **Amazon ECS** | Manages running containers. We use the **Fargate** launch type (serverless compute). |
| **Network** | **Amazon VPC** | Isolated private network with security groups restricting traffic. |
| **Load Balancing** | **ALB** | Application Load Balancer routes port 80 traffic to the ECS frontend tasks. |

## 🛠️ Deployment Steps Taken

### Phase 1: Build & Push Images to ECR
1. Created two private repositories in **Elastic Container Registry (ECR)**:
   - `docker-assignment-frontend`
   - `docker-assignment-backend`
2. Authenticated Docker with AWS CLI.
3. Built the images locally tagging them with the ECR URI.
4. Pushed the images to AWS.

*(We provide a `q3-ecr-push.sh` script to automate this step)*.

### Phase 2: Create the VPC & Load Balancer
1. Created a custom **VPC** (or used default) with at least 2 **Public Subnets** in different Availability Zones.
2. Created an **Application Load Balancer (ALB)** listening on Port 80.
3. Created a **Target Group** (Port 3000, target type: IP) for the frontend containers.

### Phase 3: Create ECS Cluster & Task Definitions
1. Created an **ECS Cluster** (Networking only cluster for Fargate).
2. Defined a **Task Definition** for the Backend:
   - Contains 1 container: the Python Flask backend image from ECR.
   - Port Mapping: 5000.
3. Defined a **Task Definition** for the Frontend:
   - Contains 1 container: the Node Express frontend image from ECR.
   - Environment Variable injected: `FLASK_URL = http://<backend-private-ip>:5000`
   - Port Mapping: 3000.

*(We provide sample ECS Task JSON config files in `/ecs` folder).*

### Phase 4: Run ECS Services
1. Deployed the **Backend ECS Service**:
   - Security Group: Allow TCP 5000 **only** from the VPC.
2. Kept note of the Backend ENI Private IP (e.g., `172.31.x.y`).
3. Deployed the **Frontend ECS Service**:
   - Updated the task definition `FLASK_URL` to point to the backend's private IP.
   - Security Group: Allow TCP 80 from anywhere (if no ALB) OR allow TCP 3000 only from the ALB.
   - Registered the service with the Load Balancer Target Group.

---

## 💻 How to access
Once ECS shows tasks as `RUNNING`, the app is accessed via the **ALB DNS Name** (or the Public IP of the frontend Fargate task if ALB is skipped for cost/simplicity).

**Result URL Structure:**
```
http://<your-load-balancer-random-string>.us-east-1.elb.amazonaws.com/
```

---

## 👨‍💻 Submission Notes
To cleanly tear down this deployment and stop costs:
1. Delete the ECS Services (Setting tasks to 0).
2. Delete the ALB and Target Groups.
3. Delete the ECR images.
