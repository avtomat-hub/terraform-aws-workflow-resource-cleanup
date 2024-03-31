# ------------------------------------------------------------------------------
# REMOTE SOURCE
# To reference modules remotely from your code supply a Git URL, pinning to a specific version:
# source = "git@github.com:avtomat-hub/aws-workflow-resource-cleanup.git//modules/<module>?ref=0.0.1"
# ------------------------------------------------------------------------------

module "service-role-111111111111" {
  source = "../../../../modules/service-role"

  hub_account_id = var.hub_account_id

  providers = {
    aws = aws.spoke-111111111111
  }
}

module "service-role-222222222222" {
  source = "../../../../modules/service-role"

  hub_account_id = var.hub_account_id

  providers = {
    aws = aws.spoke-222222222222
  }
}