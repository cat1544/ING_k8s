resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  #  mtu                     = var.mtu
}

# resource "google_compute_subnetwork" "subnet" {
#   name                     = var.subnet_name
#   ip_cidr_range            = var.ip_cidr_range
#   region                   = var.region
#   network                  = google_compute_network.vpc.id
#   private_ip_google_access = true

#   log_config {
#     aggregation_interval = "INTERVAL_10_MIN"
#     flow_sampling        = 0.5
#     metadata             = "INCLUDE_ALL_METADATA"
#   }
# }

resource "google_compute_global_address" "private_ip" {
  name          = var.private_ip_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = var.vpc_connection_service #"servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}