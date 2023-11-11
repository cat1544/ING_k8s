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

resource "google_project_service" "runtime_project" {
 project = var.project_id
 service = [
   "compute.googleapis.com",
   "cloudresourcemanager.googleapis.com",
   "iam.googleapis.com",
   "container.googleapis.com",
 ]
}

resource "google_service_account" "wlid_sa" {
  account_id   = "wlid-sa"
  display_name = "wlid-sa"
}

resource "google_project_iam_binding" "cluster_admin_binding" {
  project = var.project_id
  role    = "roles/container.clusterAdmin"
  members = [
    "serviceAccount:${google_service_account.wlid-sa.email}",
  ]
}

resource "google_project_iam_member" "workload_identity_user" {
  project   = var.project_id
  role      = "roles/iam.workloadIdentityUser"
  member    = "serviceAccount:${google_service_account.wlid_sa.email}"
  depends_on = [google_project_iam_binding.cluster_admin_binding]
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
