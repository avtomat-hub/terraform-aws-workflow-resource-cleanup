# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# You must provide a value for each of these variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults but can be modified
# ------------------------------------------------------------------------------

variable "name" {
  description = "A unique name for the Step Function"
  type        = string
  default     = "resource-cleanup"
}

variable "lambda_function_names" {
  description = "A list of lambda names which comprise this Step Function"
  type        = list(any)
  default     = [{ name : "ec2-images", next : "ec2-snapshots" }, { name : "ec2-snapshots", next : "finish" }]
}
