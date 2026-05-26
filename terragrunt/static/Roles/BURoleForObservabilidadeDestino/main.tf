terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForObservabilidadeDestino/terraform.tfstate"
  }
}

provider "aws" {
  region = "sa-east-1"
  profile = "datahubdev"
  default_tags {
    tags = local.common_tags
  }
}
locals {
  common_tags = {
    "Asset_Category" = "Development"
    "AppID"          = "N/A"
    "CostString"     = "1800.BR.134.602018" 	
    "CreateBy"       = "Terraform"
    "Data_Category"  = "N/A"
    "Data_Type"      = "N/A"
    "Environment"    = "dev"
    "map-migrated"   = "d-server-02n52mmgua5hr6"
    "Project"        = "nike"
    "Service"        = "latam_nike"
    "wiz_cig"        = "true"
  }
}

module "BUPolicyForObservabilidadeDestino" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-policy.git?ref=v1.0.5"

  env    = local.common_tags.Environment
  name   = "BUPolicyForObservabilidadeDestino"
  policy = file("policy.json")
}

module "BURoleForObservabilidadeDestino" {
  source       = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.0.8"
  
  env                = local.common_tags.Environment
  name               = "BURoleForObservabilidadeDestino"
  assume_role_policy = file("role.json")
  policy_arns        = [
    {
      arn = "${module.BUPolicyForObservabilidadeDestino.iam_policy_id}"
    }
  ]

  depends_on = [module.BUPolicyForObservabilidadeDestino]
}
