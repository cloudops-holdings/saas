stack {
  name        = "dynamodb"
  description = "setup dynamodb for terraform using cloudposse module"
  id          = "92be4afd-ef07-4d50-9a29-0443f06066eb"
}

globals {
  terraform_key = "aws/terraform/dynamodb/terraform.tfstate"
}

import {
  source = "/terramate/modules/aws/dynamodb/terramate.tm"
}
