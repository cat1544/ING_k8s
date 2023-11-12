variable "backend_gcs_name" {
  type    = string
  default = "boutique-tf-backend"
}

variable "label" {
  type = map(string)
  default = {
    "app" : "boutique"
    "made" : "terraform"
  }
}

variable "location" {
  type    = string
  default = "asia-northeast3"
}

variable "project_id" {
  default = "yoondaegyoung-01-400304"
}
