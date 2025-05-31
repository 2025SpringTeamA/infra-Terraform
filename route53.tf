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
    name                   = aws_cloudfront_distribution.saburo_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.saburo_distribution.hosted_zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "PRIMARY"
  }
}

# API サブドメイン用の Route53 レコード
resource "aws_route53_record" "api_subdomain" {
  zone_id = data.aws_route53_zone.saburo.zone_id
  name    = "api.saburo.xyz"
  type    = "A"

  alias {
    name                   = aws_lb.main_alb.dns_name
    zone_id                = aws_lb.main_alb.zone_id
    evaluate_target_health = true
  }
}