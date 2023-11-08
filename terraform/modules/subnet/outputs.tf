output "subnetwork" {
    value =   google_compute_subnetwork.subnet.self_link
}

output "ip_cidr_range" {
    value =   google_compute_subnetwork.subnet.ip_cidr_range
}