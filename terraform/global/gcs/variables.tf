variable "backend_gcs_name" {
  type    = string
  default = "windy-furnace-404312"
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
  default = "windy-furnace-404312"
}
