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
  project_id = "subtle-display-404304"
  region     = "asia-northeast3"
  location   = "asia-northeast3"
  service    = "boutique"
  env = "prod"

}

terraform {
  backend "gcs" {
    bucket = "subtle-display-404304"
    prefix = "tfstate/prod/"
    # lock_timeout_seconds = 180
  }
}

module "vpc" {
  source = "../modules/vpc"

  project_id = local.project_id
  vpc_name   = "${local.service}-${local.env}"

  private_ip_name        = "private-prod"    #
  vpc_connection_service = "servicenetworking.googleapis.com" #
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

resource "google_service_account" "prod-sa" {
  account_id   = "prod-sa"
  display_name = "prod-sa"
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
  service_account = google_service_account.prod-sa.email

  label = {
    "env" : "prod"
    "app" : "boutique"
  }
}

data "google_service_account" "prod-bastion" {
  account_id = "bastion-sa"
}

module "bastion_vm" {
  source = "../modules/bastion"
  instance_name = "prod-bastion"
  project_id = local.project_id
  network = module.vpc.network
  sa_email = data.google_service_account.prod-bastion.name

  depends_on = [ module.prod-gke ]
}