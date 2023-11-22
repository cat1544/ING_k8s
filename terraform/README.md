# terraform guide
* global/gcs 폴더의 variables.tf파일 수정 {project_id, terraform backend name}
* dev, prod 폴더 local 변수 및 project_id, backend name,Bastion sa 수정 필요

* terraform apply 전 API 활성화 필요
Compute Engine API / compute.googleapis.com
Cloud Resource Manager API / cloudresourcemanager.googleapis.com
Cloud Pub/sub API / pubsub.googleapis.com
Identity and Accesss Management(IAM) API / am.googleapis.com
Service Networking API / servicenetworking.googleapis.com
Kubernetes Engine API / container.googleapis.com


## GCS
create GCS - terraform Backend

```
cd global/gcs
# variables.tf 파일의 project_id, bucket_name 수정

terraform init
terraform apply
```

## Dev
Dev network, Cluster
```
cd ../../dev
# main.tf 파일 local 변수의 project_id, 테라폼 백엔드 설정의 bucket_name 수정

terraform init
terraform apply
```

## Prod
Prod network, Cluster
```
cd ../prod
# main.tf 파일 local 변수의 project_id, 테라폼 백엔드 설정의 bucket_name 수정

terraform init
terraform apply
```

## Workload Identity
Workload Identity Service Account
```
#env
PROJECT_ID={project_id}
NAMESPACE={namespace}
GSA={google_service_account}
KSA={Kubernetes_Service_account}
```
Kubernetes Service Account, Namespace 생성
```
kubectl create sa $KSA
kubectl create namespace $NAMESPACE
```
Google Service Account와 Kubernetes Service Account mapping
```
gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$PROJECT_ID.svc.id.goog[$NAMESPACE/$KSA]" $GSA@$PROJECT_ID.iam.gserviceaccount.com
```
kubernetes Service Account에 Annotation 추가
```
kubectl annotate serviceaccount --namespace $NAMESPACE $KSA iam.gke.io/gcp-service-account=$GSA@$PROJECT_ID.iam.gserviceaccount.com
```
