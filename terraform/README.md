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