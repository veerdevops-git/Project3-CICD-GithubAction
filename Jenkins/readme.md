# Setup Jenkins On Kubernetes Cluster

This guide will walk you through the process of setting up Jenkins in a Kubernetes cluster.

## Prerequisites

- A running Kubernetes cluster (e.g., AKS, EKS, GKE, or a local cluster like Minikube).
- `kubectl` CLI tool installed and configured to access your cluster.
- Helm (optional for deployment) or direct kubectl commands.

---

### **Step 1: Create a Namespace Called `devops-tools`**

First, create a new namespace to organize resources related to Jenkins.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: devops-tools

Apply the above YAML:
kubectl apply -f namespace.yaml


Step 2: Create a Service Account with Kubernetes Admin Permissions
Create a service account to grant Jenkins admin access to the cluster.

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-admin
rules:
  - apiGroups: [""]
    resources: ["*"]
    verbs: ["*"]

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-admin
  namespace: devops-tools

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins-admin
subjects:
- kind: ServiceAccount
  name: jenkins-admin
  namespace: devops-tools


  Apply the above YAML files to set up the Service Account:
  kubectl apply -f service-account.yaml



Step 3: Create Local Persistent Volume for Jenkins Data
Jenkins requires persistent storage to retain data across pod restarts. Here, we'll create a PersistentVolume (PV) and PersistentVolumeClaim (PVC).


kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv-volume
  labels:
    type: local
spec:
  storageClassName: local-storage
  claimRef:
    name: jenkins-pv-claim
    namespace: devops-tools
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  local:
    path: /mnt
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node01

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pv-claim
  namespace: devops-tools
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi


kubectl apply -f persistent-volume.yaml
kubectl apply -f persistent-volume-claim.yaml


Step 4: Create the Jenkins Deployment
Create a deployment YAML to deploy Jenkins in your Kubernetes cluster, ensuring that the service account, persistent volume, and required resources are configured.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: devops-tools
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins-server
  template:
    metadata:
      labels:
        app: jenkins-server
    spec:
      securityContext:
        fsGroup: 1000
        runAsUser: 1000
      serviceAccountName: jenkins-admin
      containers:
        - name: jenkins
          image: jenkins/jenkins:lts
          resources:
            limits:
              memory: "2Gi"
            requests:
              memory: "500Mi"
          ports:
            - name: httpport
              containerPort: 8080
            - name: jnlpport
              containerPort: 50000
          livenessProbe:
            httpGet:
              path: "/login"
              port: 8080
            initialDelaySeconds: 90
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 5
          readinessProbe:
            httpGet:
              path: "/login"
              port: 8080
            initialDelaySeconds: 60
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          volumeMounts:
            - name: jenkins-data
              mountPath: /var/jenkins_home
      volumes:
        - name: jenkins-data
          persistentVolumeClaim:
            claimName: jenkins-pv-claim


Apply the deployment YAML:
kubectl apply -f jenkins-deployment.yaml



Step 5: Create the Jenkins Service
Create a service to expose the Jenkins application to the external network on a NodePort.

apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  namespace: devops-tools
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/path:   /
      prometheus.io/port:   '8080'
spec:
  selector: 
    app: jenkins-server
  type: NodePort  
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 32000


Apply the service YAML:
kubectl apply -f jenkins-service.yaml


Step 6: Access Jenkins Application
Once the deployment is successful, you can access Jenkins by using the NodePort exposed by

kubectl get svc -n devops-tools

Look for the jenkins-service and note the NodePort (in this case, it's 32000).

You can now access Jenkins using http://<NodeIP>:32000



Step 7: View Jenkins Logs
If you need to check the logs for the Jenkins pod, use the following commond

kubectl logs jenkins-<POD_NAME> -n devops-tools

You can get the pod name by running:

kubectl get pods -n devops-tools
