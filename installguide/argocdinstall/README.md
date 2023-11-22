# 쉘 목차

Install Helm
Add Helm Chart
naspace 생성
Install argocd
ManagedCertificate가 Active 상태가 될 때까지 확인
values.yaml 파일 재생성 (argo-rollouts 용)
argo-rollouts 설치
Install ArgoCD CLI
rollouts 플러그인 설치
Print the admin password
ArgoCD 로그인
Secret Manager에서 시크릿 키 가져오기
ArgoCD에 repo 등록
ArgoCD 앱 추가 (dev)
권한 설정
GSA 생성
GSA 롤 바인딩 (identityUser + 필요한 역할)
KSA 생성
GSA - KSA 바인딩
Annotation 추가
환경변수 등록
prod 클러스터에 접속하기
prod 클러스터에 argocd-rollout 설치
argocd cluster 추가 및 출력을 변수에 저장
출력 메시지에서 IP 주소 추출
prod cluster에 ArgoCD 앱 추가
argocd rollouts 대시보드 실행


# 실행 방법
```
chmod +x ~/ING_k8s/installguide/argocdinstall/argoinstall.sh
bash ~/ING_k8s/installguide/argocdinstall/argoinstall.sh
```