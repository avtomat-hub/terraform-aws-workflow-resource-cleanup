# ------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ------------------------------------------------------------------------------
# Option 1

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# Option 2
# AWS_PROFILE

# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# You must provide a value for each of these variables
# ------------------------------------------------------------------------------

variable "hub_account_id" {
  description = "Service account hosting the workflow"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket used by the workflow"
  type        = string
}

variable "client_name" {
  description = "The name of the client"
  type        = string
}

variable "step_function_arn" {
  description = "Step function orchestrating the workflow"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults but can be modified
# ------------------------------------------------------------------------------

variable "workflow_short_name" {
  description = "The short name of the workflow"
  type        = string
  default     = "rc"
}