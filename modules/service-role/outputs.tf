output "service-role-arn" {
  description = "The ARN of the service role used by the workflow"
  value       = aws_iam_role.this.arn
}