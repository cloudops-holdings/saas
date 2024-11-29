module "vpc" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=<SHA>"

  ipv4_primary_cidr_block                 = var.ipv4_primary_cidr_block
  ipv4_additional_cidr_block_associations = var.ipv4_additional_cidr_block_associations
  ipv4_cidr_block_association_timeouts    = var.ipv4_cidr_block_association_timeouts

  assign_generated_ipv6_cidr_block = true

  default_security_group_deny_all       = var.default_security_group_deny_all
  default_route_table_no_routes         = var.default_route_table_no_routes
  default_network_acl_deny_all          = var.default_network_acl_deny_all
  network_address_usage_metrics_enabled = var.network_address_usage_metrics_enabled
  context                               = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.0.4"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}
