output "table_arn" {
  description = "ARN of the DynamoDB carts table"
  value       = aws_dynamodb_table.carts.arn
}

output "table_name" {
  description = "Name of the DynamoDB carts table"
  value       = aws_dynamodb_table.carts.name
}
