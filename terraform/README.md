# terraform guide

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

## IAM
Workload Identity Service Account
```
cd ../global/iam
# variables.tf 파일 project_id 수정

terraform init
terraform apply
```
Kubernetes Service Account, Namespace 생성
```
kubectl create sa [sa_name]
kubectl create namespace [namespace]
```
Google Service Account와 Kubernetes Service Account mapping
```
gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:[Project_id].svc.id.goog[namespace/ksa]" [Google_service_account]@fluted-union-403305.iam.gserviceaccount.com
```
kubernetes Service Account에 Annotation 추가
```
kubectl annotate serviceaccount --namespace [namespace] [ksa] iam.gke.io/gcp-service-account=[Google_service_account]@[project_id].iam.gserviceaccount.com
```