# ──────────────────────────────────────────────
# DynamoDB Table (Carts Service)
# ──────────────────────────────────────────────

resource "aws_dynamodb_table" "carts" {
  name         = "project-bedrock-carts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name    = "project-bedrock-carts"
    Project = var.project_tag
  }
}
