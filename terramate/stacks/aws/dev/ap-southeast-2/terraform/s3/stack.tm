stack {
  name        = "bucket"
  description = "setup s3 bucket for terraform using cloudposse module"
  id          = "92be4afd-ef07-4d50-9a29-0443f06066ec"
}

globals {
  terraform_key = "aws/terraform/s3/terraform.tfstate"

  acl = "private"

  force_destroy = true

  user_enabled = true

  versioning_enabled = false

  allowed_bucket_actions = [
    "s3:PutObject",
    "s3:PutObjectAcl",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:GetBucketLocation",
    "s3:AbortMultipartUpload"
  ]

  bucket_key_enabled = true

  minimum_tls_version = "1.2"
}

import {
  source = "/terramate/modules/aws/s3/terramate.tm"
}
