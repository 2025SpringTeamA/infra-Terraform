# アプリケーションロードバランサー（ALB）の定義  
# ALB 本体、ターゲットグループ、リスナーの構成を含む

# アプリケーションロードバランサー（ALB）の定義
resource "aws_lb" "main_alb" {
  name               = "${var.project_prefix}-main-alb"
  internal           = false                               # パブリック ALB として構成
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]   # ALB に適用するセキュリティグループ
  subnets            = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]

  enable_deletion_protection = false                       # 削除保護を無効化

  tags = {
    Name = "${var.project_prefix}-main-alb"
  }
}

# ターゲットグループの定義（ALB がリクエストを転送する先）
resource "aws_lb_target_group" "main_target_group" {
  name        = "${var.project_prefix}-main-target-group"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"                                       # Fargate の場合は 'ip' を指定

  # ヘルスチェックの設定
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  # セッション維持設定（Cookie によるスティッキーセッション）
  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400
  }

  tags = {
    Name = "${var.project_prefix}-main-target-group"
  }
}

# HTTPS リスナーの定義（ALB が HTTPS リクエストを受け取り、ターゲットグループに転送）
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn_ap_northeast_1              # ACM 証明書の ARN を指定

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main_target_group.arn
  }
}