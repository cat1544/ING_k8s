# static_ip
STATIC_IP_NAME=dev-argocd-ip
gcloud compute addresses create $STATIC_IP_NAME --global

STATIC_IP_NAME=prod-argocd-ip
gcloud compute addresses create $STATIC_IP_NAME --global

STATIC_IP_NAME=dev-boutique-ip
gcloud compute addresses create $STATIC_IP_NAME --global

STATIC_IP_NAME=ing-boutique-ip
gcloud compute addresses create $STATIC_IP_NAME --global

# cloud armor
# dev-argocd
SECURITY_POLICY_NAME=dev-argocd-security-policy
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

# prod-argocd
SECURITY_POLICY_NAME=prod-argocd-security-policy
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

# dev-boutique
SECURITY_POLICY_NAME=dev-boutique-security-policy
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

# ing-boutique
SECURITY_POLICY_NAME=ing-boutique-security-policy
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

# ssl
SSL_POLICY_NAME=dev-argocd-ssl-policy
gcloud compute ssl-policies create $SSL_POLICY_NAME \
    --profile COMPATIBLE  \
    --min-tls-version 1.0

SSL_POLICY_NAME=prod-argocd-ssl-policy
gcloud compute ssl-policies create $SSL_POLICY_NAME \
    --profile COMPATIBLE  \
    --min-tls-version 1.0

SSL_POLICY_NAME=dev-boutique-ssl-policy
gcloud compute ssl-policies create $SSL_POLICY_NAME \
    --profile COMPATIBLE  \
    --min-tls-version 1.0

SSL_POLICY_NAME=ing-boutique-ssl-policy
gcloud compute ssl-policies create $SSL_POLICY_NAME \
    --profile COMPATIBLE  \
    --min-tls-version 1.0
