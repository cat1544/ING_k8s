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
  project_id = "fiery-cabinet-404400"
  region     = "asia-northeast3"
  location   = "asia-northeast3"
  service    = "boutique"
  env = "prod"

}

# terraform {
#   backend "gcs" {
#     bucket = "fiery-cabinet-404400"
#     prefix = "tfstate/prod/"
#     # lock_timeout_seconds = 180
#   }
# }

module "vpc" {
  source = "../modules/vpc"

  project_id = local.project_id
  vpc_name   = "${local.service}-${local.env}"

  private_ip_name        = "private-prod"    #
  vpc_connection_service = "servicenetworking.googleapis.com" #
  name = "prod-allow-ingress-from-iap"
}

module "subnet" {
  source = "../modules/subnet"

  network       = module.vpc.network
  subnet_name   = "${local.env}-sbn"
  ip_cidr_range = "10.0.0.0/16"
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
  master_ipv4_cidr_block = "172.16.0.0/28"
  peering = module.vpc.peering
  cidr_block = "218.235.89.0/24"
  master_network_name = "${local.env}-cp"

  label = {
    "app" : "boutique"
    "env" : "prod"
    "made" : "terraform"
}

  workload_identity_config = "${local.project_id}.svc.id.goog"
}

resource "google_service_account" "prod_sa" {
  account_id   = "prod-node-sa"
  display_name = "prod-node-sa"
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
  type = "e2-medium"
  disk_size      = 60
  max_pods = 90
  min_node = 3
  max_node = 6
  cluster_name        = module.prod-gke.cluster_name
  service_account = google_service_account.prod_sa.email

  label = {
    "env" : "prod"
    "app" : "boutique"
  }
}

resource "google_service_account" "bastion_sa" {
    account_id = "prod-bastion-sa"
    display_name = "prod-bastion-sa"
}

resource "google_project_iam_binding" "container_developer_binding" {
  project = local.project_id
  role    = "roles/container.developer"
  members = [
    "serviceAccount:${google_service_account.bastion_sa.email}",
  ]
}

module "bastion_vm" {
  source = "../modules/bastion"
  instance_name = "prod-bastion"
  project_id = local.project_id
  network = module.vpc.network
  subnetwork = module.subnet.subnetwork
  sa_email = google_service_account.bastion_sa.email

  depends_on = [ module.prod-gke ]
}