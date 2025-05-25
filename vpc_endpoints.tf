# VPC Endpoint の定義
# ECS Exec に必要な3つのエンドポイント（SSM、SSMMessages、EC2Messages）を VPC 内に提供

# SSM エンドポイントの定義（Systems Manager から Fargate タスクへの接続を確立するために使用）
resource "aws_vpc_endpoint" "interface_ssm" {
    vpc_id              = aws_vpc.main.id
    service_name        = "com.amazonaws.ap-northeast-1.ssm"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = [aws_subnet.private1.id, aws_subnet.private2.id]
    security_group_ids  = [aws_security_group.ecs_sg.id]
    private_dns_enabled = true

    tags = {
        Name = "${var.project_prefix}-vpc-endpoint-ssm"
    }
}

# SSM Messages エンドポイントの定義（Fargate タスクとSystems Manager間のメッセージングを提供）
resource "aws_vpc_endpoint" "interface_ssm_messages" {
    vpc_id              = aws_vpc.main.id
    service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = [aws_subnet.private1.id, aws_subnet.private2.id]
    security_group_ids  = [aws_security_group.ecs_sg.id]
    private_dns_enabled = true

    tags = {
      Name = "${var.project_prefix}-vpc-endpoint-ssm-messages"
    }
}

# EC2 Messages エンドポイントの定義（Fargate タスクとEC2間のメッセージングを提供）
resource "aws_vpc_endpoint" "interface_ec2_messages" {
    vpc_id              = aws_vpc.main.id
    service_name        = "com.amazonaws.ap-northeast-1.ec2messages"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = [aws_subnet.private1.id, aws_subnet.private2.id]
    security_group_ids  = [aws_security_group.ecs_sg.id]
    private_dns_enabled = true

    tags = {
        Name = "${var.project_prefix}-vpc-endpoint-ec2-messages"
    }
}