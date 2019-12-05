resource "aws_autoscaling_policy" "cpu" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  name                   = "cpu"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "${lookup(var.settings, "${terraform.workspace}.asg_cpu_tracking_value")}"
  }
}
