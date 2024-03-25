# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# You must provide a value for each of these variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults but can be modified
# ------------------------------------------------------------------------------

variable "bucket_prefix" {
  description = "The prefix for the bucket name"
  type        = string
  default     = "resource-cleanup-"
}