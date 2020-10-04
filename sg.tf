# == Security Groups == #

data "aws_security_group" "default" {
  vpc_id = module.vpc.vpc_id
  name   = "default" # AWS name for default group.
}

module "sg_pub_world_http_80" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${local.resources_name}-pub_world_http_80"
  description = "Security group with HTTP 80 ports open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "World access to http 80"
      cidr_blocks = "0.0.0.0/0"
    }

  ]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "all"
      description = "Egress open 80"
      cidr_blocks = "0.0.0.0/0"
    }

  ]
}

module "sg_priv_http_8080" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${local.resources_name}-priv_http_8080"
  description = "SG to permit ALB backend http 8080 to private instances"
  vpc_id      = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "ALB backend to private http 8080"
      source_security_group_id = module.sg_pub_world_http_80.this_security_group_id
    }

  ]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "all"
      description = "Egress open 8080"
      cidr_blocks = "0.0.0.0/0"
    }

  ]
}
