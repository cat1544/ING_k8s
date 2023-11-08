output "network" {
  value = google_compute_network.vpc.self_link
}

output "peering" {
  value = google_service_networking_connection.private_vpc_connection.network
}