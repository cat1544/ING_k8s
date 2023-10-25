# resource "google_artifact_registry_repository" "gar" {
#   location      = var.location
#   repository_id = var.repository_id
# #description   = var.description
#   format        = var.ar_format

#   docker_config {
#     immutable_tags = true
#   }
# }