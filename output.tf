output "arn" {
  value       = try(aws_sns_topic.vss.arn, "")
}