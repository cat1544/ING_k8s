variable "backend_gcs_name" {
  type    = string
  default = "yoondaegyoung-01-400304"
}

variable "label" {
  type = map(string)
  default = {
    "app" : "boutique"
  }
}

variable "location" {
  type    = string
  default = "asia-northeast3"
}

variable "project_id" {
  default = "yoondaegyoung-01-400304"
}