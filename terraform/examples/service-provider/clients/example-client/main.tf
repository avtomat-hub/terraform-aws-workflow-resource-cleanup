# ------------------------------------------------------------------------------
# REMOTE SOURCE
# To reference modules remotely from your code supply a Git URL, pinning to a specific version:
# source = "git@github.com:avtomat-hub/aws-workflow-resource-cleanup.git//terraform/modules/<module>?ref=0.0.1"
# ------------------------------------------------------------------------------

module "schedule" {
  source = "../../../../modules/schedule"

  name              = "${var.workflow_short_name}-${var.client_name}"
  step_function_arn = var.step_function_arn
  input             = templatefile("${path.module}/config.json", { bucket_name = var.bucket_name })
}