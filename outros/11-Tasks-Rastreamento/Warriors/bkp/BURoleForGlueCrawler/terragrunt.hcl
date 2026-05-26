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
  enabled = true
  trusted_policy_vars = read_terragrunt_config("trusted_policy.hcl")
}

dependency "BUPolicyForGlueCrawler" {
  config_path = "../../policies/BUPolicyForGlueCrawler"

  mock_outputs = {
    iam_policy_id = "fake_id"
  }
}

terraform {
  source = local.enabled ? "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.4.3" : null
}

inputs = {
  env                = include.root.locals.env
  name               = "BURoleForGlueCrawler"
  assume_role_policy = local.trusted_policy_vars.locals.trusted_policy
  policy_arns        = ["${dependency.BUPolicyForGlueCrawler.outputs.iam_policy_id}"]
}
