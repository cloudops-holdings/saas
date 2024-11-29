# AWS federation for GitHub Actions

Terraform module to configure GitHub Actions as an IAM OIDC identity provider in
AWS. This enables GitHub Actions to access resources within an AWS account
without requiring long-lived credentials to be stored as GitHub secrets.

## 🔨 Getting started

### Installation and usage

The following snippet shows the minimum required configuration to create a
working OIDC connection between GitHub Actions and AWS.

```terraform
provider "aws" {
  region = var.region
}

module "aws_oidc_github" {
  source  = "./modules/oidc-github"

  github_organizations = [
    "some-org",
    "another-org",
  ]
}
```

The following demonstrates how to use GitHub Actions once the Terraform module
has been applied to your AWS account. The action receives a JSON Web Token (JWT)
from the GitHub OIDC provider and then requests an access token from AWS.

```yaml
jobs:
  caller-identity:
    name: Check caller identity
    permissions:
      contents: read
      id-token: write
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-region: ${{ secrets.AWS_REGION }}
        role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/devops/github
    - run: aws sts get-caller-identity
```
