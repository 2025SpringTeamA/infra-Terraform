# 変数の定義  
# ACM 証明書の ARN を外部入力として設定

variable "project_prefix" {
  default = "prod"
}

# S3バケット名
variable "s3_bucket_name" {
  default = "saburo-frontend"
}

variable "maintenance_bucket_name" {
  default = "saburo-maintenance"
}

# CloudFront 用（バージニア北部）
variable "acm_certificate_arn_us_east_1" {
  description = "ACM Certificate ARN for CloudFront in us-east-1"
  default     = "arn:aws:acm:us-east-1:881490128743:certificate/51fca7bc-7b49-4e99-a31f-8373bcc14ab2"
}

# ALB 用（東京リージョン）
variable "acm_certificate_arn_ap_northeast_1" {
  description = "ACM Certificate ARN for ALB in ap-northeast-1"
  default     = "arn:aws:acm:ap-northeast-1:881490128743:certificate/0f74bf4b-3ed8-4d3f-902b-b84fb7d3e97f"
}

# Datadog API Key
variable "datadog_api_key" {
  description = "Datadog API Key"
  default     = "a11f02afd575da1c6ff3cf40a2e5deab"
}

# ECR リポジトリ名
variable "ecr_repository_name" {
  default = "prod-saburo-app"
}

# ECR リポジトリの URI を格納する変数
variable "ecr_image_uri" {
  default = "881490128743.dkr.ecr.ap-northeast-1.amazonaws.com/prod-saburo-app"
}

# RDS インスタンスの DB 名
variable "rds_db_name" {
  default = "fastapi_db"
}