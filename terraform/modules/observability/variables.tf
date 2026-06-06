variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_oidc_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "cluster_oidc_url" {
  description = "URL of the EKS OIDC provider (without https://)"
  type        = string
}

variable "project_tag" {
  description = "Project tag for all resources"
  type        = string
}
