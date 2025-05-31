# AWSアカウントIDを取得（ロールARNを構築するため）
data "aws_caller_identity" "current" {}

# Lambda用IAMロール（ECS RunTask実行用）
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_prefix}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda用ポリシー（CloudWatch Logs, ECS RunTask, iam:PassRole）
resource "aws_iam_policy" "lambda_ecs_policy" {
  name        = "${var.project_prefix}-lambda-ecs-policy"
  description = "Policy for Lambda to run ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_prefix}-ecs-task-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_prefix}-ecs-task-execution-role"
        ]
      }
    ]
  })
}

# ロールにポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "lambda_ecs_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_ecs_policy.arn
}