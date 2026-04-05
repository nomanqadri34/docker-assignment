# Jenkins CI/CD Deployment Assignment — Final Submission

This document outlines the successful deployment of a Flask backend and Express frontend on a single Amazon EC2 instance, followed by the implementation of a fully automated CI/CD pipeline using Jenkins.

---

## Part 1: Deploy Flask and Express on a Single EC2 Instance

### Objective
Deploy both the Flask backend (port 5000) and the Express frontend (port 3000) on a single EC2 instance provisioned via Terraform.

### Infrastructure Provisioning (Terraform)
We used Terraform to automate the creation of the EC2 instance, security groups, and the installation of core dependencies (Java, Node.js, Python, PM2).

#### Commands Executed
```powershell
cd terraform/part4-jenkins
./terraform.exe init
./terraform.exe apply -auto-approve
```

#### Terraform Output
```hcl
Outputs:

jenkins_ip = "108.131.60.220"
jenkins_url = "http://108.131.60.220:8080"
flask_url = "http://108.131.60.220:5000"
express_url = "http://108.131.60.220:3000"
ssh_command = "ssh -i nomanqadri34.pem ubuntu@108.131.60.220"
initial_admin_password_command = "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

### Execution Screenshots
<img src="cicd/Screenshot 2026-04-05 193924.png" width="800">
<img src="cicd/Screenshot 2026-04-05 193932.png" width="800">
<img src="cicd/Screenshot 2026-04-05 193941.png" width="800">
<img src="cicd/Screenshot 2026-04-05 193953.png" width="800">

---

## Part 2: Implement CI/CD Pipeline Using Jenkins

### Objective
Automate the deployment process so that every push to the GitHub repository triggers a Jenkins build that installs dependencies and restarts the application services via PM2.

### Jenkins Pipeline Configuration
Two separate Jenkins Pipeline jobs were created: `flask-backend-pipeline` and `express-frontend-pipeline`.

#### 1. Backend Jenkinsfile (`backend/Jenkinsfile`)
The pipeline automates the creation of a Python virtual environment, installs `requirements.txt`, and uses `pm2` to manage the Flask process.

#### 2. Frontend Jenkinsfile (`frontend/Jenkinsfile`)
The pipeline automates the `npm install` process and uses `pm2` to manage the Express server.

### Automation & Webhooks
- **GitHub Webhook**: Configured to notify Jenkins on every code push.
- **PM2 Manager**: Ensures the applications remain active and restarts them with zero downtime during the CI/CD cycle.

### Pipeline Execution Screenshots
<img src="cicd/Screenshot 2026-04-05 194002.png" width="800">
<img src="cicd/Screenshot 2026-04-05 194010.png" width="800">
<img src="cicd/Screenshot 2026-04-05 194017.png" width="800">
<img src="cicd/Screenshot 2026-04-05 194027.png" width="800">

---

## Conclusion
The assignment requirements for Part 1 (Manual/Terraform Deployment) and Part 2 (CI/CD Automation) are fully met. The environment is stable, the pipelines are functional, and the applications are publicly accessible.
