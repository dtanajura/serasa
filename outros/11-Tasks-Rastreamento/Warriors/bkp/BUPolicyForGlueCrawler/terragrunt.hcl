# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


# Include the root `terragrunt.hcl` configuration
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  enabled     = true
  policy_vars = read_terragrunt_config("policy.hcl")
}

terraform {
  source = local.enabled ? "git::https://code.experian.local/scm/nikesre/terraform-iam-policy.git?ref=v1.2.5" : null
}

inputs = {
  env    = include.root.locals.env
  name   = "BUPolicyForGlueCrawler"
  policy = local.policy_vars.locals.policy
}