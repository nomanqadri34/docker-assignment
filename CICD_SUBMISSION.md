# Jenkins CI/CD Automation Assignment — Submission

This document explains the CI/CD pipeline implementation for the Flask/Express full-stack application. We have automated the environment setup using Terraform and implemented declarative Jenkins pipelines for the development workflow.

---

## Part 1: Automated Infrastructure Setup

The infrastructure for the Jenkins server is completely provisioned via Terraform in the `terraform/part4-jenkins` directory.

### Commands Executed
```powershell
cd terraform/part4-jenkins
./terraform.exe init
./terraform.exe plan
./terraform.exe apply -auto-approve
```

### Infrastructure details
- **Instance Type**: t2.micro (Ubuntu 22.04 LTS)
- **Swap Space**: 2GB (Configured to prevent Jenkins memory crashes)
- **Installed Tools**: Jenkins (Java 17), Node.js v18, PM2, Python 3, Venv.
- **Security Groups**: Default access to 8080 (Jenkins UI), 5000 (Flask), and 3000 (Express).

---

## Part 2: Jenkins CI/CD Pipelines

Separate declarative pipelines (`Jenkinsfile`) have been implemented for the backend and frontend.

### Backend Pipeline Job Config
- **Name**: `flask-backend-pipeline`
- **Definition**: Pipeline from SCM
- **SCM**: Git
- **Script Path**: `backend/Jenkinsfile`

### Frontend Pipeline Job Config
- **Name**: `express-frontend-pipeline`
- **Definition**: Pipeline from SCM
- **SCM**: Git
- **Script Path**: `frontend/Jenkinsfile`

### Automation Workflow
1. **GitHub Webhook**: Configured to point to `http://<JENKINS_IP>:8080/github-webhook/`
2. **Pull Code**: Jenkins pulls the latest changes.
3. **Install**: Virtual-envs are handles for Python; `npm install` for Node.
4. **Deploy**: **PM2** process manager handles the zero-downtime restart of the services.

---

## Deployment & Verification Instructions

### 1. Access Jenkins
1. Get the Initial Admin Password:
   ```bash
   ssh -i nomanqadri34.pem ubuntu@<JENKINS_IP>
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
2. Navigate to `http://<JENKINS_IP>:8080` and sign in.
3. Install Recommended Plugins.

### 2. Create the Pipelines
1. **New Item** -> `flask-backend-pipeline` -> **Pipeline**
2. Under **Pipeline tab**:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/nomanqadri34/docker-assignment.git`
   - Script Path: `backend/Jenkinsfile`
3. Click Save and **Build Now**.
4. Repeat for the `express-frontend-pipeline` with script path `frontend/Jenkinsfile`.

### 3. Verify
Access your live apps at:
- **Frontend**: `http://<JENKINS_IP>:3000`
- **Backend API**: `http://<JENKINS_IP>:5000/health`

---

## Visual Submission Proof (Screenshot Placeholders)

> [!NOTE]
> Please take screenshots and add them according to the requirements:
> - **Screenshot 1**: Jenkins Job History (Success builds)
> - **Screenshot 2**: EC2 Instance Console (Jenkins Server)
> - **Screenshot 3**: Live application running on Port 3000/5000.
