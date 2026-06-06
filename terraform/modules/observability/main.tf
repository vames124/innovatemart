# ──────────────────────────────────────────────
# CloudWatch Log Groups for EKS
# ──────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "eks_application" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = 30

  tags = {
    Name    = "${var.cluster_name}-application-logs"
    Project = var.project_tag
  }
}

resource "aws_cloudwatch_log_group" "eks_dataplane" {
  name              = "/aws/eks/${var.cluster_name}/dataplane"
  retention_in_days = 30

  tags = {
    Name    = "${var.cluster_name}-dataplane-logs"
    Project = var.project_tag
  }
}

# ──────────────────────────────────────────────
# IRSA Role: CloudWatch Agent
# ──────────────────────────────────────────────

resource "aws_iam_role" "cloudwatch_agent_irsa" {
  name = "${var.cluster_name}-cloudwatch-agent-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.cluster_oidc_url}:sub" = "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
            "${var.cluster_oidc_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "${var.cluster_name}-cloudwatch-agent-irsa"
    Project = var.project_tag
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_agent_irsa.name
}

# ──────────────────────────────────────────────
# IRSA Role: Fluent Bit (log forwarding)
# ──────────────────────────────────────────────

resource "aws_iam_role" "fluentbit_irsa" {
  name = "${var.cluster_name}-fluentbit-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.cluster_oidc_url}:sub" = "system:serviceaccount:amazon-cloudwatch:fluent-bit"
            "${var.cluster_oidc_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "${var.cluster_name}-fluentbit-irsa"
    Project = var.project_tag
  }
}

resource "aws_iam_role_policy" "fluentbit_cloudwatch" {
  name = "${var.cluster_name}-fluentbit-cw-policy"
  role = aws_iam_role.fluentbit_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ──────────────────────────────────────────────
# CloudWatch Dashboard
# ──────────────────────────────────────────────

resource "aws_cloudwatch_dashboard" "eks" {
  dashboard_name = "${var.cluster_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "EKS Cluster CPU Utilization"
          metrics = [
            ["AWS/EKS", "cluster_failed_node_count", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "EKS Node Count"
          metrics = [
            ["AWS/EKS", "cluster_node_count", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          view   = "timeSeries"
        }
      },
    ]
  })
}

# ──────────────────────────────────────────────
# SNS Topic for Alerts
# ──────────────────────────────────────────────

resource "aws_sns_topic" "eks_alerts" {
  name = "${var.cluster_name}-alerts"

  tags = {
    Name    = "${var.cluster_name}-alerts"
    Project = var.project_tag
  }
}

# ──────────────────────────────────────────────
# CloudWatch Alarm: High CPU
# ──────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.cluster_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS node CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.eks_alerts.arn]

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = {
    Name    = "${var.cluster_name}-high-cpu-alarm"
    Project = var.project_tag
  }
}

# ──────────────────────────────────────────────
# Amazon CloudWatch Observability EKS Add-on
# (Ships container logs + metrics to CloudWatch)
# ──────────────────────────────────────────────

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name             = var.cluster_name
  addon_name               = "amazon-cloudwatch-observability"
  service_account_role_arn = aws_iam_role.cloudwatch_agent_irsa.arn

  tags = {
    Name    = "${var.cluster_name}-cloudwatch-observability"
    Project = var.project_tag
  }
}
