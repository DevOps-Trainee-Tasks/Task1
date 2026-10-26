terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_ssm_parameter" "ami" {
  name = var.ami_ssm_parameter_name
}

resource "aws_launch_template" "application_launch_template" {
  name          = var.launch_template_name
  image_id      = data.aws_ssm_parameter.ami.value
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false
    security_groups             = var.security_group_ids
  }

  block_device_mappings {
    device_name = var.root_device_name

    ebs {
      volume_size           = var.root_volume_size_gib
      volume_type           = var.root_volume_type
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = base64encode(templatefile(var.user_data_script_path, {
    ollama_model = var.ollama_model
    ollama_port  = var.ollama_port
  }))

  tags = merge(var.tags, {
    Name = var.launch_template_name
  })
}

resource "aws_autoscaling_group" "application_autoscaling_group" {
  name                      = var.autoscaling_group_name
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.application_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking_policy" {
  name                   = var.scaling_policy_name
  autoscaling_group_name = aws_autoscaling_group.application_autoscaling_group.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.scaling_metric_type
    }

    target_value = var.cpu_target_value
  }
}
