generate_hcl "_terramate_generated_main.tf" {
  content {
    module "vpc" {
      source      = "${terramate.stack.path.to_root}/terramate/modules/aws/vpc"
      name        = global.name
      region      = global.aws_region
      namespace   = global.namespace
      stage       = global.stage
      environment = global.environment

      ipv4_primary_cidr_block                 = global.ipv4_primary_cidr_block
      ipv4_additional_cidr_block_associations = global.ipv4_additional_cidr_block_associations
      ipv4_cidr_block_association_timeouts    = global.ipv4_cidr_block_association_timeouts

      assign_generated_ipv6_cidr_block = true

      default_security_group_deny_all       = global.default_security_group_deny_all
      default_route_table_no_routes         = global.default_route_table_no_routes
      default_network_acl_deny_all          = global.default_network_acl_deny_all
      network_address_usage_metrics_enabled = global.network_address_usage_metrics_enabled
      availability_zones                    = global.availability_zones

    }
  }
}






