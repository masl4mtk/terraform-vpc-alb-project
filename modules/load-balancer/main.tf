resource "aws_alb" "terraform-project-alb" {
  name               = "terraform-project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group]
  subnets            = var.subnet_ids

  tags = {
    Name = "terraform-project-alb"
  }
}

resource "aws_lb_target_group" "terraform-project-tg" {
  name     = "terraform-project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Name = "terraform-project-tg"
  }
}

resource "aws_lb_listener" "terraform-project-listener" {
  load_balancer_arn = aws_alb.terraform-project-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform-project-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "terraform-project-tg-attachment" {
  target_group_arn = aws_lb_target_group.terraform-project-tg.arn
  target_id        = var.instance_id
  port             = 80
}
