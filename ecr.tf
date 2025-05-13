resource "aws_ecr_repository" "main" {
  name = "${var.project_prefix}-saburo-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr_repository_name
    Environment = "production"
  }
}