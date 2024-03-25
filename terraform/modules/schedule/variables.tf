# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# You must provide a value for each of these variables
# ------------------------------------------------------------------------------

variable "input" {
  description = "Input for the workflow"
  type        = string
}

variable "step_function_arn" {
  description = "ARN of the Step Function"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults but can be modified
# ------------------------------------------------------------------------------

variable "name" {
  description = "A name for the schedule"
  type        = string
  default     = "resource-cleanup"
}

variable "schedule" {
  description = "How often the workflow will run. Rate expressions -> https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rate-expressions.html"
  type        = string
  default     = "rate(1 day)"
}