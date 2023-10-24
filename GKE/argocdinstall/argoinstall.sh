#!/bin/bash

function wait_for_port_to_be_used() {
    local PORT=$1
    local MAX_TRIES=10
    local TRIES=0

    while ! (netstat -tuln | grep ":$PORT " > /dev/null 2>&1); do
        sleep 1
        ((TRIES++))

        if [ $TRIES -ge $MAX_TRIES ]; then
            echo "Port $PORT is not being used after waiting for $MAX_TRIES seconds. Exiting."
            exit 1
        fi
    done
}

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
kubectl port-forward svc/argocd-server -n argocd 8080:443 & 

# Wait for port 8080 to be in use
wait_for_port_to_be_used 8080

# Print External IP
kubectl get svc argocd-server -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'; echo

# Print the admin password
echo "Fetching the initial admin password..."
argocd admin initial-password -n argocd
