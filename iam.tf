# == IAM == #

# == IAM - role for container task == #
resource "aws_iam_role" "nginx_container" {
  name                  = "${local.name}_ecs_container_role"
  path                  = "/ecs/"
  force_detach_policies = true

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# == IAM - attach container policy to container role.

resource "aws_iam_role_policy_attachment" "container_role_attachment" {
  role       = aws_iam_role.nginx_container.name
  policy_arn = module.container-policy.arn
}

# == IAM - Container Policy == #
module "container-policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name   = "${local.name}-container-policy"
  policy = data.template_file.container_s3_policy.rendered
}

data "template_file" "container_s3_policy" {
  template = file("./files/container_s3_policy.tpl")

  vars = {
    s3_bucket_arn = module.s3-bucket.this_s3_bucket_arn
  }
}

# == IAM - EC2 Instances == #

resource "aws_iam_role" "ec2_role" {
  name = "${local.name}_ecs_instance_role"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  tags               = local.tags
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name}_ecs_instance_profile"
  role = aws_iam_role.ec2_role.name

}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.ec2_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"

}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.ec2_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"

}