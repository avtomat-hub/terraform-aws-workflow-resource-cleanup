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

variable "region" {
  description = "The region to deploy to"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults but can be modified
# ------------------------------------------------------------------------------