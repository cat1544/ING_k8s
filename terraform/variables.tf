#vpc

variable "project_id" {
  type = string
  default = "trusty-mantra-398012"
}

variable "vpc_name" {
  type    = string
  default = "boutique"
}

#subnet
variable "subnet_name" {
  type    = string
  default = "boutique-service"
}

variable "ip_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "region" {
  type    = string
  default = "asia-northeast3"
}

#Artifact Registry

variable "location" {
  type    = string
  default = "asia-northeast3"
}

# variable "repository_id" {
#   type    = string
#   default = "boutique-service-images"
# }

# variable "format" {
#   type    = string
#   default = "DOCKER"
# }

#GKE - prod
# variable "gke-sa" {
#   type    = string
#   default = "gke-standard-sa"
# }

variable "prod-gke-name" {
  type    = string
  default = "prod-boutique"
}

variable "prod-service-nodes" {
  type    = string
  default = "prod-boutique-nodes"
}

variable "prod-argocd-nodes" {
  type    = string
  default = "prod-argocd-nodes"
}

#GKE - dev
# variable "dev-gke-name" {
#   type    = string
#   default = "dev-boutique"
# }

# variable "dev-service-nodes" {
#   type    = string
#   default = "dev-boutique-nodes"
# }

# variable "dev-argocd-nodes" {
#   type    = string
#   default = "dev-argocd-nodes"
# }


#GCS
# variable "backend" {
#   type    = string
#   default = "boutique_tf_backend"
# }

