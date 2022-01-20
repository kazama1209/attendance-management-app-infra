resource "aws_alb" "main" {
  name                       = "${var.rsrc_prefix}-alb"
  security_groups            = [aws_security_group.alb.id]

  subnets                    = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]

  internal                   = false
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
  }
}

resource "aws_alb_target_group" "main" {
  name                 = "${var.rsrc_prefix}-alb-tg"
  port                 = 80
  depends_on           = [aws_alb.main]
  target_type          = "ip"
  protocol             = "HTTP"
  vpc_id               =  aws_vpc.main.id
  deregistration_delay = 15

  health_check {
    interval            = 30
    path                = "/health_check" # 適宜変更
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    target_group_arn = aws_alb_target_group.main.arn
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "http_to_https" {
  depends_on         = [aws_alb_target_group.main]
  listener_arn       = aws_alb_listener.http.arn
  priority           = 100

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  
  condition {
    path_pattern {
      values = ["${var.domain_name}"]
    }
  }
}
