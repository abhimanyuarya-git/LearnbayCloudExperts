resource "aws_cloudwatch_metric_alarm" "ec2-high-cpu" {
  alarm_name          = "${var.name}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  actions_enabled     = "true"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_out_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2-low-cpu" {
  alarm_name          = "${var.name}-low-cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.cpu_low_threshold
  actions_enabled     = "true"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_in_policy.arn]
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale-out-policy"
  scaling_adjustment     = var.scale_up_count
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-in-policy"
  scaling_adjustment     = var.scale_down_count
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
}

/////////////////////////////////////
# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "asg" {
  name        = "${var.name}-sg"
  description = "Security group for the ${var.name} launch configuration"
  vpc_id      = var.vpc_id

  tags = var.common_tags
}

resource "aws_security_group_rule" "ad_ec2_sg_rules" {
  for_each    = var.security_group_cidr_rules
  type        = each.value[0]
  from_port   = each.value[2]
  to_port     = each.value[3]
  protocol    = each.value[1]
  description = each.value[5]

  cidr_blocks       = flatten([each.value[4]])
  security_group_id = aws_security_group.asg.id
}

resource "aws_security_group_rule" "ec2_sg_prefix_rules" {
  for_each          = var.security_group_prefix_rules
  type              = each.value[0]
  from_port         = each.value[2]
  to_port           = each.value[3]
  protocol          = each.value[1]
  description       = each.value[5]
  prefix_list_ids   = [each.value[4]]
  security_group_id = aws_security_group.asg.id

}
