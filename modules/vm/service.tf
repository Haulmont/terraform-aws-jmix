resource "aws_ecs_service" "ecs_service" {
  name = local.full_name
  iam_role = aws_iam_role.service.arn
  cluster = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count = 1

  load_balancer {
    container_name = var.project_name
    container_port = var.server_port
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  depends_on = [
    aws_lb_target_group.target_group,
    aws_autoscaling_group.asg
  ]

  lifecycle {
    create_before_destroy = true
  }
}