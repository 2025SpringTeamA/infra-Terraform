# メンテナンス用 S3 バケットの定義
resource "aws_s3_bucket" "maintenance_bucket" {
  bucket = var.maintenance_bucket_name

  tags = {
    Name        = "${var.project_prefix}-saburo-maintenance"
    Environment = "Production"
  }
}

# S3 バケットの静的ウェブサイトホスティング構成
resource "aws_s3_bucket_website_configuration" "maintenance" {
  bucket = aws_s3_bucket.maintenance_bucket.id

  index_document {
    suffix = "503.html"
  }

  error_document {
    key = "503.html"
  }
}

# 所有権制御の設定(ACLを無効化)
resource "aws_s3_bucket_ownership_controls" "maintenance" {
  bucket = aws_s3_bucket.maintenance_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# バケットポリシー(Route53 → S3)
resource "aws_s3_bucket_policy" "maintenance_bucket_policy" {
  bucket = aws_s3_bucket.maintenance_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowPublicReadForStaticSite",
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.maintenance_bucket.arn}/*"   
      }
    ]
  })
}
