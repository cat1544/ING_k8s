terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.82.0"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = "asia-northeast3"
}

locals {
  project_id = "yoondaegyoung-01-400304"
  region     = "asia-northeast3"
  location   = "asia-northeast3"
  service    = "boutique"
  env = "prod"

}

terraform {
  backend "gcs" {
    bucket = "boutique-tf-backend"
    prefix = "tfstate/prod/"
  }
}

module "vpc" {
  source = "../modules/vpc"

  project_id = local.project_id
  vpc_name   = "${local.service}-${local.env}"

  private_ip_name        = "prod-private"    #
  vpc_connection_service = "servicenetworking.googleapis.com" #
  name = "prod-allow-ingress-from-iap"
}

module "subnet" {
  source = "../modules/subnet"

  network       = module.vpc.network
  subnet_name   = "${local.env}-sbn"
  ip_cidr_range = "192.168.8.0/24"
  region        = local.region
}

module "prod-gke" {
  source = "../modules/gke"

  network = module.vpc.network
  subnet = module.subnet.subnetwork
  name                   = "${local.service}-${local.env}"
  location               = local.location
  master_ipv4_cidr_block = "192.168.16.0/28"
  peering = module.vpc.peering
  master_network_name = "${local.env}-master"
  noti_name = "prod_cluster_upgrade"
  pod_ip = "192.168.0.0/21"
  svc_ip = "192.168.9.0/24"

  label = {
    "app" : "boutique"
    "env" : "prod"
    "made" : "terraform"
}

  workload_identity_config = "${local.project_id}.svc.id.goog"
}

resource "google_service_account" "prod_sa" {
  account_id   = "prod-boutique-sa"
  display_name = "prod-boutique-sa"
}

resource "google_project_iam_binding" "node_svc_role" {
  project = local.project_id
  role    = "roles/container.nodeServiceAccount"
  members = [
    "serviceAccount:${google_service_account.prod_sa.email}",
  ]
}

resource "google_project_iam_binding" "ar_viewer" {
  project = local.project_id
  role    = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${google_service_account.prod_sa.email}",
  ]
}

module "prod-nodepool" {
  source         = "../modules/node-pool"
  node_pool_name = local.service
  location       = local.location
  initial_node_count = 1
  type = "custom-4-8192"
  disk_size      = 40
  max_pods = 64
  min_node = 1
  max_node = 3
  cluster_name        = module.prod-gke.cluster_name
  service_account = google_service_account.prod_sa.email

  label = {
    "env" : "prod"
    "app" : "boutique"
    "made" : "terraform"
  }
}

# resource "google_service_account" "argo_sa" {
#   account_id   = "prod-argo-sa"
#   display_name = "prod-argo-sa"
# }

# resource "google_project_iam_binding" "argo_node_role_binding" {
#   project = local.project_id
#   role    = "roles/container.nodeServiceAccount"
#   members = [
#     "serviceAccount:${google_service_account.argo_sa.email}",
#   ]
# }

module "argo-nodepool" {
  source         = "../modules/node-pool"
  node_pool_name = "argocd"
  location       = local.location
  initial_node_count = 1
  type = "e2-medium"
  disk_size      = 20
  max_pods = 64
  min_node = 1
  max_node = 1
  cluster_name        = module.prod-gke.cluster_name
  service_account = google_service_account.prod_sa.email

  label = {
    "env" : "prod"
    "app" : "argo"
    "made" : "terraform"
  }

  depends_on = [ google_service_account.prod_sa ]
}

module "bastion_vm" {
  source = "../modules/bastion"
  instance_name = "prod-bastion"
  project_id = local.project_id
  network = module.vpc.network
  subnetwork = module.subnet.subnetwork
  sa_email = google_service_account.defualt.email

  depends_on = [ module.prod-gke ]
}

