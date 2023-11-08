variable "node_pool_name" {
  type    = string
}

variable "location" {
  type    = string
}

variable "type" {
  type    = string
}

variable "disk_size" {
  type    = number
}

variable "cluster_name" {}

variable "label" {
  type = map(string)
}

variable "max_pods" {
  type = number
}

variable "min_node" {
  type = number
}

variable "max_node" {
  type = number
}

variable "service_account" {
  type = string
}

