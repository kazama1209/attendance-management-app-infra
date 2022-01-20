resource "aws_ecs_cluster" "main" {
  name = "${var.rsrc_prefix}-cluster"
}

data "template_file" "container_definitions" {
  template = file("./task-definitions/containers.json")
  
  vars = {
    rsrc_prefix         = var.rsrc_prefix
    aws_account_id      = var.aws_account_id
    database_host       = var.database_host
    database_username   = var.database_username
    database_password   = var.database_password
    database_name       = var.database_name
    app_host            = var.app_host
    rails_log_to_stdout = var.rails_log_to_stdout
    rails_master_key    = var.rails_master_key
    mailer_user_name    = var.mailer_user_name
    mailer_password     = var.mailer_password
   }
}

resource "aws_ecs_task_definition" "containers" {
  family                   = var.rsrc_prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
  cpu                      = 256
  memory                   = 512
  container_definitions    = data.template_file.container_definitions.rendered
}

resource "aws_ecs_service" "main" {
  cluster                            = aws_ecs_cluster.main.id
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  name                               = "${var.rsrc_prefix}-service"
  task_definition                    = aws_ecs_task_definition.containers.arn
  desired_count                      = 1 # 常に1つのタスクが稼働する状態にする

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets          = [
      aws_subnet.public_1a.id,
      aws_subnet.public_1c.id
    ]

    security_groups  = [
      aws_security_group.app.id,
      aws_security_group.db.id
    ]

    assign_public_ip = "true"
  }
}
