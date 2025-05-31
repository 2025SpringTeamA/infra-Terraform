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
      ECS_CLUSTER_NAME     = var.ecs_cluster_name
      ECS_TASK_DEFINITION  = var.ecs_task_definition_name
      SUBNETS              = join(",", var.private_subnet_ids)
      SECURITY_GROUPS      = join(",", [aws_security_group.ecs_sg.id])
      ASSIGN_PUBLIC_IP     = "false"
    }
  }

  timeout = 60
  memory_size = 128
}