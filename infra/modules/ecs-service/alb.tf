resource "aws_lb_target_group" "alb_tg" {
  count       = var.alb.enable ? 1 : 0
  name        = local.service_id
  port        = var.container.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.network.vpc

  health_check {
    path                = var.alb.health
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb" "alb" {
  count                      = var.alb.enable ? 1 : 0
  name                       = local.service_id
  internal                   = ! var.alb.public
  load_balancer_type         = "application"
  security_groups            = var.alb.security_groups
  subnets                    = var.alb.subnets
  enable_deletion_protection = true
  tags                       = var.tags
  idle_timeout               = var.alb.idle_timeout

}

resource "aws_lb_listener" "alb_listener_http" {
  count             = var.alb.enable ? 1 : 0
  load_balancer_arn = aws_lb.alb[count.index].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg[count.index].arn
  }

  depends_on = [aws_lb.alb, aws_lb_target_group.alb_tg]
}

# data "aws_acm_certificate" "acm_certificate" {
#   count = var.alb.enable && var.alb.public ? 1 : 0
#   domain      = var.alb.certificate_domain
#   statuses    = ["ISSUED"]
#   most_recent = true
# }

resource "aws_acm_certificate" "acm_certificate" {
  count             = var.alb.enable && var.alb.public ? 1 : 0
  domain_name       = var.alb.certificate_domain
  validation_method = "DNS"
  tags              = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "alb_listener_https" {
  count             = var.alb.enable && var.alb.public ? 1 : 0
  load_balancer_arn = aws_lb.alb[count.index].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.acm_certificate[count.index].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg[count.index].arn
  }
  depends_on = [aws_lb.alb, aws_lb_target_group.alb_tg]
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  count        = var.alb.enable && var.alb.public ? 1 : 0
  listener_arn = aws_lb_listener.alb_listener_http[count.index].arn

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}