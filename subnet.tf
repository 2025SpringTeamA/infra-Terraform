# サブネットの定義  
# パブリックおよびプライベートサブネットを AZ ごとに設定

# パブリックサブネット（AZ: ap-northeast-1a）
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.project_prefix}-subnet-public1-ap-northeast-1a"
  }
}

# パブリックサブネット（AZ: ap-northeast-1c）
resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.project_prefix}-public2-ap-northeast-1c"
  }
}

# プライベートサブネット（AZ: ap-northeast-1a）
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.project_prefix}-subnet-private1-ap-northeast-1a"
  }
}

# プライベートサブネット（AZ: ap-northeast-1c）
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.project_prefix}-subnet-private2-ap-northeast-1c"
  }
}

# プライベートサブネット（AZ: ap-northeast-1a, 別のCIDRブロック）
resource "aws_subnet" "private3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.project_prefix}-subnet-private3-ap-northeast-1a"
  }
}

# プライベートサブネット（AZ: ap-northeast-1c, 別のCIDRブロック）
resource "aws_subnet" "private4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.project_prefix}-subnet-private4-ap-northeast-1c"
  }
}
