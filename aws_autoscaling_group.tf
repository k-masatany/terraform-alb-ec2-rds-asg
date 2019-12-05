resource "aws_autoscaling_group" "asg" {
  name = "${var.settings.app_name}-asg-${terraform.workspace}"

  availability_zones = [
    "ap-northeast-1a",
    "ap-northeast-1c",
    "ap-northeast-1d",
  ]

  vpc_zone_identifier = [
    "${aws_subnet.main-vpc-public-a.id}",
    "${aws_subnet.main-vpc-public-c.id}",
    "${aws_subnet.main-vpc-public-d.id}",
  ]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.lt.id}"
        version            = "${aws_launch_template.lt.latest_version}"
      }
    }
  }

  min_size                  = "${lookup(var.settings, "${terraform.workspace}.asg_min_size")}"
  max_size                  = "${lookup(var.settings, "${terraform.workspace}.asg_max_size")}"
  health_check_grace_period = "${lookup(var.settings, "${terraform.workspace}.asg_health_check_grace_period")}"

  tag {
    key                 = "Name"
    value               = "${var.settings.app_name}-${terraform.workspace}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${terraform.workspace}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_launch_template.lt",
  ]
}
