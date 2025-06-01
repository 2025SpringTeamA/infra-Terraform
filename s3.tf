# S3 バケットおよびファイルアップロードの定義  
# 所有権制御やバケットポリシーを含めた構成

# S3 バケットの定義（CloudFront 経由でアクセスするためのバケット）
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "${var.project_prefix}-saburo-frontend"
    Environment = "Production"
  }
}

# 所有権制御の設定(ACLを無効化)
resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# パブリックアクセスブロックの設定
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# バケットポリシー（OAC のみアクセス許可）
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowCloudFrontServicePrincipal",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.saburo_distribution.arn
          }
        }      
      }
    ]
  })
}

# CORS設定（フロントエンド用）
resource "aws_s3_bucket_cors_configuration" "frontend_bucket_cors" {
  bucket = aws_s3_bucket.frontend_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["https://saburo.xyz", "https://*.cloudfront.net"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# 静的ウェブサイトホスティング設定（フロントエンド用）- SPA対応
resource "aws_s3_bucket_website_configuration" "frontend_bucket_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}