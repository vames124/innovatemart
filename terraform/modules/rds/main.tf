# ──────────────────────────────────────────────
# RDS Subnet Group
# ──────────────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name       = "project-bedrock-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "project-bedrock-db-subnet-group"
    Project = var.project_tag
  }
}

# ──────────────────────────────────────────────
# Security Group for RDS
# ──────────────────────────────────────────────

resource "aws_security_group" "rds" {
  name        = "project-bedrock-rds-sg"
  description = "Security group for RDS instances - allows access from EKS nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "project-bedrock-rds-sg"
    Project = var.project_tag
  }
}

# MySQL (catalog) - port 3306
resource "aws_vpc_security_group_ingress_rule" "mysql_from_eks" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = var.eks_node_sg_id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "Allow MySQL from EKS nodes"

  tags = {
    Project = var.project_tag
  }
}

# PostgreSQL (orders) - port 5432
resource "aws_vpc_security_group_ingress_rule" "postgres_from_eks" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = var.eks_node_sg_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow PostgreSQL from EKS nodes"

  tags = {
    Project = var.project_tag
  }
}

# ──────────────────────────────────────────────
# MySQL RDS Instance (Catalog Service)
# ──────────────────────────────────────────────

resource "aws_db_instance" "catalog_mysql" {
  identifier             = "project-bedrock-catalog-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 50
  storage_type           = "gp3"
  db_name                = "catalog"
  username               = var.catalog_db_username
  password               = var.catalog_db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true

  tags = {
    Name    = "project-bedrock-catalog-mysql"
    Project = var.project_tag
  }
}

# ──────────────────────────────────────────────
# PostgreSQL RDS Instance (Orders Service)
# ──────────────────────────────────────────────

resource "aws_db_instance" "orders_postgres" {
  identifier             = "project-bedrock-orders-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 50
  storage_type           = "gp3"
  db_name                = "orders"
  username               = var.orders_db_username
  password               = var.orders_db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true

  tags = {
    Name    = "project-bedrock-orders-postgres"
    Project = var.project_tag
  }
}
