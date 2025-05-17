Make sure you're in the directory where your Chart.yaml and templates/ folder exist (your Jenkins Helm chart root):

cd /path/to/jenkins-helm-chart


Install the Helm Chart:

helm install jenkins-custom .

Get the NodePort to access Jenkins UI:
kubectl get svc jenkins-service -n devops-tools

Access Jenkins using:
http://<NodeIP>:32000


Get Jenkins Admin Password (Optional):

If required, get pod logs to find the initial admin password:

POD=$(kubectl get pods -n devops-tools -l app=jenkins-server -o jsonpath="{.items[0].metadata.name}")
kubectl logs $POD -n devops-tools

or 

 kkubectl exec -n devops-tools -it <podname> -- /bin/bash
