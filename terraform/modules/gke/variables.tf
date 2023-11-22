# variable "private_ip_name" {
#   type    = string
# }

# variable "vpc_connection_service" {
#   type    = string
# }

variable "name" {
  type    = string
}


variable "location" {
  type    = string
}

variable "network" {
  type    = string
}

variable "subnet" {
  type    = string
}

variable "master_ipv4_cidr_block" {
  type    = string
}

variable "label" {
  type    = map(string)
}

variable "workload_identity_config" {
  type    = string
}

# variable "cidr_block" {}
variable "master_network_name" {}
variable "peering" {}
variable "pod_ip" {}
variable "svc_ip" {}
variable "noti_name" {}
