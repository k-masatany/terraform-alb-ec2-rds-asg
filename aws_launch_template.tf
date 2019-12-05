data "template_file" "userdata" {
  template = "${file("userdata-${terraform.workspace}.sh")}"
  vars     = {}
}

resource "random_shuffle" "az" {
  input = [
    "${aws_subnet.main-vpc-public-a.id}",
    "${aws_subnet.main-vpc-public-c.id}",
    "${aws_subnet.main-vpc-public-d.id}"
  ]
  result_count = 1
}

resource "aws_launch_template" "lt" {
  name          = "${var.settings.app_name}-asg-${terraform.workspace}"
  image_id      = "${lookup(var.settings, "${terraform.workspace}.ec2_instance_ami")}"
  instance_type = "${lookup(var.settings, "${terraform.workspace}.ec2_instance_type")}"

  key_name = "${aws_key_pair.main-instance-key.id}"

  vpc_security_group_ids = [
    "${aws_security_group.main-vpc-web.id}",
    "${aws_security_group.main-vpc-ssh.id}"
  ]

  user_data = "${base64encode(data.template_file.userdata.rendered)}"

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = "${lookup(var.settings, "${terraform.workspace}.ec2_volume_size")}"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${lookup(var.settings, "app_name")}-${terraform.workspace}"
      Description = "This resource was created through Terraform"
    }
  }
}
