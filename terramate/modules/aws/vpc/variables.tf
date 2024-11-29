variable "region" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "default_security_group_deny_all" {
  type = bool
}

variable "default_route_table_no_routes" {
  type = bool
}

variable "default_network_acl_deny_all" {
  type = bool
}

variable "network_address_usage_metrics_enabled" {
  type = bool
}

variable "ipv4_primary_cidr_block" {
  default = "172.16.0.0/16"
}

variable "ipv4_additional_cidr_block_associations" {
  default = { "172.22.0.0/16" = {
    ipv4_cidr_block     = "172.22.0.0/16"
    ipv4_ipam_pool_id   = null
    ipv4_netmask_length = null
    }
  }
}

variable "ipv4_cidr_block_association_timeouts" {
  default = {
    create = "3m"
    delete = "5m"
  }
}
