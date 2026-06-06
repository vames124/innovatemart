# ──────────────────────────────────────────────
# Outputs required for grading
# ──────────────────────────────────────────────

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "S3 assets bucket name"
  value       = module.serverless.bucket_name
}

# ──────────────────────────────────────────────
# IAM developer user outputs
# ──────────────────────────────────────────────

output "dev_user_access_key_id" {
  description = "IAM dev user access key ID"
  value       = module.iam.dev_user_access_key_id
}

output "dev_user_secret_access_key" {
  description = "IAM dev user secret access key"
  value       = module.iam.dev_user_secret_access_key
  sensitive   = true
}

output "dev_user_console_password" {
  description = "IAM dev user console login password"
  value       = module.iam.dev_user_console_password
  sensitive   = true
}

# ──────────────────────────────────────────────
# Database endpoints
# ──────────────────────────────────────────────

output "mysql_endpoint" {
  description = "MySQL (catalog) RDS endpoint"
  value       = module.rds.mysql_endpoint
}

output "postgres_endpoint" {
  description = "PostgreSQL (orders) RDS endpoint"
  value       = module.rds.postgres_endpoint
}
