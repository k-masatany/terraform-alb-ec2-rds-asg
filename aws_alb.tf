resource "aws_alb" "alb" {
  idle_timeout    = 60
  name            = "${var.settings.app_name}-${terraform.workspace}"
  security_groups = ["${aws_security_group.main-vpc-alb.id}"]

  subnets = [
    "${aws_subnet.main-vpc-public-a.id}",
    "${aws_subnet.main-vpc-public-c.id}",
    "${aws_subnet.main-vpc-public-d.id}",
  ]

  tags = {
    Description = "This resource was created through Terraform"
  }
}

resource "aws_alb_target_group" "target_group" {
  name                 = "${var.settings.app_name}-${terraform.workspace}"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = "${aws_vpc.main.id}"
  deregistration_delay = 15

  health_check {
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = 200
  }
}

resource "aws_alb_listener" "http-listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https-listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "${lookup(var.settings, "${terraform.workspace}.alb_certificate_arn")}"

  default_action {
    target_group_arn = "${aws_alb_target_group.target_group.arn}"
    type             = "forward"
  }
}
