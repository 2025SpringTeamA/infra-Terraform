# セキュリティグループの定義  
# ALB、ECS、RDS 用に必要な通信ルールを設定

# パブリック（ALB）用セキュリティグループ（HTTPS トラフィックを許可）
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

  # インバウンドルール: HTTP (80) の受信を全インターネットから許可
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # インバウンドルール: HTTPS (443) の受信を全インターネットから許可
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # アウトバウンドルール: すべての通信を許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_prefix}-alb-sg"
  }
}

# ECS 用のセキュリティグループ（アプリケーションの通信を制御）
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  # VPCエンドポイント（SSM経由のECS Exec）からのリクエストを許可（ポート443）
  ingress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"] # VPC内通信を許可（VPCエンドポイント用）
}

  # ALB からのリクエストを許可（FastAPIのアプリ: ポート8000）
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # すべてのアウトバウンドトラフィックを許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_prefix}-ecs-sg"
  }
}

# RDS 用セキュリティグループ（データベースへのアクセスを制御）
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  # インバウンドルール: MySQL (3306) の接続を VPC 内のリソースから許可
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.fargate_sg.id]
  }

  # アウトバウンドルール: すべての通信を許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_prefix}-rds-sg"
  }
}