# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# You must provide a value for each of these variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults but can be modified
# ------------------------------------------------------------------------------

variable "service_role_name" {
  description = "Name of the role deployed to accounts serviced by the workflow"
  type        = string
  default     = "ResourceCleanupServiceRole"
}

variable "name" {
  description = "A unique name for the Lambda Function"
  type        = string
  default     = "resource-cleanup-ec2-images"
}

variable "description" {
  description = "A description of the workflow"
  type        = string
  default     = "Deletes images older than certain days"
}

variable "layer_name" {
  description = "The name of the Avtomat AWS layer"
  type        = string
  default     = "avtomat-aws"
}

variable "handler" {
  description = "Lambda Function entrypoint"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "architectures" {
  description = "arm64 – 64-bit ARM or x86_64 – 64-bit x86 "
  type        = string
  default     = "x86_64"
}

variable "memory_size" {
  description = "Amount of memory in MB the Lambda Function can use at runtime. Valid value between 128 MB to 10,240 MB (10 GB), in 64 MB increments."
  type        = number
  default     = 190
}

variable "timeout" {
  description = "The amount of time the Lambda Function has to run in seconds."
  type        = number
  default     = 240
}

variable "runtime" {
  description = "The runtime of the Lambda Function"
  type        = string
  default     = "python3.11"
}

variable "cloudwatch_log_retention_in_days" {
  description = "The number of days log events are retained in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = 14
}