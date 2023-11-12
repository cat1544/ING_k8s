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
    # lock_timeout_seconds = 180
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
#   private_ip_name        = "private"    #
#   vpc_connection_service = "servicenetworking.googleapis.com" #
  name                   = "${local.service}-${local.env}"
  location               = local.location
  master_ipv4_cidr_block = "192.168.16.0/28"
  peering = module.vpc.peering
  # cidr_block = "218.235.89.0/24"
  master_network_name = "${local.env}-master"
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

resource "google_project_iam_binding" "node_role_binding" {
  project = local.project_id
  role    = "roles/container.nodeServiceAccount"
  members = [
    "serviceAccount:${google_service_account.prod_sa.email}",
  ]
}

module "prod-nodepool" {
  source         = "../modules/node-pool"
  node_pool_name = local.service
  location       = local.location
  initial_node_count = 1
  type = "e2-highcpu-8"
  disk_size      = 40
  max_pods = 40
  min_node = 1
  max_node = 3
  cluster_name        = module.prod-gke.cluster_name
  service_account = google_service_account.prod_sa.email

  label = {
    "env" : "prod"
    "app" : "boutique"
  }
}

resource "google_service_account" "argo_sa" {
  account_id   = "prod-argo-sa"
  display_name = "prod-argo-sa"
}

resource "google_project_iam_binding" "argo_node_role_binding" {
  project = local.project_id
  role    = "roles/container.nodeServiceAccount"
  members = [
    "serviceAccount:${google_service_account.argo_sa.email}",
  ]
}

module "argo-nodepool" {
  source         = "../modules/node-pool"
  node_pool_name = "argocd"
  location       = local.location
  initial_node_count = 1
  type = "e2-standard-4"
  disk_size      = 20
  max_pods = 30
  min_node = 1
  max_node = 1
  cluster_name        = module.prod-gke.cluster_name
  service_account = google_service_account.argo_sa.email

  label = {
    "env" : "prod"
    "app" : "argo"
  }

  depends_on = [ google_service_account.argo_sa ]
}

# resource "google_service_account" "bastion_sa" {
#     account_id = "prod-bastion-sa"
#     display_name = "prod-bastion-sa"
# }

# resource "google_project_iam_binding" "container_developer_binding" {
#   project = local.project_id
#   role    = "roles/container.developer"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "iap_accessor_binding" {
#   project = local.project_id
#   role    = "roles/iap.httpsResourceAccessor"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "iap_tunnel_accessor_binding" {
#   project = local.project_id
#   role    = "roles/iap.tunnelResourceAccessor"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "role_create_binding" {
#   project = local.project_id
#   role    = "roles/container.clusterRoles.create"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "role_binding_create_binding" {
#   project = local.project_id
#   role    = "roles/container.roleBindings.create"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "cluster_role_create_binding" {
#   project = local.project_id
#   role    = "roles/container.roles.create"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "oauth_editor_binding" {
#   project = local.project_id
#   role    = "roles/oauthconfig.editor"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

module "bastion_vm" {
  source = "../modules/bastion"
  instance_name = "prod-bastion"
  project_id = local.project_id
  network = module.vpc.network
  subnetwork = module.subnet.subnetwork
  # sa_email = google_service_account.bastion_sa.email

  depends_on = [ module.prod-gke ]
}

