locals {
  create_managed_policies = {
    "terraform-exec-compute"                 = data.aws_iam_policy_document.compute.json
    "terraform-exec-database-storage"        = data.aws_iam_policy_document.database_storage.json
    "terraform-exec-application-integration" = data.aws_iam_policy_document.application_integration.json
    "terraform-exec-business-applications"   = data.aws_iam_policy_document.business_applications.json
    "terraform-exec-data"                    = data.aws_iam_policy_document.data.json
    "terraform-exec-management"              = data.aws_iam_policy_document.management.json
  }
}

#---------------------------------------------------------------------------------------------------
# Terraform Execution Role
#---------------------------------------------------------------------------------------------------

module "terraform_assume_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.3"

  create_role = true

  role_name         = "terraform-execution-role"
  role_path         = "/devops/"
  role_description  = "Allows another account to this role to perform Terraform resource management."
  role_requires_mfa = false

  custom_role_policy_arns = concat(
    [module.terraform_remote_state.terraform_exe_aws_iam_policy_arn],
    [for policy in module.terraform_exec_iam_policy : policy.arn]
  )
  number_of_custom_role_policy_arns = 1 + length(keys(local.create_managed_policies))

  tags = merge(local.tags, { Name = "terraform-execution-role" })
}

#---------------------------------------------------------------------------------------------------
# Terraform Resource Management Execution Policies
#---------------------------------------------------------------------------------------------------

module "terraform_exec_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  for_each = local.create_managed_policies

  name        = each.key
  path        = "/devops/"
  description = "Managed IAM Policy to allow Terraform role to manage resources"
  policy      = each.value
}

#---------------------------------------------------------------------------------------------------
# Compute
# - Lambda
# - EC2
# - EC2 Image Builder
# - ECR
# - ECS
# - EKS
# - API Gateway
# - CloudFront
# - Route53
#---------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "compute" {
  statement {
    sid    = "LambdaFullAccess"
    effect = "Allow"
    actions = [
      "lambda:*",
      "states:*",
    ]
    resources = ["*"]
  }
  statement {
    sid       = "EC2FullAccess"
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ImageBuilderFullAccess"
    effect    = "Allow"
    actions   = ["imagebuilder:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ECRFullAccess"
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["*"]
  }
  statement {
    sid    = "ECSFullAccess"
    effect = "Allow"
    actions = [
      "ecs:*",
      "application-autoscaling:*"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "EKSFullAccess"
    effect    = "Allow"
    actions   = ["eks:*"]
    resources = ["*"]
  }
  statement {
    sid       = "APIGatewayFullAccess"
    effect    = "Allow"
    actions   = ["apigateway:*"]
    resources = ["*"]
  }
  statement {
    sid    = "CloudfrontScopedManagedAccess"
    effect = "Allow"
    actions = [
      "cloudfront:Create*",
      "cloudfront:Describe*",
      "cloudfront:TagResource",
      "cloudfront:UntagResource",
    ]
    resources = ["*"]
  }
  statement {
    sid       = "Route53GatewayFullAccess"
    effect    = "Allow"
    actions   = ["route53:*"]
    resources = ["*"]
  }
  statement {
    sid       = "CreateTargetGroup"
    effect    = "Allow"
    actions   = ["elasticloadbalancing:*"]
    resources = ["*"]
  }

  statement {
    sid    = "applicationautoscaling"
    effect = "Allow"
    actions = [
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:PutScalingPolicy"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "KafkaFullAccess"
    effect    = "Allow"
    actions   = ["kafka:*"]
    resources = ["*"]
  }

}

#---------------------------------------------------------------------------------------------------
# Database Storage
# - S3
# - Backup
# - DynamoDb
# - RDS
# - Elasticache
#---------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "database_storage" {
  statement {
    sid    = "S3ScopedAccess"
    effect = "Allow"
    actions = [
      "s3:BypassGovernanceRetention",
      "s3:Create*",
      "s3:Get*",
      "s3:ListBucket*",
      "s3:ListAllMyBuckets",
      "s3:PutAccountPublicAccessBlock",
      "s3:PutAnalyticsConfiguration",
      "s3:PutAnalyticsConfiguration",
      "s3:PutBucket*",
      "s3:PutInventoryConfiguration",
      "s3:PutIntelligentTieringConfiguration",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutMetricsConfiguration",
      "s3:PutObject*",
      "s3:PutReplicationConfiguration*",
      "s3:Replicate*",
      "s3:RestoreObject",
      "s3:DeleteBucketPolicy",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "BackupScopedAccess"
    effect = "Allow"
    actions = [
      "backup:Create*",
      "backup:Describe*",
      "backup:List*",
      "backup:PutBackup*",
      "backup:TagResource",
      "backup:UntagResource",
      "backup:Update*",
      "backup:GetBackupVaultNotifications",
    ]
    resources = ["*"]
  }
  statement {
    sid       = "DynamoDBFullAccess"
    effect    = "Allow"
    actions   = ["dynamodb:*", "dax:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ElasticacheFullAccess"
    effect    = "Allow"
    actions   = ["elasticache:*"]
    resources = ["*"]
  }
  statement {
    sid       = "RDSFullAccess"
    effect    = "Allow"
    actions   = ["rds:*"]
    resources = ["*"]
  }
  statement {
    sid       = "OpenSearchFullAccess"
    effect    = "Allow"
    actions   = ["es:*"]
    resources = ["*"]
  }
}

#---------------------------------------------------------------------------------------------------
# Application Integration
# - SNS
# - SQS
# - EventBridge
#---------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "application_integration" {
  statement {
    sid       = "SQSFullAccess"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = ["*"]
  }
  statement {
    sid       = "SNSFullAccess"
    effect    = "Allow"
    actions   = ["sns:*"]
    resources = ["*"]
  }
  statement {
    sid       = "EventBridgeFullAccess"
    effect    = "Allow"
    actions   = ["events:*"]
    resources = ["*"]
  }
  statement {
    sid    = "TransferUserManagement"
    effect = "Allow"
    actions = [
      "transfer:CreateUser",
      "transfer:DescribeUser",
      "transfer:ListUsers", "transfer:UpdateUser",
      "transfer:DeleteUser", "transfer:TagResource",
      "transfer:UntagResource",
      "transfer:ImportSshPublicKey"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "ServerlessFullAccess"
    effect    = "Allow"
    actions   = ["serverlessrepo:*"]
    resources = ["*"]
  }
}

#---------------------------------------------------------------------------------------------------
# Business Applications
# - SES
# - Pinpoint
#---------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "business_applications" {
  statement {
    sid       = "SESFullAccess"
    effect    = "Allow"
    actions   = ["ses:*"]
    resources = ["*"]
  }
  statement {
    sid       = "PinpointFullAccess"
    effect    = "Allow"
    actions   = ["pinpoint:*"]
    resources = ["*"]
  }
  statement {
    sid       = "pinpointapp"
    effect    = "Allow"
    actions   = ["mobiletargeting:*"]
    resources = ["*"]
  }
  statement {
    sid       = "LocationFullAccess"
    effect    = "Allow"
    actions   = ["geo:*"]
    resources = ["*"]
  }
}

#---------------------------------------------------------------------------------------------------
# Analytics
# - Kinesis
# - Elasticsearch
# - Redshift
# - Athena
# - Sagemaker
# - Rekognition
#---------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "data" {
  statement {
    sid       = "SageMakerFullAccess"
    effect    = "Allow"
    actions   = ["sagemaker:*"]
    resources = ["*"]
  }
  statement {
    sid       = "RekognitionFullAccess"
    effect    = "Allow"
    actions   = ["rekognition:*"]
    resources = ["*"]
  }
  statement {
    sid       = "KinesisFullAccess"
    effect    = "Allow"
    actions   = ["kinesis:*"]
    resources = ["*"]
  }
  statement {
    sid       = "firehose"
    effect    = "Allow"
    actions   = ["firehose:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ElasticsearchFullAccess"
    effect    = "Allow"
    actions   = ["elasticsearch:*"]
    resources = ["*"]
  }
  statement {
    sid       = "RedshiftFullAccess"
    effect    = "Allow"
    actions   = ["redshift:*"]
    resources = ["*"]
  }
  statement {
    sid       = "AthenaFullAccess"
    effect    = "Allow"
    actions   = ["athena:*"]
    resources = ["*"]
  }
  statement {
    sid       = "AirflowFullAccess"
    effect    = "Allow"
    actions   = ["airflow:*"]
    resources = ["*"]
  }
}

#---------------------------------------------------------------------------------------------------
# Management
# - Account
# - Cloudwatch
# - Auto Scaling
# - CloudFormation
# - Systems Manager
# - AppConfig
# - Config
# - Secrets Manager
# - SSM
# - ACM
# - KMS
# - WAF
# - Transfer Family
#---------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "management" {
  statement {
    sid       = "AccountListRegionAccess"
    effect    = "Allow"
    actions   = ["account:ListRegions"]
    resources = ["*"]
  }
  statement {
    sid       = "CloudwatchFullAccess"
    effect    = "Allow"
    actions   = ["cloudwatch:*", "logs:*"]
    resources = ["*"]
  }
  statement {
    sid    = "AutoScalingFullAccess"
    effect = "Allow"
    actions = [
      "autoscaling:*",
      "autoscaling-plans:*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "CloudFormationFullAccess"
    effect = "Allow"
    actions = [
      "cloudformation:*",
      "resource-groups:*",
      "resource-explorer:List*",
      "tag:GetResources",
      "tag:TagResources",
      "tag:UntagResources",
      "tag:getTagKeys",
      "tag:getTagValues"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "SystemsManagerFullAccess"
    effect    = "Allow"
    actions   = ["ssm:*", "appconfig:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ConfigFullAccess"
    effect    = "Allow"
    actions   = ["config:*"]
    resources = ["*"]
  }
  statement {
    sid    = "IAMScopedManageAccess"
    effect = "Allow"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:Attach*",
      "iam:CreateInstanceProfile",
      "iam:CreatePolicy*",
      "iam:CreateRole*",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteInstanceProfile",
      "iam:DeletePolicy*",
      "iam:DeleteRole*",
      "iam:DeleteServiceLinkedRole",
      "iam:Detach*",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:Get*",
      "iam:List*",
      "iam:PutRole*",
      "iam:PassRole",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:SetDefaultPolicyVersion",
      "iam:Tag*",
      "iam:Untag*",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole*",
    ]
    resources = ["*"]
  }
  statement {
    sid       = "SecretsManagerFullAccess"
    effect    = "Allow"
    actions   = ["secretsmanager:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ACMFullAccess"
    effect    = "Allow"
    actions   = ["acm:*"]
    resources = ["*"]
  }
  statement {
    sid       = "KMSFullAccess"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid       = "Cognito"
    effect    = "Allow"
    actions   = ["cognito-idp:*"]
    resources = ["*"]
  }
  statement {
    sid       = "WAFFullAccess"
    effect    = "Allow"
    actions   = ["wafv2:*"]
    resources = ["*"]
  }
  statement {
    sid       = "TransferFamilyFullAccess"
    effect    = "Allow"
    actions   = ["transfer:*"]
    resources = ["*"]
  }
  statement {
    sid       = "CloudFrontFullAccess"
    effect    = "Allow"
    actions   = ["cloudfront:*"]
    resources = ["*"]
  }
  statement {
    sid    = "EKSAccess"
    effect = "Allow"
    actions = [
      "eks:*",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider"
    ]
    resources = ["*"]
  }
}
