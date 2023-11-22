# argocd의 yaml설정
## nodeselector 추가
      nodeSelector:
        cloud.google.com/gke-nodepool: argocd

## OAuth 추가
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
  name: argocd-cm
  namespace: argocd
data:
  admin.enabled: "false"
  url: https://www.2280.store
  dex.config: |
    connectors:
      - type: github
        id: github
        name: GitHub
        config:
          clientID: $argocd-iap-oauth-client:client_id
          clientSecret: $argocd-iap-oauth-client:client_secret
          orgs:
          - name: GCP-ING

# ingress를 추가하여 ssl도 추가하였음