#!/bin/bash

set -e

# Step 1: Create namespace
echo "Creating namespace 'argocd'..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Step 2: Download ArgoCD installation manifest
echo "Downloading ArgoCD install.yaml..."
curl -sSL -o install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Step 3: Apply ArgoCD manifest
echo "Applying ArgoCD install.yaml..."
kubectl apply -n argocd -f install.yaml

# Step 4: Patch argocd-server deployment to add --insecure flag
echo "Patching argocd-server deployment to use --insecure..."
kubectl -n argocd patch deployment argocd-server \
  --type='json' \
  -p='[
    {"op": "replace", "path": "/spec/template/spec/containers/0/command", "value":["argocd-server"]},
    {"op": "replace", "path": "/spec/template/spec/containers/0/args", "value":["--insecure"]}
  ]'

# Step 5: Patch argocd-server service to use NodePort
echo "Patching argocd-server service to NodePort 32080..."
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "targetPort": 8080, "nodePort": 32080, "protocol": "TCP", "name": "http"}]}}'

# Step 6: Show status
echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/argocd-server -n argocd
kubectl get pods -n argocd
kubectl get svc -n argocd

# Step 7: Get Node IP
echo -e "\nTo access the ArgoCD UI, open the following URL in your browser:"
NODE_IP=$(kubectl get nodes -o wide | awk 'NR==2{print $6}')
echo "➡️  http://${NODE_IP}:32080"

# Step 8: Show ArgoCD admin password
echo -e "\n🔐 ArgoCD admin password:"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo

# Optional restart (commented out)
# echo -e "\n(If needed) Restarting argocd-server..."
# kubectl rollout restart deployment argocd-server -n argocd

echo -e "\n✅ ArgoCD installation complete!"
