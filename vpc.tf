# VPC の定義  
# DNS サポートとホスト名付与を有効にした基本構成の VPC を作成

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"              # VPC の CIDR 範囲
  enable_dns_support   = true                       # DNS 解決を有効化
  enable_dns_hostnames = true                       # ホスト名の自動割り当てを有効化

  tags = {
    Name = "${var.project_prefix}-vpc"              # VPC に名前タグを付与
  }
}