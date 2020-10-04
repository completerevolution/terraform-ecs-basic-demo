# main.tf

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "random_pet" "s3_bucket_name" {
  length = 2
}

locals {
  s3_bucket_name = "a1b2c3-ecs-${random_pet.s3_bucket_name.id}"
  instance_type  = "t2.micro"
  name           = "ali-fay-demo"
  environment    = "dev"
  resources_name = "${local.name}-${local.environment}"
  tags = {
    Terraform   = "true"
    Environment = "${local.environment}"
    Client      = "${local.name}"
  }
}

output "alb_endpoint" {
  description = "FQDN of ALB for ECS"
  value       = module.alb.this_lb_dns_name
}

# == Main execution == #

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true

  tags = local.tags
}

# == S3 == #

module "s3-bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = local.s3_bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }

  tags = local.tags
}

