variable "name_prefix" { type = string }

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${var.name_prefix}-api"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "api_high_cpu" {
  alarm_name          = "${var.name_prefix}-ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS API task CPU above 80%"
  treat_missing_data  = "notBreaching"
}

output "ecs_log_group_name" { value = aws_cloudwatch_log_group.ecs.name }
