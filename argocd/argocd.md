🚀 ArgoCD Installation with NodePort and --insecure Flag (Step-by-Step Guide)
1. Create the ArgoCD Namespace
First, create a Kubernetes namespace for ArgoCD.

yaml
Copy
Edit
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
Apply it:

bash
Copy
Edit
kubectl apply -f namespace.yaml
2. Download ArgoCD Installation YAML
Download the official ArgoCD install YAML file.

bash
Copy
Edit
curl -O https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
3. Apply the ArgoCD Install YAML
Apply the downloaded YAML to create the default resources for ArgoCD:

bash
Copy
Edit
kubectl apply -n argocd -f install.yaml
4. Patch the argocd-server Deployment to Add --insecure Flag
Run the following kubectl patch command to modify the argocd-server deployment and add the --insecure flag:

bash
Copy
Edit
kubectl -n argocd patch deployment argocd-server \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value":["argocd-server"]}, {"op": "replace", "path": "/spec/template/spec/containers/0/args", "value":["--insecure"]}]'
5. Patch the argocd-server Service to Use NodePort
Now, use the following kubectl patch command to expose the argocd-server service on NodePort 32080.

bash
Copy
Edit
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "targetPort": 8080, "nodePort": 32080, "protocol": "TCP", "name": "http"}]}}'
6. Verify the Deployment
Check the status of your pods and services to make sure everything is running:

bash
Copy
Edit
kubectl get pods -n argocd
kubectl get svc -n argocd
7. Access ArgoCD UI
Find your Node IP (for example, if using Minikube, run minikube ip), then open ArgoCD UI in your browser:

cpp
Copy
Edit
http://<NodeIP>:32080
8. Get Initial Admin Password
Retrieve the initial admin password for ArgoCD:

bash
Copy
Edit
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo
Use admin as the username and the decoded password to log in.

Optional: Force Restart After Modifications
If you need to restart the argocd-server after modifying configurations:

bash
Copy
Edit
kubectl rollout restart deployment argocd-server -n argocd
Done!
You’ve now successfully installed ArgoCD with NodePort and the --insecure flag.