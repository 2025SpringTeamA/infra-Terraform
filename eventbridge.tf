# EventBridge スケジュールルールの定義（毎日3時に実行）
resource "aws_cloudwatch_event_rule" "daily_maintenance_trigger" {
  name                = "${var.project_prefix}-ecs-daily-runtask"
  description         = "Trigger ECS RunTask daily at 3:00 AM JST"
  schedule_expression = "cron(0 18 * * ? *)" # JST 3:00 = UTC 18:00
}

# イベントターゲット（Lambda関数をターゲットに指定）
resource "aws_cloudwatch_event_target" "ecs_runtask_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_maintenance_trigger.name
  target_id = "InvokeLambda"
  arn       = aws_lambda_function.ecs_runtask_lambda.arn
}

# Lambda の許可設定（EventBridge からの呼び出しを許可）
resource "aws_lambda_permission" "allow_eventbridge_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_runtask_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_maintenance_trigger.arn
}