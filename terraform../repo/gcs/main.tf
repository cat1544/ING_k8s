resource "google_storage_bucket" "backend" {
  project = var.project_id
  name = var.project_id
  force_destroy = true
  location = var.location
  storage_class = "STANDARD" #autoclass
  versioning {
    enabled = true
  }
#  retention_policy {
#    is_locked = true
#    retention_period = var.retention_period
#   }

  labels = var.label 

  public_access_prevention = "enforced"
  uniform_bucket_level_access = true      #균일한 버킷 수준 액세스, 세부 권한 조정 시 삭제

  # condition {
  #   noncurrent_time_before = true
  # }
}

