# Lambda用の実行時変数を locals で定義
locals {
  ecs_cluster_name         = aws_ecs_cluster.main.name
  ecs_task_definition_name = aws_ecs_task_definition.main.family
  private_subnet_ids       = [
    aws_subnet.private1.id,
    aws_subnet.private2.id,
    aws_subnet.private3.id,
    aws_subnet.private4.id
  ]
}

# Lambda 関数を zip ファイルからデプロイする定義
resource "aws_lambda_function" "ecs_runtask_lambda" {
  function_name = var.lambda_function_name
  description   = "Invoke ECS RunTask for DB migration"

  # 事前にzip化したLambda関数のコードを指定
  filename         = "${path.module}/lambda/ecs_runtask.zip"  
  source_code_hash = filebase64sha256("${path.module}/lambda/ecs_runtask.zip")

  handler = "ecs_runtask.lambda_handler"
  runtime = "python3.11"

  role = aws_iam_role.lambda_execution_role.arn

  environment {
    variables = {
      ECS_CLUSTER_NAME     = local.ecs_cluster_name
      ECS_TASK_DEFINITION  = local.ecs_task_definition_name
      SUBNETS              = join(",", local.private_subnet_ids)
      SECURITY_GROUPS      = join(",", [aws_security_group.ecs_sg.id])
      ASSIGN_PUBLIC_IP     = "false"
    }
  }

  timeout = 60
  memory_size = 128
}