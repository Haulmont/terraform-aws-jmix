resource "aws_ecs_task_definition" "task_definition" {
  family = "${local.full_name}-definition"
  container_definitions = local.task_definition_json
}

locals {
  task_definition_json = jsonencode([
    {
      name = var.project_name
      image = var.image
      cpu = 10
      memory = 800
      essential = true
      portMappings = [
        {
          hostPort = var.server_port
          containerPort = var.server_port
          protocol = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = aws_cloudwatch_log_group.logs.name
          "awslogs-region" = data.aws_region.current.name
          "awslogs-stream-prefix" = "awslogs-${local.full_name}"
        }
      }
      environment = [for key, value in var.env: {
        name = key
        value = value
      }]
    }
  ])
}

data "aws_region" "current" {}