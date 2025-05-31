# CloudFront OAC の定義（S3とセキュア連携するため）
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "${var.project_prefix}-frontend-oac"
  description                       = "OAC for saburo-frontend S3 bucket access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "maintenance_oac" {
  name                              = "${var.project_prefix}-maintenance-oac"
  description                       = "OAC for saburo-maintenance S3 bucket access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront ディストリビューション
resource "aws_cloudfront_distribution" "saburo_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for saburo.xyz"
  default_root_object = "index.html"

  aliases = ["saburo.xyz"]

  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id                = "${var.project_prefix}-saburo-frontend-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  origin {
    domain_name              = aws_s3_bucket.maintenance_bucket.bucket_regional_domain_name
    origin_id                = "${var.project_prefix}-saburo-maintenance-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.maintenance_oac.id
  }

  # デフォルトルート（トップページ用）
  default_cache_behavior {
    target_origin_id       = "${var.project_prefix}-saburo-frontend-origin"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_custom_origin.id
  }

  # beautiful-woman-mode 用ビヘイビア
  ordered_cache_behavior {
    path_pattern           = "/beautiful-woman-mode/*"
    target_origin_id       = "${var.project_prefix}-saburo-frontend-origin"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_custom_origin.id
  }

  # sabutyan-mode 用ビヘイビア
  ordered_cache_behavior {
    path_pattern           = "/sabutyan-mode/*"
    target_origin_id       = "${var.project_prefix}-saburo-frontend-origin"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_custom_origin.id
  }

  # 🔻 共通のSPAルート対応（403/404時は /index.html を返す）
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
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

  tags = {
    Name        = "${var.project_prefix}-saburo-cloudfront"
    Environment = "Production"
  }
}

# キャッシュポリシー（CloudFrontマネージド）
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# オリジンリクエストポリシー（CloudFrontマネージド）
data "aws_cloudfront_origin_request_policy" "cors_custom_origin" {
  name = "Managed-CORS-CustomOrigin"
}
