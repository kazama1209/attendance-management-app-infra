resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.rsrc_prefix}"
}
