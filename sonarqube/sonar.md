

git clone https://github.com/coderise-lab/k8s-sonarqube



Create the secret 

kubectl create secret generic postgres-pwd --from-literal=password=CodeRise_Pass



Run the following command on each node (especially the one where the PostgreSQL Pod will run):

sudo mkdir -p /data/postgresql/
sudo chmod 777 /data/postgresql/
