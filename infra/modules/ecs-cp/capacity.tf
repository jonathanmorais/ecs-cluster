resource "aws_launch_configuration" "lc" {
  name                 = "${var.ecs_cluster}-${var.name}-ECSLaunchConfiguration"
  image_id             = "ami-ecd5e884" ## ecs image optmize
  instance_type        = var.instace_type
  iam_instance_profile = "ecsInstanceRole"
  security_groups      = var.network.security_groups

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
echo ECS_DATADIR=/data >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS=[\"gelf\",\"awslogs\"] >> /etc/ecs/ecs.config
echo ECS_LOGLEVEL=WARN >> /etc/ecs/ecs.config
sudo start ecs
EOF
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.ecs_cluster}-${var.name}-ECSAutoSalingGroup"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.min_size
  force_delete              = true
  launch_configuration      = aws_launch_configuration.lc.name
  vpc_zone_identifier       = var.network.subnets
  protect_from_scale_in     = true
  tags                      = var.asg_tags

  lifecycle {
    ignore_changes = ["desired_capacity"]
  }
}

resource "aws_ecs_capacity_provider" "cp" {
  name = "${var.ecs_cluster}-${var.name}-ECSCapacityProvider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = var.max_size
      minimum_scaling_step_size = var.min_size
      status                    = "ENABLED"
      target_capacity           = var.target_capacity
    }
  }

  tags = var.tags
}
