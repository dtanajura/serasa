terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForPep/terraform.tfstate"
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
    "AppID"          = "16977"
    "CostString"     = "1800.BR.134.602018"
    "CreateBy"       = "Terraform"
    "Data_Category"  = "N/A"
    "Data_Type"      = "N/A"
    "Environment"    = "dev"
    "Flow"           = "operador"
    "map-migrated"   = "d-server-02n52mmgua5hr6"
    "Name"           = "BURoleForPep"
    "Project"        = "datahub"
    "Service"        = "latam_nike"
    "Solution"       = "pep"
    "Squad"          = "cadastral"
    "Sustain"        = "true"
    "wiz_cig"        = "true"
  }
}

module "BURoleForPep" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.1"

  instace_profile_created = true

  env                = local.common_tags.Environment
  name               = "BURoleForPep"
  assume_role_policy = file("trust.json")  # Trusted Policy

  policy_arns = [
    "arn:aws:iam::730335661246:policy/BUPolicyForPep",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-ec2-role-policy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-encryption-policy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-role-policy"
  ]
}
