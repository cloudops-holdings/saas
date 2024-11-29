stack {
  name        = "oidc"
  description = "setup oidc for terraform to access aws on github"
  id          = "92be4afd-ef07-4d50-9a29-0443f06066ee"
}

globals {
  terraform_key = "aws/terraform/oidc/terraform.tfstate"
}

generate_hcl "_terramate_generated_main.tf" {
  content {
    module "aws_oidc_github" {
      source               = "${terramate.stack.path.to_root}/terramate/modules/aws/oidc-github"
      github_organizations = [global.company]

      iam_role_path = "/devops/"

      iam_role_policy_arns = concat(
        [module.terraform_remote_state.terraform_exe_aws_iam_policy_arn],
        [for policy in module.terraform_exec_iam_policy : policy.arn]
      )
    }
  }
}

