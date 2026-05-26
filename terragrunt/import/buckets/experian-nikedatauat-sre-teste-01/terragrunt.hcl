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

}

terraform {
  source = local.enabled ? "git::https://code.experian.local/scm/nikesre/terraform-s3.git?ref=v1.6.5" : null
}

inputs = {
  env                           = include.root.locals.env
  bucket_name                   = "experian-nikedatauat-sre-teste-01"
  payer                         = "Requester"
}