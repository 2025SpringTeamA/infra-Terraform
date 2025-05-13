# NAT ゲートウェイの構成定義  
# プライベートサブネットからインターネットへのアクセスを提供するための NAT ゲートウェイと Elastic IP を定義

# NAT ゲートウェイ用の Elastic IP（EIP）の定義
resource "aws_eip" "nat" {
  domain = "vpc"                     # VPC 用の EIP を指定

  tags = {
    Name = "${var.project_prefix}-eip-ap-northeast-1a"
  }
}

# NAT ゲートウェイの定義（パブリックサブネットに配置）
resource "aws_nat_gateway" "public1" {
  allocation_id = aws_eip.nat.id               # 上記 EIP を割り当て
  subnet_id     = aws_subnet.public1.id        # NAT ゲートウェイを配置するパブリックサブネット

  tags = {
    Name = "${var.project_prefix}-nat-public1-ap-northeast-1a"
  }

  depends_on = [aws_internet_gateway.main]     # IGW が先に作成されるように依存関係を明示
}