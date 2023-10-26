#!/bin/bash

# Install Helm
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh
echo "Helm installation complete."

# Add Helm Chart
echo "Adding Helm chart for Argo..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
echo "Helm chart added."

# Create values.yaml
cat <<EOF > values.yaml
global:
  nodeSelector:
    cloud.google.com/gke-nodepool: argocd
EOF

# Install argocd
echo "Installing ArgoCD..."
helm install argocd -f values.yaml argo/argo-cd --namespace argocd --create-namespace 
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

# Wait for External IP
echo "Waiting for ArgoCD External IP..."
while true; do
    IP=$(kubectl get svc argocd-server -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ ! -z "$IP" ]]; then
        break
    fi
    sleep 10
done
echo "ArgoCD External IP: $IP"

# Print the admin password
echo "Fetching the initial admin password..."
argocd admin initial-password -n argocd
