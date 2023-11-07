terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.82.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "asia-northeast3"
}

# resource "google_service_account" "postdb_user_sa" {
#   account_id   = "postdb-user-sa"
#   display_name = "postdb-user-sa"
# }

# resource "google_project_iam_binding" "cloudsql_admin_binding" {
#   project = var.project_id
#   role    = "roles/cloudsql.admin"
#   members = [
#     "serviceAccount:${google_service_account.postdb_user_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "secretmanager_accessor_binding" {
#   project = var.project_id
#   role    = "roles/secretmanager.secretAccessor"
#   members = [
#     "serviceAccount:${google_service_account.postdb_user_sa.email}",
#   ]
# }

# resource "google_project_iam_member" "workload_identity_user" {
#   project   = var.project_id
#   role      = "roles/iam.workloadIdentityUser"
#   member    = "serviceAccount:${google_service_account.postdb_user_sa.email}"
#   depends_on = [google_project_iam_binding.cloudsql_admin_binding, google_project_iam_binding.secretmanager_accessor_binding]
# }

# cluster
resource "google_service_account" "gke_sa" {
  account_id   = "gke-sa"
  display_name = "gke-sa"
}

resource "google_project_iam_binding" "cluster_admin_binding" {
  project = var.project_id
  role    = "roles/container.clusterAdmin"
  members = [
    "serviceAccount:${google_service_account.gke_sa.email}",
  ]
}

# resource "google_project_iam_member" "workload_identity_user" {
#   project   = var.project_id
#   role      = "roles/iam.workloadIdentityUser"
#   member    = "serviceAccount:${google_service_account.postdb_user_sa.email}"
#   depends_on = [google_project_iam_binding.cloudsql_admin_binding, google_project_iam_binding.secretmanager_accessor_binding]
# }

resource "google_project_iam_member" "workload_identity_user" {
  project   = var.project_id
  role      = "roles/iam.workloadIdentityUser"
  member    = "serviceAccount:${google_service_account.gke_sa.email}"
  depends_on = [google_project_iam_binding.cluster_admin_binding]
}

# resource "google_project_iam_binding" "workload_identity_user_binding" {
#   project = var.project_id
#   role    = "roles/iam.workloadIdentityUser"
#   members = [
#     "serviceAccount:${google_service_account.postdb_user_sa.email}",
#     "serviceAccount:${google_service_account.gke_sa.email}",
#   ]
#   depends_on = [google_project_iam_binding.cloudsql_admin_binding, google_project_iam_binding.secretmanager_accessor_binding, google_project_iam_binding.cluster_admin_binding]
# }