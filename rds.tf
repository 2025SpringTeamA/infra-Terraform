# RDS 構成の定義  
# サブネットグループ、Secrets Manager、DB インスタンスの設定

# RDS 用のサブネットグループの定義
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_prefix}-rds-subnet-group"
  subnet_ids = [
    aws_subnet.private3.id,
    aws_subnet.private4.id
  ]

  tags = {
    Name = "${var.project_prefix}-rds-subnet-group"
  }
}

# RDS インスタンスの定義（MySQL 8.0）
resource "aws_db_instance" "rds_instance" {
  identifier           = "${var.project_prefix}-rds"
  engine               = "mysql"
  engine_version       = "8.0.41"
  instance_class       = "db.t4g.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  db_name              = var.rds_db_name

  # 認証情報
  username = "admin"
  password = jsondecode(data.aws_secretsmanager_secret_version.rds_password_v2.secret_string)["password"]

  # サブネットとセキュリティグループの設定
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  multi_az            = false

  tags = {
    Name = "${var.project_prefix}-rds-instance"
  }

  # 削除時にスナップショットを作成しない
  skip_final_snapshot = true
}
