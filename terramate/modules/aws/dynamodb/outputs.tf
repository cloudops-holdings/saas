output "table_name" {
  value       = module.dynamodb.table_name
  description = "DynamoDB table name"
}

output "table_arn" {
  value       = module.dynamodb.table_arn
  description = "DynamoDB table ARN"
}

