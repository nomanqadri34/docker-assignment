# 🚀 Kubernetes Local Deployment (Minikube) — Final Submission

This document verifies the successful local deployment of the Flask backend and Express frontend onto a local Kubernetes cluster using **Minikube**.

---

## 🏗 Architecture Overview

1. **Local Kubernetes Cluster**: We used **Minikube** (utilizing the Docker driver) to spin up a single-node Kubernetes cluster directly on the local Windows OS environment.
2. **Kubernetes Resources**:
   * `backend-deployment`: A Pod replica running the Python Flask application locally.
   * `backend-service`: A **ClusterIP** service routing internal HTTP traffic on port 5000 directly to the backend Pods.
   * `frontend-deployment`: A Pod replica running the Node/Express React frontend, configured with `FLASK_URL` to point to the backend service.
   * `frontend-service`: A **NodePort** service explicitly mapped to port `30080` to expose the frontend to the local machine's web browser natively.

---

## ⚙️ Deployment Execution Commands

The following commands were correctly executed locally to provision the cluster, build the images securely inside the Minikube registry daemon, and apply the YAML manifests:

```powershell
# 1. Start Minikube cluster using Docker Engine Desktop driver
.\minikube.exe start --driver=docker

# 2. Point Docker context safely to Minikube
.\minikube.exe docker-env | Invoke-Expression

# 3. Build Docker Images directly inside the minikube ecosystem
docker build -t flask-backend ./backend
docker build -t express-frontend ./frontend

# 4. Deploy configured YAML Resource Manifests
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# 5. Access the application natively
kubectl get pods
```

---

## 📸 Local Kubernetes Proof of Work

Below are the live execution screenshots proving the deployment commands functioning, the Pods reaching the `ContainerCreating` and `Running` lifecycle phases, and the successful Minikube instantiation:

![Kubernetes Proof 1](./kubernates/Screenshot%202026-04-03%20010350.png)
<br><br>
![Kubernetes Proof 2](./kubernates/Screenshot%202026-04-03%20020810.png)
<br><br>
![Kubernetes Proof 3](./kubernates/Screenshot%202026-04-03%20020826.png)
<br><br>
![Kubernetes Proof 4](./kubernates/Screenshot%202026-04-03%20020834.png)
<br><br>
![Kubernetes Proof 5](./kubernates/Screenshot%202026-04-03%20020840.png)

---
**Submission Guidelines Met**: Minikube locally launched, Kubernetes manifest resources successfully built locally via `./k8s`, and documented thoroughly.
