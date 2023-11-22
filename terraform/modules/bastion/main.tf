# resource "google_service_account" "bastion_sa" {
#     account_id = "bastion-sa"
#     display_name = "bastion-sa"
# }

# resource "google_project_iam_binding" "container_developer_binding" {
#   project = var.project_id
#   role    = "roles/container.container.developer"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "service_agent_binding" {
#   project = var.project_id
#   role    = "roles/container.serviceAgent"
#   members = [
#     "serviceAccount:${google_service_account.bastion_sa.email}",
#   ]
# }

resource "google_service_account" "bastion_sa" {
  account_id   = "bastion-sa"
  display_name = "Custom SA for bastion"
}

resource "google_compute_instance" "bastion" {
    name = var.instance_name
    machine_type = "e2-medium"
    zone = "asia-northeast3-a"

    tags = ["bastion"]

    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-11"
        labels = {
          app : "boutique"
          made : "terraform"
        }
      }
    }
    # scratch_disk {
    #   interface = "NVME"
    # }
    
    network_interface {
      network = var.network
      subnetwork = var.subnetwork
      access_config {
        nat_ip = null
      }
    }

    metadata = {
      enable-oslogin : "TRUE"
      enable-oslogin-2fa : "TRUE"
    }

    metadata_startup_script = file("userdata.sh")

    service_account {
      email = google_service_account.bastion_sa.email
      scopes = ["cloud-platform"] # To allow full access to all Cloud APIs
    }
}
