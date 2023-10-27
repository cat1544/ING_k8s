variable "node_pool_name" {
  type    = string
}

variable "location" {
  type    = string
}

variable "disk_size" {
  type    = number
}

variable "cluster_name" {}

variable "label" {
  type = map(string)
}