# 아르고 cd 클러스터 추가하기

## 아르고 cd 로그인
```
argocd logind <argocd adress>
```

## 추가할 클러스터 이름 알아내기
```
kubectl config get-contexts -o name
```

## 추가할 클러스터에 연결하고 ns추가하기
```
kubectl create namespace argocd
```

## 알아낸 이름으로 추가하기
```
argocd cluster add <위에 명령어 결과값> --system-namespace argocd
```