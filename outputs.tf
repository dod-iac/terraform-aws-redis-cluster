output "replication_group_arn" {
  value = aws_elasticache_replication_group.main.arn
}

output "replication_group_id" {
  value = aws_elasticache_replication_group.main.id
}

output "primary_endpoint_address" {
  value = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint_address" {
  value = aws_elasticache_replication_group.main.reader_endpoint_address
}
