terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForEcred/terraform.tfstate"
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
    "AppID"          = "23346"
    "CostString"     = "1800.BR.134.602018"
    "CreateBy"       = "Terraform"
    "Data_Category"  = "behavioral"
    "Data_Type"      = "pp"
    "Environment"    = "dev"
    "Flow"           = "controlador"
    "map-migrated"   = "d-server-02n52mmgua5hr6"
    "Name"           = "BURoleForEcred"
    "Project"        = "datahub"
    "Service"        = "latam_nike"
    "Solution"       = "ecred"
    "Squad"          = "comportamental"
    "Sustain"        = "true"
    "wiz_cig"        = "true"
    "version"        = "2"
  }
}

module "BURoleForEcred" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.1"

  env                     = local.common_tags.Environment
  name                    = "BURoleForEcred"
  assume_role_policy      = file("trust.json")  # Trusted Policy
  instace_profile_created = true
  
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::730335661246:policy/BUPolicyForEcred",
    "arn:aws:iam::730335661246:policy/AmazonEMRCleanupPolicy"
  ]
}
