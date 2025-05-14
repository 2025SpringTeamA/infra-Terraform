# ルートテーブルと関連リソースの定義  
# パブリックおよびプライベートサブネットに適切なルーティングを設定

# パブリックルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-rtb-public"
  }
}

# パブリックルートテーブルにインターネットアクセスを許可するルートを追加
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# パブリックサブネットをルートテーブルに関連付け
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# プライベートルートテーブル（AZ: ap-northeast-1a）
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-rtb-private1-ap-northeast-1a"
  }
}

# NAT ゲートウェイを経由したインターネットアクセスのルート
resource "aws_route" "private1_nat_access" {
  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public1.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

# プライベートルートテーブル（AZ: ap-northeast-1c）
resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-rtb-private2-ap-northeast-1c"
  }
}

resource "aws_route" "private2_nat_access" {
  route_table_id         = aws_route_table.private2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}

# プライベートルートテーブル（AZ: ap-northeast-1a, 別の CIDR）
resource "aws_route_table" "private3" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-rtb-private3-ap-northeast-1a"
  }
}

resource "aws_route" "private3_nat_access" {
  route_table_id         = aws_route_table.private3.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public1.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private3.id
}

# プライベートルートテーブル（AZ: ap-northeast-1c, 別の CIDR）
resource "aws_route_table" "private4" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_prefix}-rtb-private4-ap-northeast-1c"
  }
}

resource "aws_route" "private4_nat_access" {
  route_table_id         = aws_route_table.private4.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public1.id
}

resource "aws_route_table_association" "private4" {
  subnet_id      = aws_subnet.private4.id
  route_table_id = aws_route_table.private4.id
}
