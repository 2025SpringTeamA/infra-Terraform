output "ecs_cluster_name" {
  description = "ECS Cluster name for Lambda function"
  value       = aws_ecs_cluster.main.name
}

# output "migration_task_definition_arn" {
#   description = "Migration task definition ARN for Lambda function"
#   value       = aws_ecs_task_definition.migration.arn
# }

output "private_subnet_ids" {
  description = "Private subnet IDs for ECS RunTask"
  value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "ecs_security_group_id" {
  description = "ECS security group ID for RunTask"
  value       = aws_security_group.ecs_sg.id
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_execution_role.arn
}