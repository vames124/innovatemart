output "cart_role_arn" {
  description = "IAM role ARN for the cart service (IRSA/DynamoDB)"
  value       = aws_iam_role.cart_dynamodb_role.arn
}

output "dev_user_access_key_id" {
  description = "Access key ID for the bedrock-dev-view IAM user"
  value       = aws_iam_access_key.dev_view.id
}

output "dev_user_secret_access_key" {
  description = "Secret access key for the bedrock-dev-view IAM user"
  value       = aws_iam_access_key.dev_view.secret
  sensitive   = true
}

output "dev_user_console_password" {
  description = "Console login password for the bedrock-dev-view IAM user"
  value       = aws_iam_user_login_profile.dev_view.password
  sensitive   = true
}

output "dev_user_arn" {
  description = "ARN of the bedrock-dev-view IAM user"
  value       = aws_iam_user.dev_view.arn
}

output "dev_user_name" {
  description = "Name of the developer IAM user"
  value       = aws_iam_user.dev_view.name
}
