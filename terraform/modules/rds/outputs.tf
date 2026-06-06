output "mysql_endpoint" {
  description = "MySQL (catalog) RDS endpoint"
  value       = aws_db_instance.catalog_mysql.endpoint
}

output "postgres_endpoint" {
  description = "PostgreSQL (orders) RDS endpoint"
  value       = aws_db_instance.orders_postgres.endpoint
}

output "mysql_address" {
  description = "MySQL (catalog) RDS hostname"
  value       = aws_db_instance.catalog_mysql.address
}

output "postgres_address" {
  description = "PostgreSQL (orders) RDS hostname"
  value       = aws_db_instance.orders_postgres.address
}
