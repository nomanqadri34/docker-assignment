# 🎓 Docker & AWS Deployment Assignment — Final Submission

This document contains the complete summary and live URLs for all three deployment methods required for this assignment.

---

## 1️⃣ Question 1: Single EC2 Deployment (Docker Compose)
**Objective**: Deploy the Flask backend and Express frontend in a single Amazon EC2 instance.

* **Architecture**: Both the Frontend and Backend run on the same ubuntu instance (`3.253.195.102`). They are orchestrated using `docker-compose`, which automatically builds and connects them via a shared internal bridge network.
* **Security & Proxy**: An Nginx container sits in front of the application, handling Port 80 and Port 443 (HTTPS) with a self-signed certificate. It acts as a reverse proxy to route traffic securely to the internal Express container.
* **Live App URL**: 👉 **[https://3.253.195.102/](https://3.253.195.102/)** *(Accept the self-signed certificate warning to view).*
* **Documentation**: See `DEPLOYMENT.md` for full steps.

---

## 2️⃣ Question 2: Separate EC2 Instances
**Objective**: Deploy the Flask backend and Express frontend in separate EC2 instances.

* **Architecture**: The application is distributed across two physically separate servers to ensure independent scaling and security.
  * **Frontend EC2** (`3.253.195.102`): Runs the Node/Express container on Port 3001. Publicly accessible.
  * **Backend EC2** (`54.74.9.47`): Runs the Python/Flask container on Port 5000. It receives API calls from the frontend server.
* **Security**: The backend server requires a custom Security Group Rule (Custom TCP, Port 5000) so the frontend can securely POST data to it.
* **Live App URL (Frontend)**: 👉 **[http://3.253.195.102:3001/](http://3.253.195.102:3001/)**
* **Live API URL (Backend Health Check)**: 👉 **[http://54.74.9.47:5000/health](http://54.74.9.47:5000/health)** 
* **Documentation & Scripts**: See `DEPLOYMENT_Q2.md`, `q2-backend-setup.sh`, and `q2-frontend-setup.sh`.

---

## 3️⃣ Question 3: AWS Fully Managed Container Service (ECR + ECS)
**Objective**: Deploy the Docker Containers using AWS ECR, ECS, and VPC services.

* **Architecture**: A fully managed, serverless approach eliminating the need to SSH into raw EC2 instances.
  * **AWS ECR (Elastic Container Registry)**: We created private image repositories (`docker-assignment-backend` and `docker-assignment-frontend`) and securely pushed the built Docker images to them.
  * **AWS ECS (Fargate)**: We defined "Task Definitions" (`flask-backend-task` and `express-frontend-task`) which instruct AWS on how much CPU/Memory to allocate to each container. These tasks are launched into the `docker-assignment-cluster`.
  * **VPC**: The containers execute within the default AWS Virtual Private Cloud, restricting networking at the subnet level.
* **Live URLs**: *(Deployment of the final ECS Services is done via AWS Console pointing to an Application Load Balancer (ALB). Access is provided through the ALB's DNS string).*
* **Documentation & Automation**: See `DEPLOYMENT_Q3.md` and the `automated-q3-deploy.sh` script which handled the AWS API automated provisioning.

#### 🔎 Deployment Proof (AWS API Output)
During automated deployment, the AWS services were verified to be created actively in the `eu-west-1` region under AWS Account `007977988656`.

**ECS Cluster Target ARN**:
```json
{
    "clusterArn": "arn:aws:ecs:eu-west-1:007977988656:cluster/docker-assignment-cluster",
    "clusterName": "docker-assignment-cluster",
    "status": "ACTIVE"
}
```

**ECS Task Definitions Successfully Registered**:
- `arn:aws:ecs:eu-west-1:007977988656:task-definition/flask-backend-task:1`
- `arn:aws:ecs:eu-west-1:007977988656:task-definition/express-frontend-task:1`

**ECR Repositories Created Successfully**:
- `007977988656.dkr.ecr.eu-west-1.amazonaws.com/docker-assignment-backend`
- `007977988656.dkr.ecr.eu-west-1.amazonaws.com/docker-assignment-frontend`

#### 📸 Deployment Screenshots
Here is the visual proof of the automated AWS deployment script executing on the EC2 server and provisioning the infrastructure:

<div align="center">
  <img src="./new/Screenshot%202026-04-03%20004858.png" width="800" alt="Deployment Screenshot 1" />
  <br/><br/>
  <img src="./new/Screenshot%202026-04-03%20004905.png" width="800" alt="Deployment Screenshot 2" />
  <br/><br/>
  <img src="./new/Screenshot%202026-04-03%20004913.png" width="800" alt="Deployment Screenshot 3" />
  <br/><br/>
  <img src="./new/Screenshot%202026-04-03%20004920.png" width="800" alt="Deployment Screenshot 4" />
  <br/><br/>
  <img src="./new/Screenshot%202026-04-03%20004927.png" width="800" alt="Deployment Screenshot 5" />
  <br/><br/>
  <img src="./new/Screenshot%202026-04-03%20004935.png" width="800" alt="Deployment Screenshot 6" />
</div>

---
**Submission Notice**: To avoid unexpected AWS charges, all EC2 Instances and ECS Clusters will be stopped/deleted after grading.
