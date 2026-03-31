# 🚀 AWS Deployment Guide — Method 1 (Single EC2)

This document explains the full containerized deployment of the Student Registration application on a single AWS EC2 instance.

---

## 🔗 Live Deployment URL
👉 **[https://3.253.195.102/](https://3.253.195.102/)**

> [!WARNING]
> **Important Note on HTTPS / SSL**:
> When you visit the link above, your browser (Chrome, Edge, etc.) will show a **"Your connection is not private"** warning.
>
> **Why is this happening?**
> A secure (HTTPS) connection requires an SSL/TLS Certificate signed by a "Trusted Authority". However, trusted authorities **only issue certificates to domain names** (like `example.com`), never to bare IP addresses.
>
> **How we fixed it**:
> Since this project does not have a registered domain name, we generated a **Self-Signed Certificate**. 
> - **Encryption**: Your data is still 100% encrypted and secure.
> - **How to proceed**: Click **"Advanced"** and then **"Proceed to 3.253.195.102 (unsafe)"**.

---

## 🏗️ Architecture Stack
| Component | Technology | Role |
| :--- | :--- | :--- |
| **Server** | AWS EC2 (Ubuntu 24.04) | Physical Hosting |
| **Reverse Proxy** | Nginx (Docker) | SSL Termination & Load Balacing |
| **Frontend** | Express / Node.js (Docker) | Web UI (Port 3000) |
| **Backend** | Flask / Python (Docker) | Form Processing & Logic (Port 5000) |

---

## 🛠️ Deployment Steps Taken

### 1. Remote Server Setup
- Connected via SSH using the `nomanqadri34.pem` key.
- Installed **Docker** and **Docker Compose v2** on the Ubuntu host.
- Configured permissions for the `ubuntu` user to manage containers.

### 2. Nginx Reverse Proxy Integration
To enable HTTPS, we added an **Nginx** container as a "front door" for the app:
- **Port 80 (HTTP)**: Automatically redirects all users to Port 443 (HTTPS).
- **Port 443 (HTTPS)**: Uses the generated SSL certificates to handle secure connections.
- **Internal Routing**: Nginx forwards traffic from the internet to the `frontend` container inside the Docker network.

### 3. Docker Orchestration
We used `docker-compose.yml` to launch all three services simultaneously:
```bash
docker compose up --build -d
```
This ensures that if the server restarts, the application starts automatically.

### 4. Network Security (AWS Security Group)
For maximum security, we configured the AWS Firewall as follows:
- **OPEN**: Port **22** (SSH), Port **80** (HTTP), and Port **443** (HTTPS).
- **CLOSED**: Ports **3000** and **5000**. These are no longer exposed to the public internet; they can only be reached internally by Nginx.

---

## 👨‍💻 Author
**Student Assignment — Dockerized Fullstack Deployment on AWS**
