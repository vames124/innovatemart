terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = var.project_tag
    }
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# ──────────────────────────────────────────────
# VPC
# ──────────────────────────────────────────────

module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  cluster_name         = var.cluster_name
  project_tag          = var.project_tag
}

# ──────────────────────────────────────────────
# EKS
# ──────────────────────────────────────────────

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  node_instance_type = var.eks_node_instance_type
  node_desired_size  = var.eks_node_desired
  node_min_size      = var.eks_node_min
  node_max_size      = var.eks_node_max
  project_tag        = var.project_tag
}

# ──────────────────────────────────────────────
# RDS (MySQL + PostgreSQL)
# ──────────────────────────────────────────────

module "rds" {
  source              = "./modules/rds"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  eks_node_sg_id      = module.eks.node_sg_id
  catalog_db_username = var.catalog_db_username
  catalog_db_password = var.catalog_db_password
  orders_db_username  = var.orders_db_username
  orders_db_password  = var.orders_db_password
  project_tag         = var.project_tag
}

# ──────────────────────────────────────────────
# DynamoDB
# ──────────────────────────────────────────────

module "dynamodb" {
  source      = "./modules/dynamodb"
  project_tag = var.project_tag
}

# ──────────────────────────────────────────────
# IAM (IRSA roles + dev user)
# ──────────────────────────────────────────────

module "iam" {
  source             = "./modules/iam"
  cluster_name       = var.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url
  dynamodb_table_arn = module.dynamodb.table_arn
  assets_bucket_arn  = module.serverless.bucket_arn
  project_tag        = var.project_tag
}

# ──────────────────────────────────────────────
# Serverless (S3 + Lambda)
# ──────────────────────────────────────────────

module "serverless" {
  source      = "./modules/serverless"
  student_id  = var.student_id
  project_tag = var.project_tag
}

# ──────────────────────────────────────────────
# Observability (CloudWatch)
# ──────────────────────────────────────────────

module "observability" {
  source           = "./modules/observability"
  cluster_name     = module.eks.cluster_name
  cluster_oidc_arn = module.eks.oidc_provider_arn
  cluster_oidc_url = module.eks.oidc_provider_url
  project_tag      = var.project_tag
}
