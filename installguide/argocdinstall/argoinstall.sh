#!/bin/bash

# Install Helm
# echo "Installing Helm..."
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh
# rm get_helm.sh
# echo "Helm installation complete."

# Add Helm Chart
# echo "Adding Helm chart for Argo..."
# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo update
# echo "Helm chart added."

# Install argocd
echo "Installing ArgoCD..."
kubectl apply -n argocd -f ~/ING_k8s/installguide/argocdyaml/argocd.yaml
echo "ArgoCD installation complete."

# ManagedCertificate가 Active 상태가 될 때까지 확인
CERT_NAME="argocd-certificate" # ManagedCertificate 이름
NAMESPACE="argocd" # 네임스페이스

echo "ManagedCertificate의 상태를 확인합니다."

while true; do
    # ManagedCertificate의 상태를 가져옵니다.
    STATUS=$(kubectl get managedcertificate $CERT_NAME -n $NAMESPACE -o jsonpath='{.status.certificateStatus}')
    
    # 상태가 Active인지 확인합니다.
    if [ "$STATUS" == "Active" ]; then
        echo "ManagedCertificate가 활성화되었습니다. 다음 단계로 진행합니다."
        break
    else
        echo "ManagedCertificate가 아직 활성화되지 않았습니다. 10초 후에 다시 시도합니다."
        sleep 10
    fi
done

# values.yaml 파일 재생성 (argo-rollouts 용)
cat <<EOF > values.yaml
controller:
  nodeSelector:
    cloud.google.com/gke-nodepool: argocd
dashboard:
  enabled: true
EOF

# argo-rollouts 설치
echo "argo-rollouts 설치 중..."
helm install argocd-rollouts -f values.yaml argo/argo-rollouts --namespace argocd-rollouts --create-namespace
echo "ArgoCD-rolluts installation complete."

# Install ArgoCD CLI
echo "Installing ArgoCD CLI..."
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
echo "ArgoCD CLI installation complete."

# rollouts 플러그인 설치
echo "rollouts 플러그인 설치 중..."
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

# Change the ArgoCD's Cluster IP to LoadBalancer
echo "Changing ArgoCD's service type to LoadBalancer..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# # Wait for External IP
# echo "Waiting for ArgoCD External IP..."
# while true; do
#     ARGOCD_SERVER=$(kubectl get svc argocd-server -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
#     if [[ ! -z "$ARGOCD_SERVER" ]]; then
#         break
#     fi
#     sleep 10
# done
# echo "ArgoCD External IP: $ARGOCD_SERVER"

# # Print the admin password
# echo "Fetching the initial admin password..."
# argocd admin initial-password -n argocd
# ARGOCD_PASSWORD=$(argocd admin initial-password -n argocd | awk 'NR==1')

# # Define a retry function
# retry_command() {
#     local RETRIES=3
#     local SLEEP_TIME=10
#     local COUNTER=0

#     until [ $COUNTER -gt $RETRIES ]; do
#         $@ && break
#         COUNTER=$((COUNTER + 1))
#         if [ $COUNTER -le $RETRIES ]; then
#             echo "Retrying ($COUNTER/$RETRIES)..."
#             sleep $SLEEP_TIME
#         fi
#     done

#     if [ $COUNTER -gt $RETRIES ]; then
#         echo "Failed after $RETRIES attempts."
#         exit 1
#     fi
# }

# ArgoCD 로그인
echo "ArgoCD 로그인 중..."
argocd login www.2280.store --username admin --password $ARGOCD_PASSWORD --insecure

# Secret Manager에서 시크릿 키 가져오기
SECRET_VALUE=$(gcloud secrets versions access 1 --secret="GIT_ACCESS_TOKEN")

# ArgoCD에 repo 등록
USER_NAME=$(git config user.name)
argocd repo add https://github.com/$USER_NAME/ING_k8s.git --username $USER_NAME --password $SECRET_VALUE --insecure --grpc-web
# 다른 클러스터에 접속하기 위한 설정
#gcloud container clusters get-credentials production --region asia-northeast3 --project protean-blend-398805

# 필요한 네임스페이스 생성
#kubectl create namespace argocd
#kubectl create namespace boutique

# 클러스터 이름 형식 설정 및 추가 등록
#CLUSTER_NAME=gke_<project>_asia-northeast3_<clusername>
#CLUSTER_NAME=gke_protean-blend-398805_asia-northeast3_production
#argocd cluster add $CLUSTER_NAME --system-namespace argocd

# ArgoCD 앱 추가
argocd app create boutique \
  --repo https://github.com/$USER_NAME/ING_k8s.git \
  --path GKE/cluster/overlays/prod \
  --dest-namespace boutique \
  --dest-server https://kubernetes.default.svc \
  --sync-option CreateNamespace=true
  --grpc-web
  
# argocd rollouts 대시보드 실행
kubectl argo rollouts dashboard &
