resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.rsrc_prefix}-alb-logs"
}
