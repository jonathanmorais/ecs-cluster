resource "aws_ecs_cluster" "foo" {
  name = var.team

  tags = var.tags
}

