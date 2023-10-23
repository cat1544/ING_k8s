#!/bin/bash

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "ArgoCD installation complete."

# Install ArgoCD CLI
echo "Installing ArgoCD CLI..."
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
echo "ArgoCD CLI installation complete."

# Change the ArgoCD's Cluster IP to LoadBalancer
echo "Changing ArgoCD's service type to LoadBalancer..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Port-forwarding
echo "Setting up port-forwarding for ArgoCD..."
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Print the admin password
echo "Fetching the initial admin password..."
argocd admin initial-password -n argocd
