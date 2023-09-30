resource "aws_wafv2_web_acl" "web_acl1" {
  name        = "prod-wss-test"
  description = "For prod wss"
  scope       = "CLOUDFRONT" # CLOUDFRONT(must also specify the region us-east-1 (N. Virginia)), REGIONAL

  default_action {
    allow {}
  }

  rule {
    name     = "block-ip"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rule-block-ip"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block-country"
    priority = 2

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["US"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rule-block-country"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block-query"
    priority = 3

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }
        positional_constraint = "EXACTLY" # EXACTLY, STARTS_WITH, ENDS_WITH, CONTAINS, CONTAINS_WORD
        search_string         = "/abc"
        text_transformation {
          priority = 1
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rule-block-query"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Tag1 = "Value1"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl-prod-wss-test"
    sampled_requests_enabled   = true
  }
}

data "aws_cloudfront_distribution" "test" {
  arn = "arn:aws:cloudfront::123456789012:distribution/EATDVGD171BHDS1"
}

resource "aws_wafv2_web_acl_association" "enable_web_acl" {
  resource_arn = aws_cloudfront_distribution.test.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl1.arn
}
