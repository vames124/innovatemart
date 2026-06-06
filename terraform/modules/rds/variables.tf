variable "vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "eks_node_sg_id" {
  description = "Security group ID of EKS nodes (for ingress rules)"
  type        = string
}

variable "catalog_db_username" {
  description = "Username for the catalog MySQL database"
  type        = string
}

variable "catalog_db_password" {
  description = "Password for the catalog MySQL database"
  type        = string
  sensitive   = true
}

variable "orders_db_username" {
  description = "Username for the orders PostgreSQL database"
  type        = string
}

variable "orders_db_password" {
  description = "Password for the orders PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "project_tag" {
  description = "Project tag for all resources"
  type        = string
}
