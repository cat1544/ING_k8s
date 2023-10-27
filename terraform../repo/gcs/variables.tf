variable "backend_gcs_name" {
  type    = string
  default = "boutique-tf"
}

# variable "label_key" {
#   type    = string
# #   default = "boutique_tf_backend"
# }

# variable "label_value" {
#   type    = string
# #   default = "boutique_tf_backend"
# }

variable "retention_period" {
  type    = number
  default = 60
}

variable "location" {
  type    = string
  default = "asia-northeast3"
}

variable "project_id" {
  default = "trusty-mantra-398012"
}
