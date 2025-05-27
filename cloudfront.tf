# CloudFront ディストリビューションの定義  
# OAC（オリジンアクセスコントロール）を使用して、S3 バケットへのセキュアなアクセスを構成

# CloudFront OAC の定義
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                       = "${var.project_prefix}-frontend-oac"
  description                = "OAC for saburo-frontend S3 bucket access"  
  origin_access_control_origin_type = "s3"
  signing_behavior           = "always"
  signing_protocol           = "sigv4"
}

# CloudFront ディストリビューションの定義
resource "aws_cloudfront_distribution" "saburo_distribution" {
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id                = "${var.project_prefix}-saburo-frontend-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for saburo.xyz"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "${var.project_prefix}-saburo-frontend-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    # キャッシュポリシーの設定
    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id # CachingOptimized
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_custom_origin.id
  }

  # カスタムエラーレスポンス（メンテナンス用）
  custom_error_response {
    response_code         = 200
    error_code            = 503
    response_page_path    = "/503.html"
    error_caching_min_ttl = 60
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn_us_east_1
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = ["saburo.xyz"]

  tags = {
    Name        = "${var.project_prefix}-saburo-cloudfront"
    Environment = "Production"
  }
}

# CloudFront キャッシュポリシーの定義
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# CloudFront オリジンリクエストポリシーの定義
data "aws_cloudfront_origin_request_policy" "none" {
  name = "Managed-CORS-S3Origin"
}