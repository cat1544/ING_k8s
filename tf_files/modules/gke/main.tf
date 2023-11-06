# resource "google_compute_global_address" "private_ip" {
#   name          = var.private_ip_name
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 16
#   network       = google_compute_network.vpc.id
# }

# resource "google_service_networking_connection" "private_vpc_connection" {
#   network                 = google_compute_network.vpc.id
#   service                 = var.vpc_connection_service
#   reserved_peering_ranges = [google_compute_global_address.private_ip.name]
# }

resource "google_container_cluster" "cluster" {
  name     = var.name
  location = var.location

  release_channel {
    channel = "REGULAR"
  }

  network = var.network
  subnetwork = var.subnet

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"

  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = var.master_ipv4_cidr_block
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
      # cidr_block = google_compute_subnetwork.subnet.ip_cidr_range
      # display_name = "test" # 승인된 네트워크
      cidr_block = var.cidr_block
      display_name = var.master_network_name
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

#  maintenance_policy {
#    recurring_window {
#      start_time = "17:00"
#      end_time  = "21:00"
#      #duration    = "4h"
#      recurrence = "FREQ=WEEKLY;BYDAY=MO,WE,SU"
#    }
#  }

  resource_labels = var.label

  # resource_labels = {
  #   "env" = "prod"
  # }

  workload_identity_config {
    workload_pool = var.workload_identity_config
  }

  depends_on = [ var.peering ]
  # depends_on = [ google_service_networking_connection.private_vpc_connection ]
}

#   maintenance_policy {
#     recurring_window {
#         daily_maintenance_window {
#             start_time = "02:00"
#         }
#         recurrence = "FREQ=WEEKLY;BYDAY=SU"
#     }
#   }
