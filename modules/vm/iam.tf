data "aws_iam_policy_document" "service" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "service" {
  name = "ecs-service-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.service.json
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role = aws_iam_role.service.name
}

data "aws_iam_policy_document" "instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name = "ecs-instance-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.instance.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role = aws_iam_role.instance.name
}

resource "aws_iam_instance_profile" "instance" {
  name = "ecs-instance-profile"
  path = "/"
  role = aws_iam_role.instance.name
}
