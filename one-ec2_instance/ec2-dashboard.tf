resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  dashboard_name = "ec2-dashboard"
  dashboard_body = file("dashboards/ec2-dash.json")
}

resource "aws_cloudwatch_composite_alarm" "ec2_alarms" {
  alarm_description = "Composite alarm that monitors CPUUtilization "
  alarm_name        = "ec2_composite_alarm"
  alarm_actions = [aws_sns_topic.ec2_topic.arn]

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.ec2_cpu_usage_alarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.ebs_write_operations.alarm_name})"

  depends_on = [
    aws_cloudwatch_metric_alarm.ec2_cpu_usage_alarm,
    aws_sns_topic.ec2_topic,
    aws_sns_topic_subscription.ec2_subscription
  ]
}

# Creating the AWS CLoudwatch Alarm that will autoscale the AWS EC2 instance based on CPU utilization.
resource "aws_cloudwatch_metric_alarm" "ebs_write_operations" {
  # defining the name of AWS cloudwatch alarm
    alarm_name          = "ec2_ebs_write_operations_alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
  
  # Defining the metric_name 
  metric_name = "DiskReadOps"
  
  # The namespace for the alarm's associated metric
  namespace = "AWS/EC2"
  
  # After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds 
  period = "60"
  statistic = "Average"
 
  threshold = "10"
  
  alarm_description     = "This metric monitors ec2 readops exceeding 10 reads"
}

# Creating the AWS CLoudwatch Alarm that will autoscale the AWS EC2 instance based on CPU utilization.
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_usage_alarm" {
  # defining the name of AWS cloudwatch alarm
    alarm_name          = "ec2_cpu_usage_alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"

  # Defining the metric_name according to which scaling will happen (based on CPU) 
    metric_name = "CPUUtilization"

  # The namespace for the alarm's associated metric
    namespace = "AWS/EC2"

  # After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds 
    period = "60"
    statistic = "Average"

  # CPU Utilization threshold is set to 10 percent
    threshold = "70"

  # which instance to watch ?
  #dimensions = {
  #   InstanceId = aws_instance.ec2-instance.id
  #}
    
  alarm_description  = "This metric monitors ec2 cpu utilization exceeding 70%"
}

resource "aws_cloudwatch_log_group" "ebs_log_group" {
  name = "ebs_log_group"
  retention_in_days = 30
}


resource "aws_cloudwatch_log_stream" "ebs_log_stream" {
  name           = "ebs_log_stream"
  log_group_name = aws_cloudwatch_log_group.ebs_log_group.name
}


resource "aws_sns_topic" "ec2_topic" {
  name = "EC2_topic"
}

resource "aws_sns_topic_subscription" "ec2_subscription" {
  topic_arn = aws_sns_topic.ec2_topic.arn
  protocol  = "email"
  endpoint  = "pearl118@gmail.com"

  depends_on = [
    aws_sns_topic.ec2_topic
  ]
}
