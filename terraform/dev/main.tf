terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.82.0"
    }
  }
}

provider "google" {
  project = "yoondaegyoung-01-400304"
  region  = "asia-northeast3"
}

locals {
  project_id = "yoondaegyoung-01-400304"
  region     = "asia-northeast3"
  location   = "asia-northeast3"
  service    = "boutique"
  env = "dev"
}

terraform {
  backend "gcs" {
    bucket = "boutique-tf-backend"
    prefix = "tfstate/dev/"
  }
}

module "vpc" {
  source = "../modules/vpc"

  project_id = local.project_id
  vpc_name   = "${local.service}-${local.env}"

  private_ip_name        = "dev-private"    #
  vpc_connection_service = "servicenetworking.googleapis.com" #
  name = "dev-allow-ingress-from-iap"
}

module "subnet" {
  source = "../modules/subnet"

  network       = module.vpc.network
  subnet_name   = "${local.env}-sbn"
  ip_cidr_range = "172.16.8.0/24"
  region        = local.region
}

# =========================================
# ***************prod-cluster**************
# =========================================

module "dev-gke" {
  source = "../modules/gke"

  network = module.vpc.network
  subnet = module.subnet.subnetwork
  name                   = "${local.service}-${local.env}"
  location               = local.location
  master_ipv4_cidr_block = "172.16.16.0/28"
  pod_ip = "172.16.0.0/21"
  svc_ip = "172.16.9.0/24"
  peering = module.vpc.peering
  master_network_name = "${local.env}-master"
  noti_name = "dev_cluster_upgrade"

  label = {
    "app" : "boutique"
    "env" : "dev"
    "made" : "terraform"
  }

  workload_identity_config = "${local.project_id}.svc.id.goog"
}

resource "google_service_account" "dev_sa" {
  account_id   = "dev-boutique-sa"
  display_name = "dev-boutique-sa"
}

resource "google_project_iam_binding" "node_svc_role" {
  project = local.project_id
  role    = "roles/container.nodeServiceAccount"
  members = [
    "serviceAccount:${google_service_account.dev_sa.email}",
  ]
}

resource "google_project_iam_binding" "ar_viewer" {
  project = local.project_id
  role    = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${google_service_account.dev_sa.email}",
  ]
}

module "dev-nodepool" {
  source         = "../modules/node-pool"
  node_pool_name = local.service
  location       = local.location
  initial_node_count = 1
  type = "custom-4-8192"
  disk_size      = 40
  max_pods = 64
  min_node = 0
  max_node = 2
  cluster_name        = module.dev-gke.cluster_name
  service_account = google_service_account.dev_sa.email
  label = {
    "env" : "dev"
    "app" : "boutique"
    "made" : "terraform"
  }

  depends_on = [ google_service_account.dev_sa ]
}

# resource "google_service_account" "argo_sa" {
#   account_id   = "dev-argo-sa"
#   display_name = "dev-argo-sa"
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
  # type = "e2-medium"
  type = "e2-medium"
  initial_node_count = 1
  disk_size      = 20
  max_pods = 64
  min_node = 1
  max_node = 1
  cluster_name        = module.dev-gke.cluster_name
  service_account = google_service_account.dev_sa.email

  label = {
    "env" : "dev"
    "app" : "argo"
    "made" : "terraform"
  }

  depends_on = [ google_service_account.dev_sa ]
}

# resource "google_service_account" "bastion_sa" {
#     account_id = "dev-bastion-sa"
#     display_name = "dev-bastion-sa"
# }

# resource "google_project_iam_binding" "container_developer_binding" {
#   project = local.project_id
#   role    = "roles/container.developer"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

module "bastion_vm" {
  source = "../modules/bastion"
  instance_name = "dev-bastion"
  project_id = local.project_id
  network = module.vpc.network
  subnetwork = module.subnet.subnetwork
  sa_email = google_service_account.default.email

  depends_on = [ module.dev-gke ]
}
