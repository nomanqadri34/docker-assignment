# 🚀 AWS Deployment Guide — Method 2 (Separate EC2 Instances)

This document explains how to deploy the Flask backend and Express frontend onto two **separate** AWS EC2 instances. This demonstrates a distributed architecture.

---

## 🔗 Live Application URLs

Here are the live URLs for this specific deployment (Instance 1 & Instance 2):

- **Frontend Application (View in Browser)**: 👉 **[http://3.253.195.102:3001/](http://3.253.195.102:3001/)**
- **Backend API (Health Check)**: 👉 **[http://54.74.9.47:5000/health](http://54.74.9.47:5000/health)**

---

## 🏗️ Architecture

```text
Internet
   │
   ├──▶  EC2 #1 "Frontend Instance"  (3.253.195.102)
   │         └── Express App (Port 3001)
   │                    │  HTTP calls to Backend EC2
   │                    ▼
   └──▶  EC2 #2 "Backend Instance"   (54.74.9.47)
              └── Flask App (Port 5000)
```

**Key Advantages:**
- **Scaling:** If the backend gets heavy traffic, you can upgrade the Backend EC2 without touching the frontend.
- **Security:** The backend instance does not need to expose port 80/443 to the internet; it only needs to allow traffic from the Frontend instance.

---

## 🛠️ Step-by-Step Deployment Instructions

### 1. Launch Two EC2 Instances
Launch two **Ubuntu 24.04** instances in AWS (e.g., `t2.micro`):
1. **Frontend-EC2**: Security Group allows SSH (22), HTTP (80), and Custom TCP (3000) from Anywhere (0.0.0.0/0).
2. **Backend-EC2**: Security Group allows SSH (22) and Custom TCP (5000). For security, restrict Port 5000 source to the `Frontend-EC2`'s public IP (or Security Group ID).

### 2. Configure Backend EC2

SSH into the **Backend-EC2**:
```bash
ssh -i nomanqadri34.pem ubuntu@<BACKEND_PUBLIC_IP>
```

Copy and run the setup script (or run these commands):
```bash
# Update and install Docker
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu

# Clone/copy your project files here, then go to backend folder
# cd docker-assignment/backend

# Build the backend docker image
docker build -t flask-backend .

# Run the backend container on port 5000
docker run -d -p 5000:5000 --name backend-container --restart unless-stopped flask-backend
```
*(Alternatively, use the provided `q2-backend-setup.sh` script)*

Wait a few seconds, then verify it is running:
```bash
curl http://localhost:5000/health
# Should return: {"status": "ok"}
```

---

### 3. Configure Frontend EC2

SSH into the **Frontend-EC2**:
```bash
ssh -i nomanqadri34.pem ubuntu@<FRONTEND_PUBLIC_IP>
```

```bash
# Update and install Docker
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu

# Clone/copy your project files here, then go to frontend folder
# cd docker-assignment/frontend

# Note: You MUST pass the Backend's IP to the frontend container
export FLASK_URL=http://<BACKEND_PUBLIC_IP>:5000

# Build the frontend docker image
docker build -t express-frontend .

# Run the frontend container on port 3001 (mapping 3001 to container's 3000)
docker run -d -p 3001:3000 -e FLASK_URL=$FLASK_URL --name frontend-container --restart unless-stopped express-frontend
```
*(Alternatively, use the provided `q2-frontend-setup.sh` script)*

---

### 4. Verification

1. Go to your browser.
2. Enter the **Frontend EC2's Public IP** (`http://3.253.195.102:3001`).
3. You should see the registration form.
4. Fill out the form and submit. It will send a request from the frontend browser/server to your Backend EC2 (`54.74.9.47`) and display the success response!

---

## 👨‍💻 Submission Notes
For this method, the required deliverables are:
- Two running EC2 instances.
- Deployed App URL: `http://3.253.195.102:3001`
- After demonstrating/submitting, **Stop** both instances in the AWS Console to save costs.
