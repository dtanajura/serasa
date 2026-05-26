include "root" {
  path = find_in_parent_folders()
  expose = true
}

locals {
  enabled = true
}

terraform {
  source = local.enabled ? "git::https://code.experian.local/scm/nikesre/terraform-iam-policy.git?ref=v1.2.5" : null
}

inputs = {
  env = include.root.locals.env
    assume_role_policy = file("trust.json")  # Trusted Policy
    name = "BUPolicyForAssumeRole"
    policy = file("policies/configpolicy.json")
}
