resource "aws_ecs_cluster" "foo" {
  name               = var.team
  capacity_providers = var.capacity_providers
  
  tags               = var.tags
}

