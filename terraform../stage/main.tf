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
  project_id = "trusty-mantra-398012"
  region     = "asia-northeast3"
  location   = "asia-northeast3"
  service    = "boutique"
  # env = ["dev", "prod"]

}

terraform {
  backend "gcs" {
    bucket = "boutique-tf"
    prefix = "tfstate/"
    # lock_timeout_seconds = 180
  }
}

module "vpc" {
  source = "../modules/vpc"

  project_id = local.project_id
  vpc_name   = local.service

  private_ip_name        = "private"    #
  vpc_connection_service = "servicenetworking.googleapis.com" #
}

module "subnet" {
  source = "../modules/subnet"

  network       = module.vpc.network
  subnet_name   = "${local.service}-sbn"
  ip_cidr_range = "10.0.0.0/16"
  region        = local.region
}


# =========================================
# ***************prod-cluster**************
# =========================================

module "prod-gke" {
  source = "../modules/gke"

  network = module.vpc.network
  subnet = module.subnet.subnetwork
#   private_ip_name        = "private"    #
#   vpc_connection_service = "servicenetworking.googleapis.com" #
  name                   = "${local.service}-prod"
  location               = local.location
  master_ipv4_cidr_block = "172.16.0.0/28"
  peering = module.vpc.peering
  cidr_block = module.subnet.ip_cidr_range
  master_network_name = "test"

#   resource_labels = {
#     "env" = "prod"
#   }

  workload_identity_config = "${local.project_id}.svc.id.goog"
}

module "prod-nodepool" {
  source         = "../modules/node-pool"
  node_pool_name = "prod-nodepool"
  location       = local.location
  disk_size      = 100
  cluster_name        = module.prod-gke.cluster_name

  label = {
    "env" : "prod"
  }
}

# =========================================
# ***************dev-cluster***************
# =========================================

# module "prod-gke" {
#     source = "../modules/gke"
# }

# module "prod-nodepool-service" {
#     source = "../modules/node-pool"
# }

# module "prod-nodepool-argocd" {
#     source = "../modules/node-pool"
# }

