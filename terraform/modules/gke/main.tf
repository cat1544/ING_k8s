resource "google_pubsub_topic" "cluster_topic" {
  name = var.noti_name

  labels = {
    "made" : "terraform"
  }  
}

resource "google_container_cluster" "cluster" {
  name     = var.name
  location = var.location

  release_channel {
    channel = "STABLE" #STABLE
  }
  #master_version = "1.27.3-gke.100"
  network = var.network
  subnetwork = var.subnet

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"

  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = true
    master_ipv4_cidr_block = var.master_ipv4_cidr_block
    master_global_access_config {
      enabled = true
    }
  }

  ip_allocation_policy {
    # cluster_secondary_range_name = "pod-ip"
    # services_secondary_range_name = "svc-ip"
    cluster_ipv4_cidr_block = var.pod_ip
    services_ipv4_cidr_block = var.svc_ip
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

  master_authorized_networks_config {
    cidr_blocks {
      # cidr_block = google_compute_subnetwork.subnet.ip_cidr_range
      # display_name = "test" # 승인된 네트워크
      cidr_block = "10.0.0.0/16"
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

  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
    maintenance_exclusion {
      exclusion_name = "sale_festa"
      start_time = "2023-11-01T00:00:00Z"
      end_time = "2023-11-15T00:00:00Z"
      exclusion_options {
        scope = "NO_UPGRADES"
      }
    }
  }

  resource_labels = var.label

  workload_identity_config {
    workload_pool = var.workload_identity_config
  }

  notification_config {
    pubsub {
      enabled = "true"
      topic = google_pubsub_topic.cluster_topic.id
      filter {
        event_type = ["UPGRADE_AVAILABLE_EVENT", "UPGRADE_EVENT"]
      }
    }
  }

  depends_on = [ var.peering ]
}

#   maintenance_policy {
#     recurring_window {
#         daily_maintenance_window {
#             start_time = "02:00"
#         }
#         recurrence = "FREQ=WEEKLY;BYDAY=SU"
#     }
#   }
