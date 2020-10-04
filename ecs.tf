# == ECS == #
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name   = local.name
  tags   = local.tags
}

resource "aws_ecs_task_definition" "nginx_tsk" {
  family                = local.resources_name
  container_definitions = file("./files/task-definition.json")
  task_role_arn         = aws_iam_role.nginx_container.arn
  tags                  = local.tags
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = module.ecs.this_ecs_cluster_id
  task_definition = aws_ecs_task_definition.nginx_tsk.arn
  desired_count   = 2
  depends_on = [
    aws_iam_role.ec2_role,
    module.s3-bucket
  ]

}