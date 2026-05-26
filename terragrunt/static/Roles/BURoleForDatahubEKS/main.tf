terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForDatahubEKS/terraform.tfstate"
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
    "Project"        = "datahub"
    "Service"        = "latam_nike"
    "wiz_cig"        = "true"
  }
}

module "BURoleForDatahubEKS" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.4"

  env                = local.common_tags.Environment
  name               = "BURoleForDatahubEKS"
  assume_role_policy = file("trust.json")  # Trusted Policy
  
  policy_arns = [
    "arn:aws:iam::730335661246:policy/BUPolicyForAssumeRole",
    "arn:aws:iam::730335661246:policy/BUPolicyForDatahubEKS"
  ]
}