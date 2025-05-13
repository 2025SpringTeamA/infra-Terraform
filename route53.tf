# ホストゾーンを取得
data "aws_route53_zone" "saburo" {
  name = "saburo.xyz"
}

# Route 53 に CloudFront の Aレコードを追加(Primary)
resource "aws_route53_record" "saburo_cloudfront_primary" {
  zone_id        = data.aws_route53_zone.saburo.zone_id
  name           = "saburo.xyz"
  type           = "A"
  set_identifier = "cloudfront-primary"

  alias {
    name                   = aws_cloudfront_distribution.my_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.my_distribution.hosted_zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "PRIMARY"
  }
}

# Route 53 に メンテナンス用 S3 のA レコード（Secondary）
resource "aws_route53_record" "maintenance_failover" {
  zone_id = data.aws_route53_zone.saburo.zone_id
  name    = "saburo.xyz"
  type    = "A"
  set_identifier = "maintenance-backup"

  alias {
    name                   = aws_s3_bucket.maintenance_bucket.website_endpoint
    zone_id                = "Z3AQBSTGFYJSTF"  # S3 静的ホスティング用固定ゾーンID
    evaluate_target_health = false
  }

  failover_routing_policy {
    type = "SECONDARY"
  }
}

# Route 53 に ALB の Aレコードを追加(api.saburo.xyz)
resource "aws_route53_record" "saburo_alb" {
  zone_id = data.aws_route53_zone.saburo.zone_id
  name    = "api.saburo.xyz"
  type    = "A"

  alias {
    name                   = aws_lb.main_alb.dns_name
    zone_id                = aws_lb.main_alb.zone_id
    evaluate_target_health = true
  }
}