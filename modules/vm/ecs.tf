resource "aws_ecs_cluster" "ecs" {
  name = "${local.full_name}-ecs-cluster"
}

data "aws_ssm_parameter" "ecs_image_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_configuration" "ecs" {
  name = "${local.full_name}-ecs-launch-configuration"
  image_id = data.aws_ssm_parameter.ecs_image_id.value
  instance_type = local.vm_instance_type
  iam_instance_profile = aws_iam_instance_profile.instance.name

  root_block_device {
    volume_type = "standard"
    volume_size = 100
    delete_on_termination = true
  }

  security_groups = [
    aws_security_group.ecs.id,
    var.db_access_security_group_id
  ]

  associate_public_ip_address = true
  key_name = var.key_pair_name
  user_data = <<EOF
  #!/bin/bash
  echo ECS_CLUSTER=${aws_ecs_cluster.ecs.name} >> /etc/ecs/ecs.config
  EOF
}

resource "aws_autoscaling_group" "asg" {
  name = "${local.full_name}-ecs-asg"

  vpc_zone_identifier = var.private_subnet_ids
  launch_configuration = aws_launch_configuration.ecs.name

  min_size = var.min_instance_size
  max_size = var.max_instance_size
  desired_capacity = var.desired_capacity
}
