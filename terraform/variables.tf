variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "project-bedrock-cluster"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "project-bedrock-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "student_id" {
  description = "Student ID used for resource naming"
  type        = string
  default     = "alt-soe-025-4486"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "eks_node_min" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "eks_node_max" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "catalog_db_username" {
  description = "Username for the catalog MySQL database"
  type        = string
  default     = "catalog_admin"
}

variable "catalog_db_password" {
  description = "Password for the catalog MySQL database"
  type        = string
  sensitive   = true
}

variable "orders_db_username" {
  description = "Username for the orders PostgreSQL database"
  type        = string
  default     = "orders_admin"
}

variable "orders_db_password" {
  description = "Password for the orders PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "project_tag" {
  description = "Project tag applied to all resources"
  type        = string
  default     = "karatu-2025-capstone"
}
