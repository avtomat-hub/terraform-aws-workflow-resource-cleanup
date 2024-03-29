# ------------------------------------------------------------------------------
# REMOTE SOURCE
# To reference modules remotely from your code supply a Git URL, pinning to a specific version:
# source = "git@github.com:avtomat-hub/aws-workflow-resource-cleanup.git//terraform/modules/<module>?ref=0.0.1"
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# REQUIRED MODULES
# The below modules are required at all times and should not be removed.
# ------------------------------------------------------------------------------

module "ec2-images" {
  source = "../../modules/ec2-images"
}

module "ec2-snapshots" {
  source = "../../modules/ec2-snapshots"
}

module "ec2-volumes" {
  source = "../../modules/ec2-volumes"
}

module "bucket" {
  source = "../../modules/bucket"
}

module "step-function" {
  source = "../../modules/step-function"
}

# ------------------------------------------------------------------------------
# CLIENT MODULES
# The below modules control schedules and service roles for clients. Remove or add as needed.
# If managing all clients in a single apply is not desired, delete the below modules and apply individually from the clients directory.
# ------------------------------------------------------------------------------

module "example-client" {
  source = "./clients/example-client"

  client_name       = "example-client"
  hub_account_id    = 333333333333
  bucket_name       = module.bucket.bucket_name
  step_function_arn = module.step-function.step_function_arn
}
