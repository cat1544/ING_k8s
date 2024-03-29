resource "google_container_node_pool" "node-pool" {
  name       = var.node_pool_name
  location   = var.location
#  cluster    = google_container_cluster.cluster.name
#  node_count = 3 autoscaling과 함께 사용 불가
  cluster = var.cluster_name
  initial_node_count = var.initial_node_count
  max_pods_per_node = var.max_pods

  node_config {
    preemptible  = true
    image_type = "COS_CONTAINERD"
    machine_type = var.type
    disk_size_gb = var.disk_size
    disk_type = "pd-balanced"
    labels = var.label
    service_account = var.service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  autoscaling {
    # total_min_node_count = var.min_node
    # total_max_node_count = var.max_node
    min_node_count = var.min_node
    max_node_count = var.max_node
    location_policy = "BALANCED"
  }
  network_config {
    # create_pod_range = true
    enable_private_nodes = true
    # pod_ipv4_cidr_block = ""
  }

  upgrade_settings {
    max_surge = 1
    max_unavailable = 0
    #strategy = "BLUE_GREEN"
    #blue_green_settings {
    #  node_pool_soak_duration = "10.0s"
    #  standard_rollout_policy {
    #    batch_percentage = 0.5
    #    batch_soak_duration = "10.0s"
    #  }
    #} 
  }
}
