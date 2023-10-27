# Public static IP address
Create the static public IP address:
```
STATIC_IP_NAME=boutique-ip
gcloud compute addresses create $STATIC_IP_NAME --global
```

# Cloud Armor
Set up Cloud Armor:
```
SECURITY_POLICY_NAME=boutique-security-policy
gcloud compute security-policies create $SECURITY_POLICY_NAME \
    --description "Block various attacks"
gcloud compute security-policies rules create 1000 \
    --security-policy $SECURITY_POLICY_NAME \
    --expression "evaluatePreconfiguredExpr('xss-stable')" \
    --action "deny-403" \
    --description "XSS attack filtering"
gcloud compute security-policies rules create 12345 \
    --security-policy $SECURITY_POLICY_NAME \
    --expression "evaluatePreconfiguredExpr('cve-canary')" \
    --action "deny-403" \
    --description "CVE-2021-44228 and CVE-2021-45046"
gcloud compute security-policies update $SECURITY_POLICY_NAME \
    --enable-layer7-ddos-defense
gcloud compute security-policies update $SECURITY_POLICY_NAME \
    --log-level=VERBOSE
```

# SSL Poilcy
Set up an SSL policy in order to later set up a redirect from HTTP to HTTPs:
```
SSL_POLICY_NAME=boutique-ssl-policy
gcloud compute ssl-policies create $SSL_POLICY_NAME \
    --profile COMPATIBLE  \
    --min-tls-version 1.0
```

# Deploy
Deploy the Kubernetes manifests in this current folder:
```
kubectl apply -f . -n boutique
```

Wait for the ManagedCertificate to be provisioned. This usually takes about 30 minutes.
```
kubectl get managedcertificates
```

Remove the default LoadBalancer Service not used at this point:
```
kubectl delete service front-external -n boutique
```