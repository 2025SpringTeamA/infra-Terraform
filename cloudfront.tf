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

# SPA専用キャッシュポリシー（HTMLページ用）
resource "aws_cloudfront_cache_policy" "spa_cache_policy" {
  name        = "${var.project_prefix}-spa-cache-policy"
  comment     = "Cache policy for SPA HTML pages - no cache for dynamic routing"
  default_ttl = 0
  max_ttl     = 86400
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    query_strings_config {
      query_string_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }
  }
}

# 静的アセット用キャッシュポリシー（JS/CSS/画像用）
resource "aws_cloudfront_cache_policy" "static_assets_cache_policy" {
  name        = "${var.project_prefix}-static-assets-cache-policy"
  comment     = "Cache policy for static assets - long cache"
  default_ttl = 31536000
  max_ttl     = 31536000
  min_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    query_strings_config {
      query_string_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }
  }
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

  # Next.jsの静的アセット用（JS/CSS）
  ordered_cache_behavior {
    path_pattern           = "/_next/static/*"
    target_origin_id       = "${var.project_prefix}-saburo-frontend-origin"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id          = aws_cloudfront_cache_policy.static_assets_cache_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_custom_origin.id
  }

  # 画像ファイル用
  ordered_cache_behavior {
    path_pattern           = "/images/*"
    target_origin_id       = "${var.project_prefix}-saburo-frontend-origin"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id          = aws_cloudfront_cache_policy.static_assets_cache_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_custom_origin.id
  }

  # 音声ファイル用
  ordered_cache_behavior {
    path_pattern           = "/sounds/*"
    target_origin_id       = "${var.project_prefix}-saburo-frontend-origin"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id          = aws_cloudfront_cache_policy.static_assets_cache_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_custom_origin.id
  }

  # アイコンファビコン用
  ordered_cache_behavior {
    path_pattern           = "/favicon.ico"
    target_origin_id       = "${var.project_prefix}-saburo-frontend-origin"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id          = aws_cloudfront_cache_policy.static_assets_cache_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_custom_origin.id
  }

  # デフォルト（すべてのHTMLページ・SPAルート）
  default_cache_behavior {
    target_origin_id       = "${var.project_prefix}-saburo-frontend-origin"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id          = aws_cloudfront_cache_policy.spa_cache_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_custom_origin.id
  }

  # SPAルート対応（すべての4xxエラーを index.html へリダイレクト）
  custom_error_response {
    error_code            = 400
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

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

  custom_error_response {
    error_code            = 405
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