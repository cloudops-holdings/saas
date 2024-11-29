variable "region" {
  type        = string
  description = "AWS region"
}
variable "billing_mode" {
  type        = string
  default     = "PAY_PER_REQUEST"
  description = "DynamoDB Billing mode. Can be PROVISIONED or PAY_PER_REQUEST"
}
