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
  project_id = "windy-furnace-404312"
  region     = "asia-northeast3"
  location   = "asia-northeast3"
  service    = "boutique"
  env = "dev"
  # env = ["dev", "prod"]

}

terraform {
  backend "gcs" {
    bucket = "windy-furnace-404312"
    prefix = "tfstate/dev/"
    # lock_timeout_seconds = 180
  }
}

module "vpc" {
  source = "../modules/vpc"

  project_id = local.project_id
  vpc_name   = "${local.service}-${local.env}"

  private_ip_name        = "private"    #
  vpc_connection_service = "servicenetworking.googleapis.com" #
}

module "subnet" {
  source = "../modules/subnet"

  network       = module.vpc.network
  subnet_name   = "${local.env}-sbn"
  ip_cidr_range = "10.0.0.0/16"
  region        = local.region
}


# =========================================
# ***************prod-cluster**************
# =========================================

module "dev-gke" {
  source = "../modules/gke"

  network = module.vpc.network
  subnet = module.subnet.subnetwork
#   private_ip_name        = "private"    #
#   vpc_connection_service = "servicenetworking.googleapis.com" #
  name                   = "${local.service}-${local.env}"
  location               = local.location
  master_ipv4_cidr_block = "172.16.0.0/28"
  peering = module.vpc.peering
  cidr_block = "218.235.89.0/24"
  master_network_name = "${local.env}-cp"

  label = {
    "app" : "boutique"
    "env" : "dev"
    "made" : "terraform"
}

  workload_identity_config = "${local.project_id}.svc.id.goog"
}

resource "google_service_account" "dev-sa" {
  account_id   = "dev-sa"
  display_name = "Service Account"
}

# resource "google_project_iam_binding" "compute_admin_binding3" {
#   project = local.project_id
#   role    = "roles/compute.serviceAgent"
#   members = [
#     "serviceAccount:${google_service_account.dev-sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "compute_admin_binding6" {
#   project = local.project_id
#   role    = "roles/compute.instanceAdmin.v1"
#   members = [
#     "serviceAccount:${google_service_account.dev-sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "compute_admin_binding7" {
#   project = local.project_id
#   role    = "roles/iam.serviceAccountUser"
#   members = [
#     "serviceAccount:${google_service_account.dev-sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "compute_admin_binding8" {
#   project = local.project_id
#   role    = "roles/container.clusterAdmin"
#   members = [
#     "serviceAccount:${google_service_account.dev-sa.email}",
#   ]
# }

module "dev-nodepool" {
  source         = "../modules/node-pool"
  node_pool_name = local.service
  location       = local.location
  type = "e2-medium"
  disk_size      = 30
  max_pods = 50
  min_node = 0
  max_node = 3
  cluster_name        = module.dev-gke.cluster_name
  service_account = google_service_account.dev-sa.email
  label = {
    "env" : "dev"
    "app" : "boutique"
  }

  depends_on = [ google_service_account.dev-sa ]
}

resource "google_service_account" "argo-sa" {
  account_id   = "argo-sa"
  display_name = "argo-sa"
}

# resource "google_project_iam_binding" "compute_admin_binding1" {
#   project = local.project_id
#   role    = "roles/compute.serviceAgent"
#   members = [
#     "serviceAccount:${google_service_account.argo-sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "compute_admin_binding5" {
#   project = local.project_id
#   role    = "roles/compute.viewer"
#   members = [
#     "serviceAccount:${google_service_account.argo-sa.email}",
#   ]
# }


module "argo-nodepool" {
  source         = "../modules/node-pool"
  node_pool_name = "argocd"
  location       = local.location
  type = "e2-medium"
  disk_size      = 20
  max_pods = 20
  min_node = 2
  max_node = 3
  cluster_name        = module.dev-gke.cluster_name
  service_account = google_service_account.argo-sa.email

  label = {
    "env" : "dev"
    "app" : "argo"
  }

  depends_on = [ google_service_account.argo-sa ]
}

# resource "google_service_account" "bastion_sa" {
#     account_id = "bastion-sa"
#     display_name = "bastion-sa"
# }

# resource "google_project_iam_binding" "container_developer_binding" {
#   project = local.project_id
#   role    = "roles/container.developer"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "service_agent_binding" {
#   project = local.project_id
#   role    = "roles/container.serviceAgent"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "compute_admin_binding" {
#   project = local.project_id
#   role    = "roles/compute.serviceAgent"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# module "bastion_vm" {
#   source = "../modules/bastion"
#   instance_name = "dev-bastion"
#   project_id = local.project_id
#   network = module.vpc.network
#   sa_email = google_service_account.bastion_sa.email

#   depends_on = [ module.dev-gke ]
# }