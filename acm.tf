resource "aws_acm_certificate" "main" {
  domain_name = data.aws_route53_zone.main.name
  subject_alternative_names  = ["*.${data.aws_route53_zone.main.name}"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.rsrc_prefix}-acm"
  }
}
