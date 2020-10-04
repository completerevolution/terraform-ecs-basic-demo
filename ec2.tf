# == EC2 == #



data "aws_ami" "ecs_image" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "template_file" "user_data" {
  template = file("./files/ec2_userdata.tpl")

  vars = {
    cluster_name = local.name
  }
}

module "autoscaling" {
  source                       = "terraform-aws-modules/autoscaling/aws"
  version                      = "3.6.0"
  name                         = local.resources_name
  instance_type                = local.instance_type
  image_id                     = data.aws_ami.ecs_image.image_id
  iam_instance_profile         = aws_iam_instance_profile.ec2_profile.id
  recreate_asg_when_lc_changes = true
  desired_capacity             = 2
  max_size                     = 3
  min_size                     = 1
  health_check_type            = "EC2"
  user_data                    = data.template_file.user_data.rendered
  vpc_zone_identifier          = module.vpc.private_subnets
  security_groups = [
    data.aws_security_group.default.id,
    module.sg_priv_http_8080.this_security_group_id
  ]
  depends_on = [
    module.sg_priv_http_8080.this_security_group_id
  ]
  target_group_arns = module.alb.target_group_arns
  tags = [
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.name
      propagate_at_launch = true
    },
    {
      key                 = "AmazonECSManaged"
      value               = ""
      propagate_at_launch = true
    }
  ]

}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name               = local.resources_name
  load_balancer_type = "application"
  security_groups = [
    data.aws_security_group.default.id,
    module.sg_pub_world_http_80.this_security_group_id,
  ]
  subnets = module.vpc.public_subnets
  vpc_id  = module.vpc.vpc_id

  ip_address_type = "ipv4"

  http_tcp_listeners = [
    {
      target_group_index = 0
      port               = 80
      protocol           = "HTTP"
    },
  ]

  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
    },
  ]
}