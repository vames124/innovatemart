# ──────────────────────────────────────────────
# IRSA Role: Cart Service (DynamoDB)
# ──────────────────────────────────────────────

resource "aws_iam_role" "cart_dynamodb_role" {
  name = "bedrock-cart-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:sub" = "system:serviceaccount:retail-app:cart-sa"
            "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "bedrock-cart-dynamodb-role"
    Project = var.project_tag
  }
}

resource "aws_iam_role_policy" "cart_dynamodb" {
  name = "bedrock-cart-dynamodb-policy"
  role = aws_iam_role.cart_dynamodb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable",
          "dynamodb:CreateTable",
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*",
        ]
      }
    ]
  })
}

# ──────────────────────────────────────────────
# Developer IAM User: bedrock-dev-view
# ──────────────────────────────────────────────

resource "aws_iam_user" "dev_view" {
  name = "bedrock-dev-view"
  path = "/"

  tags = {
    Name    = "bedrock-dev-view"
    Project = var.project_tag
  }
}

resource "aws_iam_user_login_profile" "dev_view" {
  user                    = aws_iam_user.dev_view.name
  password_reset_required = false
}

resource "aws_iam_access_key" "dev_view" {
  user = aws_iam_user.dev_view.name
}

# Attach AWS managed ReadOnlyAccess policy (Console read-only)
resource "aws_iam_user_policy_attachment" "dev_view_readonly" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Inline policy: s3:PutObject on the assets bucket (for grading)
resource "aws_iam_user_policy" "dev_view_s3_put" {
  name = "bedrock-dev-view-s3-put"
  user = aws_iam_user.dev_view.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3PutObject"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = "${var.assets_bucket_arn}/*"
      }
    ]
  })
}
