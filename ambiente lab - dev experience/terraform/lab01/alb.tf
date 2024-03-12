resource "aws_alb" "sample" {
  name            = "sample-alb"
  internal        = false
  security_groups = [aws_security_group.alb.id]
  subnets         = aws_subnet.alb_subnets.*.id

  idle_timeout               = 60
  enable_deletion_protection = false

  tags = {
    Name = "sample-alb"
  }
}
resource "aws_alb_listener" "sample" {
  load_balancer_arn = aws_alb.sample.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_alb_target_group.sample.arn
  }
}

resource "aws_alb_target_group" "sample" {
  name     = "sample-target-group"
  port     = 80
  protocol = "HTTP"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}