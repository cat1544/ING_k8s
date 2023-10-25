# resource "google_service_account" "gke-sa" {
#   account_id   = var.gke-sa
#   display_name = "Service Account"
# }

resource "google_container_cluster" "prod-boutique" {
  name     = var.prod-gke-name
  location = var.location

  release_channel {
    channel = "REGULAR"
  }

  network = var.vpc_name
  subnetwork = var.subnet_name

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"

  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = true
    master_ipv4_cidr_block = "172.16.0.0/28"
  }

  ip_allocation_policy {
    # cluster_secondary_range_name = "pod-ip"
    # services_secondary_range_name = "svc-ip"
    cluster_ipv4_cidr_block = ""
    services_ipv4_cidr_block = ""
  }
  
  dns_config {
    cluster_dns = "PLATFORM_DEFAULT"
  }

  security_posture_config {
    mode = "BASIC"
    vulnerability_mode = "VULNERABILITY_BASIC"
  }

#   logging_service = "logging.googleapis.com/kubernetes"
#   monitoring_service = "none"
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled= false
    }
  }

  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

    # master_global_access_config {
    #   private_cluster_config.master_global_access_config = enabled #전역액세스
    # }
#   }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = google_compute_subnetwork.subnet.ip_cidr_range
      display_name = "test" # 승인된 네트워크
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  resource_labels = {
    "env" = "prod"
  }

  workload_identity_config {
    workload_pool = "trusty-mantra-398012.svc.id.goog"
  }

  depends_on = [ google_service_networking_connection.private_vpc_connection ]
}

#   maintenance_policy {
#     recurring_window {
#         daily_maintenance_window {
#             start_time = "02:00"
#         }
#         recurrence = "FREQ=WEEKLY;BYDAY=SU"
#     }
#   }


resource "google_container_node_pool" "prod-service_nodes" {
  name       = var.prod-service-nodes
  location   = var.location
  cluster    = google_container_cluster.prod-boutique.name
#  node_count = 3 autoscaling과 함께 사용 불가
  max_pods_per_node = 90

  node_config {
    preemptible  = true
    image_type = "COS_CONTAINERD"
    machine_type = "e2-medium"
    disk_size_gb = 100
    disk_type = "pd-balanced"
    labels = {
      "app" = "boutique"
      "env" = "dev"
    }
  }
  autoscaling {
    total_min_node_count = 3
    total_max_node_count = 6
    location_policy = "BALANCED"
  }
  network_config {
    # create_pod_range = true
    enable_private_nodes = true
    # pod_ipv4_cidr_block = ""
  }

  upgrade_settings {
    # max_surge = 1
    # max_unavailable = 1
    strategy = "BLUE_GREEN"
    blue_green_settings {
      node_pool_soak_duration = "10.0s"
      standard_rollout_policy {
        batch_percentage = 0.5
        batch_soak_duration = "10.0s"
      }
    } 
  }
}


# resource "google_container_node_pool" "prod-argocd_nodes" {
#   name       = var.prod-argocd-nodes
#   location   = var.location
#   cluster    = google_container_cluster.prod-boutique.name
#   node_count = 2

#   node_config {
#     preemptible  = true
#     machine_type = "e2-medium"

#   network_config {
#     create_pod_range = true
#     enable_private_nodes = true
#     pod_ipv4_cidr_block = "172.16.0.0/24"
#   }
# }