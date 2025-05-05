# Makefile
install:
	curl -L https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -o files/install.yaml
	helm install argocd-custom .

upgrade:
	helm upgrade argocd-custom .

uninstall:
	helm uninstall argocd-custom