output "step_function_arn" {
  description = "The ARN of the Step Function"
  value       = aws_sfn_state_machine.this.arn
}