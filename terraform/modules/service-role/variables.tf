# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# You must provide a value for each of these variables
# ------------------------------------------------------------------------------

variable "hub_account_id" {
  description = "AWS Account ID where workflow is deployed"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults but can be modified
# ------------------------------------------------------------------------------

variable "name" {
  description = "The name of the service role"
  type        = string
  default     = "ResourceCleanupServiceRole"
}