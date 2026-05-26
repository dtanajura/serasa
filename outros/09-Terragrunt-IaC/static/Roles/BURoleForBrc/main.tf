terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForBrc/terraform.tfstate"
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
    "AppID"          = "21809"
    "CostString"     = "1800.BR.134.602018"
    "CreateBy"       = "Terraform"
    "Data_Category"  = "behavioral"
    "Data_Type"      = "pp"
    "Environment"    = "dev"
    "Flow"           = "controlador"
    "map-migrated"   = "d-server-02n52mmgua5hr6"
    "Name"           = "BURoleForBrc"
    "Project"        = "datahub"
    "Service"        = "latam_nike"
    "Solution"       = "brc"
    "Squad"          = "comportamental"
    "Sustain"        = "true"
    "wiz_cig"        = "true"
  }
}

module "BURoleForBrc" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.1"

  env                = local.common_tags.Environment
  name               = "BURoleForBrc"
  assume_role_policy = file("trust.json")  # Trusted Policy
  
  policy_arns = [
    "arn:aws:iam::730335661246:policy/BUPolicyForBrc",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::730335661246:policy/AmazonEMRCleanupPolicy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-ec2-role-policy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-encryption-policy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-role-policy"
  ]
}