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

# ECR リポジトリの URI を格納する変数
variable "ecr_image_uri" {
  default = "881490128743.dkr.ecr.ap-northeast-1.amazonaws.com/saburo-fastapi"
}

# RDS インスタンスの DB 名
variable "rds_db_name" {
  default = "fastapi_db"
}

# パラメータグループとオプショングループの設定
variable "rds_parameter_group_name" {
  description = "RDSのパラメータグループ名"
  type        = string
  default     = "rds-param-mydbparametergroup-yoxc9cx9okn9"
}

variable "rds_option_group_name" {
  description = "RDSのオプショングループ名"
  type        = string
  default     = "rds-param-mydboptiongroup-ffa59wwihmxj"
}

# Lambda Function用のIAMロール定義も追加
variable "lambda_function_name" {
  description = "Lambda function name for DB migration trigger"
  default     = "db-migration-trigger"
}

# Lambda が参照する ECS クラスタ名
variable "ecs_cluster_name" {
  description = "ECSクラスタ名（LambdaからRunTaskを実行するために使用）"
  type        = string
}

# Lambda が起動する ECS タスク定義名
variable "ecs_task_definition_name" {
  description = "ECSタスク定義名（LambdaからRunTaskを実行するために使用）"
  type        = string
}

# Lambda が RunTask を実行する際のプライベートサブネット
variable "private_subnet_ids" {
  description = "ECS RunTask に使用するプライベートサブネットIDのリスト"
  type        = list(string)
}