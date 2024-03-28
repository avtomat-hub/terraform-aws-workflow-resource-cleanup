# ------------------------------------------------------------------------------
# REMOTE SOURCE
# To reference modules remotely from your code supply a Git URL, pinning to a specific version:
# source = "git@github.com:avtomat-hub/aws-workflow-resource-cleanup.git//terraform/modules/<module>?ref=0.0.1"
# ------------------------------------------------------------------------------

module "ec2-snapshots" {
  source = "../../modules/ec2-snapshots"
}

module "ec2-images" {
  source = "../../modules/ec2-images"
}

module "bucket" {
  source = "../../modules/bucket"
}

module "step-function" {
  source = "../../modules/step-function"
}

module "schedule" {
  source = "../../modules/schedule"

  input = templatefile("${path.module}/config.json", {
    bucket_name = module.bucket.bucket_name
  })
  step_function_arn = module.step-function.step_function_arn
}