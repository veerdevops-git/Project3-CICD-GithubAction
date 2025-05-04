# 🚀 Full CI/CD Pipeline with GitHub Actions, Docker, Kubernetes & ArgoCD

This project demonstrates a complete CI/CD pipeline for a Node.js application using **GitHub Actions**, **Docker**, **Kubernetes**, and **ArgoCD** for GitOps-based continuous deployment.

---

### **Step 1: Create Node.js Application**

* Created `app.js` with a simple Express server:

  ```js
  const express = require('express');
  const app = express();
  app.get('/', (req, res) => res.send('Hello from GitHub Actions! by mobile'));
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => console.log(`App running on port ${PORT}`));
  ```
* Created `package.json` with dependencies:

  ```json
  {
    "name": "node-app",
    "version": "1.0.0",
    "main": "app.js",
    "scripts": {
      "start": "node app.js",
      "test": "echo \"No test specified\" && exit 0"
    },
    "dependencies": {
      "express": "^4.18.2"
    }
  }
  ```

---

### **Step 2: Create Dockerfile**

* Created `Dockerfile` to containerize the app:

  ```dockerfile
  FROM node:18
  WORKDIR /app
  COPY . .
  RUN npm install
  EXPOSE 3000
  CMD ["npm", "start"]
  ```

---

### **Step 3: Set Up GitHub Secrets**

* Created a **Docker Hub account**.
* Generated **Docker access token** (recommended).
* Added the following secrets to your GitHub repo under **Settings → Secrets and variables → Actions**:

  * `DOCKER_USERNAME`
  * `DOCKER_PASSWORD`

---

### **Step 4: Configure GitHub Actions CI/CD Workflow**

* Created `.github/workflows/ci-cd.yml`:

  * Runs on `push` to `main`
  * Installs dependencies, builds and tests
  * Builds Docker image and pushes to Docker Hub
  * Updates `deployment.yaml` with new tag
  * Commits the change back to the repo
  * ArgoCD watches and deploys the new version automatically

---

### **Step 5: Create Kubernetes Deployment and Service**

* Created a `K8S/` folder in the repo.
* Added the following files:

  **K8S/deployment.yaml**

  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: node-app
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: node-app
    template:
      metadata:
        labels:
          app: node-app
      spec:
        containers:
        - name: node-app
          image: DOCKER_USERNAME/node-app:latest  # <-- Will be updated by GitHub Action
          ports:
          - containerPort: 3000
  ```

  **K8S/service.yaml**

  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: node-app-service
  spec:
    selector:
      app: node-app
    ports:
      - protocol: TCP
        port: 80
        targetPort: 3000
    type: LoadBalancer
  ```

---

### **Step 6: Automatically Update Image Tag in deployment.yaml**

* Added a GitHub Action step that:

  * Replaces the Docker tag in `K8S/deployment.yaml`
  * Commits and pushes the updated YAML file back to the repo using `GITHUB_TOKEN`
* This ensures ArgoCD picks up changes automatically.

---

### **Step 7: Install and Configure ArgoCD**

* Installed **ArgoCD** on your Kubernetes cluster:

  ```bash
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```

* Logged in to ArgoCD UI:

  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  ```

* Set admin password:

  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
  ```

---

### **Step 8: Connect GitHub Repo to ArgoCD**

* In ArgoCD UI:

  * **Add Git repository**:

    * Repo URL: your GitHub repo
    * Type: HTTPS or SSH (use token for HTTPS)
    * Username: your GitHub username
    * Password/Token: GitHub personal access token
  * **Create a new ArgoCD Application**:

    * Name: `node-app`
    * Repo: your GitHub repo
    * Path: `K8S`
    * Cluster: your AKS cluster
    * Namespace: your app namespace
    * Sync Policy: **Automatic**

---

### **Now You Have a Fully Automated GitOps Pipeline!**

* Push code → GitHub Actions builds Docker image
* Tag is updated in `deployment.yaml` automatically
* Change is committed → ArgoCD sees it and deploys to AKS
