# ECS 関連リソースの定義  
# クラスター、タスク実行ロール、タスク定義、サービスの構成

# CloudWatch Logs グループの定義
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/datadog"
  retention_in_days = 7

  tags = {
    Name = "${var.project_prefix}-ecs-logs"
  }
}

# ECS クラスターの定義（Fargate でアプリケーションを実行）
resource "aws_ecs_cluster" "main" {
  name = "${var.project_prefix}-ecs-cluster"
}

# ECS タスク実行ロールの定義（タスクが必要な AWS サービスへアクセスするための IAM ロール）
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_prefix}-ecs-task-execution-role"

  # ECS タスクがこのロールを引き受けるための信頼ポリシー
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# タスク実行時に必要な操作を許可するIAMポリシー
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name = "${var.project_prefix}-ecs-task-execution-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:GetObject",
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}

# ECS タスク実行ロールにポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

# ECS Exec用のタスクロール
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_ssm" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Bedrock 用のポリシーを作成
resource "aws_iam_policy" "ecs_bedrock_policy" {
  name = "${var.project_prefix}-ecs-bedrock-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "bedrock:ListFoundationModels"
        ],
        Resource = "*"
      }
    ]
  })
}

# ECS タスクロールに Bedrock ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_role_bedrock" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_bedrock_policy.arn
}

# ECS タスク定義（Fargate: init-datadog → datadog-agent → DB Migration → FastAPI App）
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_prefix}-saburo-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "init-datadog",
      image        = "datadog/cws-instrumentation:latest",
      essential    = false,
      command      = ["/cws-instrumentation", "setup", "--cws-volume-mount", "/cws-instrumentation-volume"],
      mountPoints  = [{
        sourceVolume  = "cws-instrumentation-volume",
        containerPath = "/cws-instrumentation-volume",
        readOnly      = false
      }],
      user         = "0",
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/datadog",
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "cws-instrumentation-init"
        }
      }
    },
{
  name        = "datadog-agent",
  image       = "datadog/agent:latest",
  essential   = true,

  secrets = [
    { 
      name      = "DD_API_KEY", 
      valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/datadog-IQUsil:DD_API_KEY::" 
    }
  ],
  environment = [
    { name  = "DD_SITE", value = "ap1.datadoghq.com" },
    { name  = "ECS_FARGATE", value = "true" },
    { name  = "DD_CONTAINER_METRICS_ENABLED", value = "true" },
    { name  = "DD_LOGS_ENABLED", value = "true"},
    { name  = "DD_PROCESS_AGENT_ENABLED", value = "true"},
    { name  = "DD_PROCESS_CONFIG_ENABLED", value = "true"},
    { name  = "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL", value = "true"},
    { name  = "DD_APM_ENABLED", value = "true"},
    { name  = "DD_TRACE_ENABLED", value = "true"}
  ],
  logConfiguration = {
    logDriver = "awslogs",
    options = {
      awslogs-group         = "/ecs/datadog",
      awslogs-region        = "ap-northeast-1",
      awslogs-stream-prefix = "datadog-agent"
    }
  },
  healthCheck = {
    command     = ["CMD-SHELL", "/probe.sh"],
    interval    = 30,
    timeout     = 5,
    retries     = 2,
    startPeriod = 60
  }
},
  {
      name           = "db-migration",
      image          = "${var.ecr_image_uri}:latest",
      essential      = false,
      entryPoint     = ["/bin/sh", "-c"],
      command        = ["cd /app && alembic upgrade head"],
      secrets = [
        { 
          name = "MYSQL_ROOT_PASSWORD", 
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials-4w84iT:MYSQL_ROOT_PASSWORD::" 
        },
        { 
          name = "MYSQL_DATABASE", 
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials-4w84iT:MYSQL_DATABASE::" 
        },
        { 
          name = "MYSQL_USER",     
          valueFrom =  "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials-4w84iT:MYSQL_USER::"       
        },
        { 
          name = "MYSQL_PASSWORD", 
          valueFrom =  "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials-4w84iT:MYSQL_PASSWORD::" 
        },
        { 
          name = "DATABASE_URL",   
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials-4w84iT:DATABASE_URL::" 
        }
      ],
      dependsOn = [
        {
          containerName = "datadog-agent",
          condition     = "HEALTHY"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/datadog",
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "db-migration"
        }
      }
    },
    {
      name  = "fastapi-app",
      image = "${var.ecr_image_uri}:latest",
      essential = true,
      secrets = [
        { 
          name = "MYSQL_DATABASE",       
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials:MYSQL_DATABASE::" 
        },
        { 
          name = "MYSQL_USER",           
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials:MYSQL_USER::" 
        },
        { 
          name = "MYSQL_PASSWORD",       
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials:MYSQL_PASSWORD::" 
        },
        { 
          name = "MYSQL_ROOT_PASSWORD",  
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials:MYSQL_ROOT_PASSWORD::" 
        },
        { 
          name = "DATABASE_URL",         
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials:DATABASE_URL::" 
        },
        { 
          name = "ADMIN_PIN_CODE",       
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials:ADMIN_PIN_CODE::" 
        },
        { 
          name = "SECRET_KEY",           
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials:SECRET_KEY::" 
        },
        { name = "OPENAI_API_KEY",       
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials:OPENAI_API_KEY::" 
        },
        { name = "OPENAI_MODEL",         
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:881490128743:secret:prod/saburo-fastapi/db-credentials:OPENAI_MODEL::" 
        }                    
      ],
      portMappings = [
        {
          containerPort = 8000,
          hostPort      = 8000,
          protocol      = "tcp"
        }
      ],
      command: [
        "uvicorn",
        "main:app",
        "--host", "0.0.0.0",
        "--port", "8000",
        "--log-level", "info"
      ],
      dependsOn = [
        {
          containerName = "datadog-agent",
          condition     = "HEALTHY"
        },
        {
          containerName = "init-datadog",
          condition     = "SUCCESS"
        },
        {
          containerName = "db-migration",
          condition     = "SUCCESS"
        }
      ],
      mountPoints = [{
        sourceVolume = "cws-instrumentation-volume",
        containerPath = "/cws-instrumentation-volume",
        readOnly = true
      }],
      linuxParameters = {
        capabilities = {
          add = ["SYS_PTRACE"]
        }
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/datadog",
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "fastapi-app"
        }
      }
    }
  ])

  volume {
    name = "cws-instrumentation-volume"
  }
}

# ECS サービスの定義（Fargate でアプリケーションを実行し、ALB に登録）
resource "aws_ecs_service" "main" {
  name            = "${var.project_prefix}-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # ECS Exec を有効化
  enable_execute_command = true

  # サブネットとセキュリティグループの指定（プライベートサブネットで実行）
  network_configuration {
    subnets         = [aws_subnet.private1.id, aws_subnet.private2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  # ALB にコンテナを登録（ターゲットグループ連携）
  load_balancer {
    target_group_arn = aws_lb_target_group.main_target_group.arn
    container_name   = "fastapi-app"
    container_port   = 8000
  }

  # ALBリスナー作成後に ECS サービスを作成する
  depends_on = [
    aws_lb_listener.http_listener,
    aws_lb_listener.https_listener
  ]
}

# ECS サービスの Auto Scaling 定義（CPU 使用率に基づいてスケールイン/スケールアウト）
resource "aws_appautoscaling_target" "ecs_service_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_scaling" {
  name                  = "${var.project_prefix}-cpu-scaling-policy"
  policy_type           = "TargetTrackingScaling"
  resource_id           = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension    = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  service_namespace     = aws_appautoscaling_target.ecs_service_target.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}