# Project3-CICD-GithubAction


CI/CD Pipeline for Docker Images with GitHub Actions
This project implements a fully automated CI/CD pipeline using GitHub Actions to build, test, and deploy Docker images. The pipeline builds a Docker image for a Node.js application, pushes the image to Docker Hub, and optionally uploads build artifacts. This summary will guide you through the end-to-end process.

Project Setup
1. Project Files Overview
Before setting up the CI/CD pipeline, ensure that your Node.js application is structured correctly. Here's an example directory structure for the project:

plaintext
Copy
Edit
.
├── .github
│   └── workflows
│       └── ci-cd-pipeline.yml       # GitHub Actions workflow
├── Dockerfile                       # Dockerfile to build the Docker image
├── package.json                     # Node.js dependencies and scripts
├── package-lock.json                # Ensures consistent npm installs
└── src                              # Your application code
    └── index.js                     # Sample Node.js entry file
2. package.json File
In your package.json, define the dependencies and scripts for your Node.js app. A typical package.json might look like this:

json
Copy
Edit
{
  "name": "node-app",
  "version": "1.0.0",
  "description": "A simple Node.js application",
  "main": "index.js",
  "scripts": {
    "start": "node src/index.js",
    "test": "echo \"No tests yet\""
  },
  "dependencies": {
    "express": "^4.17.1"
  },
  "devDependencies": {}
}
Explanation:

scripts.start: The command to run your application inside the Docker container (node src/index.js).

scripts.test: A placeholder test script, which can be expanded to include real tests.

3. Dockerfile
Your Dockerfile defines how to build your Docker image from the Node.js application.

dockerfile
Copy
Edit
# Use official Node.js image
FROM node:14

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Expose the application port
EXPOSE 3000

# Command to start the application
CMD ["npm", "start"]
Explanation:

FROM node:14: Starts from an official Node.js image.

WORKDIR /app: Sets the working directory inside the Docker container to /app.

COPY package.json package-lock.json ./: Copies the package.json and package-lock.json files to install the dependencies.

RUN npm install: Installs the dependencies.

COPY . .: Copies the rest of the application files into the Docker container.

EXPOSE 3000: Exposes port 3000 for the application.

CMD ["npm", "start"]: The command to run your Node.js app when the Docker container starts.

CI/CD Pipeline Setup
4. Create GitHub Actions Workflow
Create a .github/workflows/ci-cd-pipeline.yml file in your repository. This file defines the CI/CD pipeline steps that will run automatically on every push.

5. Define the Pipeline Steps
The pipeline consists of the following steps:

Step 1: Clone the Repository
The first step in the pipeline is to checkout the code from the GitHub repository.

yaml
Copy
Edit
- name: Checkout code
  uses: actions/checkout@v2
Explanation:

actions/checkout@v2: This action checks out the code from your GitHub repository to the GitHub Actions runner.

Step 2: Set Up Docker Login
Authenticate to Docker Hub using your Docker Hub credentials stored as GitHub secrets.

yaml
Copy
Edit
- name: Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
Explanation:

docker/login-action@v3: Logs into Docker Hub using the credentials stored in GitHub secrets (DOCKER_USERNAME and DOCKER_PASSWORD).

Step 3: Build Docker Image
Build the Docker image from the repository’s code using the Dockerfile.

yaml
Copy
Edit
- name: Build Docker image
  run: |
    docker build -t ${{ secrets.DOCKER_USERNAME }}/node-app:${{ github.sha }} .
    docker tag ${{ secrets.DOCKER_USERNAME }}/node-app:${{ github.sha }} ${{ secrets.DOCKER_USERNAME }}/node-app:latest
Explanation:

docker build: This command builds the Docker image and tags it with the current commit SHA (${{ github.sha }}) for versioning.

docker tag: Also creates a latest tag for the Docker image.

Step 4: Push Docker Image to Docker Hub
After building the image, we push it to Docker Hub.

yaml
Copy
Edit
- name: Push Docker image to Docker Hub
  run: |
    docker push ${{ secrets.DOCKER_USERNAME }}/node-app:${{ github.sha }}
    docker push ${{ secrets.DOCKER_USERNAME }}/node-app:latest
Explanation:

docker push: Pushes both the commit-specific version tag and the latest tag to your Docker Hub repository.

Step 5: Upload Build Artifacts (Optional)
This step uploads build artifacts (e.g., logs or test results) for debugging or further analysis.

yaml
Copy
Edit
- name: Upload Build Artifact
  uses: actions/upload-artifact@v3
  with:
    name: node-app-artifact
    path: .
Explanation:

actions/upload-artifact@v3: This action uploads files (in this case, the entire directory) as build artifacts, which can be downloaded later.

6. Configuring GitHub Secrets
For security, store sensitive information (such as your Docker Hub credentials) in GitHub secrets:

Go to GitHub → Repo → Settings → Secrets and variables → Actions → Secrets.

Click "New repository secret".

Add the following secrets:

DOCKER_USERNAME: Your Docker Hub username.

DOCKER_PASSWORD: Your Docker Hub password or access token.

7. Running the CI/CD Pipeline
Once you push your changes to the repository, the GitHub Actions workflow is automatically triggered.

Push to GitHub: On every push to the repository, GitHub Actions will:

Clone the repository.

Log into Docker Hub.

Build the Docker image.

Push the image to Docker Hub.

Monitor the Process: The progress and status of the workflow can be monitored from the Actions tab in your GitHub repository.