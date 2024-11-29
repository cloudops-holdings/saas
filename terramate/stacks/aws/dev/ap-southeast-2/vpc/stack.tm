stack {
  name        = "vpc"
  description = "setup vpc and network using cloudposse module"
  id          = "92be4afd-ef07-4d50-9a29-0443f06066ea"
}

globals {
  name      = "dev"
  namespace = "terraform"

  ipv4_primary_cidr_block               = "172.16.0.0/16"
  availability_zones                    = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  default_security_group_deny_all       = true
  default_route_table_no_routes         = true
  default_network_acl_deny_all          = true
  network_address_usage_metrics_enabled = true
  assign_generated_ipv6_cidr_block      = true

  ipv4_additional_cidr_block_associations = {
    "172.22.0.0/16" = {
      ipv4_cidr_block     = "172.22.0.0/16"
      ipv4_ipam_pool_id   = null
      ipv4_netmask_length = null
    }
  }

  ipv4_cidr_block_association_timeouts = {
    create = "3m"
    delete = "5m"
  }
}

import {
  source = "/terramate/modules/aws/vpc/terramate.tm"
}
