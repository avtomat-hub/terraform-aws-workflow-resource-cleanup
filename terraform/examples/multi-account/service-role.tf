# ------------------------------------------------------------------------------
# REMOTE SOURCE
# To reference modules remotely from your code supply a Git URL, pinning to a specific version:
# source = "git@github.com:avtomat-hub/aws-workflow-resource-cleanup.git//terraform/modules/<module>?ref=0.0.1"
# ------------------------------------------------------------------------------

module "service-role-hub" {
  source = "../../modules/service-role"

  hub_account_id = "333333333333"
}

module "service-role-spoke-111111111111" {
  source = "../../modules/service-role"

  hub_account_id = "333333333333"

  providers = {
    aws = aws.spoke-111111111111
  }
}