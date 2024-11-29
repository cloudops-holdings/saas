module "dynamodb" {
  source = "git::https://github.com/cloudposse/terraform-aws-dynamodb.git?ref=f312393109ce3d8688e75c671c6746a9fc4a49aa"

  name = var.name

  billing_mode = var.billing_mode
  hash_key     = "HashKey"
  range_key    = "RangeKey"

  context = module.this.context
}
