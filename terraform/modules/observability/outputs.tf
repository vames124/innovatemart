output "cloudwatch_agent_role_arn" {
  description = "IAM role ARN for the CloudWatch Agent (IRSA)"
  value       = aws_iam_role.cloudwatch_agent_irsa.arn
}

output "fluentbit_role_arn" {
  description = "IAM role ARN for Fluent Bit (IRSA)"
  value       = aws_iam_role.fluentbit_irsa.arn
}

output "application_log_group" {
  description = "CloudWatch log group for application logs"
  value       = aws_cloudwatch_log_group.eks_application.name
}

output "dataplane_log_group" {
  description = "CloudWatch log group for dataplane logs"
  value       = aws_cloudwatch_log_group.eks_dataplane.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = aws_sns_topic.eks_alerts.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.eks.dashboard_name
}
