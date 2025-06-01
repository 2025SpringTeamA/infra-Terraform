output "ecs_cluster_name" {
  description = "ECS Cluster name for Lambda function"
  value       = aws_ecs_cluster.main.name
}

output "private_subnet_ids" {
  description = "Private subnet IDs for ECS RunTask"
  value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "ecs_security_group_id" {
  description = "ECS security group ID for RunTask"
  value       = aws_security_group.ecs_sg.id
}

output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID for cache invalidation"
  value       = aws_cloudfront_distribution.saburo_distribution.id
}

output "cloudfront_domain_name" {
  description = "CloudFront Distribution domain name"
  value       = aws_cloudfront_distribution.saburo_distribution.domain_name
}

output "s3_frontend_bucket_name" {
  description = "S3 frontend bucket name for deployment"
  value       = aws_s3_bucket.frontend_bucket.bucket
}

output "s3_maintenance_bucket_name" {
  description = "S3 maintenance bucket name"
  value       = aws_s3_bucket.maintenance_bucket.bucket
}