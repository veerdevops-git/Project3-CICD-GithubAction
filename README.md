🚀 Node.js CI/CD Pipeline with GitHub Actions + Docker + Kubernetes
🔧 Overview
This project sets up a CI/CD pipeline for a simple Node.js app. The pipeline builds a Docker image, pushes it to Docker Hub, and deploys to Kubernetes.

📁 Project Structure
bash
Copy
Edit
.
├── .github/workflows/ci-cd-pipeline.yml  # GitHub Actions workflow
├── Dockerfile                            # Builds the Docker image
├── package.json                          # Node.js dependencies
├── src/index.js                          # App entry point
└── k8s/                                  # Kubernetes manifests (deployment & service)
🛠️ Step-by-Step Guide
Create Node.js App

Initialize with npm init -y

Add a simple Express app in src/index.js

Create package.json

json
Copy
Edit
{
  "name": "node-app",
  "version": "1.0.0",
  "scripts": {
    "start": "node src/index.js",
    "test": "echo \"No tests yet\""
  },
  "dependencies": {
    "express": "^4.17.1"
  }
}
Create Dockerfile

dockerfile
Copy
Edit
FROM node:14
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
Create GitHub Actions Workflow

File: .github/workflows/ci-cd-pipeline.yml

Includes:

Checkout code

Install deps & test

Build Docker image

Push image to Docker Hub

Upload optional artifacts

Push Code to GitHub Repo

Set GitHub Secrets

Go to: Repo → Settings → Secrets → Actions

Add:

DOCKER_USERNAME

DOCKER_PASSWORD

Create Kubernetes Manifests

deployment.yaml (pulls image from Docker Hub)

service.yaml (use type: NodePort for testing)

Deploy to Kubernetes

bash
Copy
Edit
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml